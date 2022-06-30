//
//  ReportApiProvider.swift.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.05.2022.
//

import Foundation
import Alamofire

class ReportApiProvider {
    enum Constants {
        static let BASE_URL = NetworkShared.Constants.BASE_URL
    }
    
    class Result: Codable {
        let message: String = ""
    }
    
    static func sendReport(message: String, report: SectionCollection.Report.ReportBase, completion: @escaping (ApiStatus<Result>) -> Void) {
        if let report = report as? SectionCollection.Report.ReportRoute {
            return sendReport(message: message, route: report, completion: completion)
        } else if let report = report as? SectionCollection.Report.ReportAnnotation {
            return sendReport(message: message, annotation: report, completion: completion)
        }
    }
    
    static func sendReport(message: String, route: SectionCollection.Report.ReportRoute, completion: @escaping (ApiStatus<Result>) -> Void) {
        var params = [
            "message": message,
            "from": route.from.imdfID.uuidString,
            "to": route.to.imdfID.uuidString,
            "asphalt": String(route.params.asphalt),
            "serviceRoute": String(route.params.serviceRoute)
        ]
        params = addDeviceInfo(params: &params)
        
        NetworkShared.load(url: Constants.BASE_URL + "/api/report/route", metod: .post, params: params, enecodig: JSONEncoding.default, timeoutInterval: 10, completion: completion)
    }
    
    static func sendReport(message: String, annotation: SectionCollection.Report.ReportAnnotation, completion: @escaping (ApiStatus<Result>) -> Void) {
        var params = [
            "message": message,
            "annotation": annotation.annotation.imdfID.uuidString
        ]
        params = addDeviceInfo(params: &params)
        
        NetworkShared.load(url: Constants.BASE_URL + "/api/report/annotation", metod: .post, params: params, enecodig: JSONEncoding.default, timeoutInterval: 10, completion: completion)
    }
    
    static private func addDeviceInfo(params: inout [String:String]) -> [String:String] {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        let device = UIDevice.current
        
        params["modelCode"] = modelCode ?? "-"

        params["os"] = "\(device.systemName) \(device.systemVersion)"
        params["orientation"] = device.orientation.isLandscape ? "Landscape" : device.orientation.isPortrait ? "Portrait" : "-"
        
        params["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        params["locale"] = Locale.current.languageCode
        
        params["screen"] = "\(UIScreen.main.bounds.width)x\(UIScreen.main.bounds.height)"
        
        
        return params
    }
}
