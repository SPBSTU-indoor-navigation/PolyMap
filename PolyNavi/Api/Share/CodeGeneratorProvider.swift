//
//  CodeGeneratorProvider.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.04.2022.
//

import Foundation
import Alamofire

class CodeGeneratorProvider {
    enum Constants {
        static let BASE_URL = "https://polymap.ru"
    }
    
    struct RouteSettings {
        let isQR: Bool
        let from: UUID
        let to: UUID
        let text: String?
        let asphalt: Bool
        let serviceRoute: Bool
        let allowParameterChange: Bool
    }
    
    static func load<T:Codable>(url: String, metod: HTTPMethod, params: Dictionary<String, String>, enecodig: ParameterEncoding = URLEncoding.default, completion: @escaping (ApiStatus<T>) -> Void) {
        NetworkShared.load(url: Constants.BASE_URL + "/api" + url, metod: metod, params: params, enecodig: enecodig, completion: completion)
    }
    
    static func loadStatus(completion: @escaping (ApiStatus<CodeGeneratorModel.ServerStatus>) -> Void) {
        load(url: "/generator/status", metod: .get, params: [:], completion: completion)
    }
    
    static func loadData(id: String, completion: @escaping (ApiStatus<CodeGeneratorModel.DataResponse>) -> Void) {
        load(url: "/load/\(id)", metod: .get, params: [:], completion: completion)
    }
    
    static func generateCode(settings: RouteSettings, completion: @escaping (ApiStatus<CodeGeneratorModel.GenerateResponse>) -> Void) {
        let params = [
            "codeVariant": settings.isQR ? "qr" : "appclip",
            "from": settings.from.uuidString,
            "to": settings.to.uuidString,
            "helloText": settings.text ?? "",
            "asphalt": String(settings.asphalt),
            "serviceRoute": String(settings.serviceRoute),
            "allowParameterChange": String(settings.allowParameterChange)
        ]
        
        load(url: "/generate", metod: .post, params: params, enecodig: JSONEncoding.default, completion: completion)
    }
    
    static func createParams(id: Int,
                             colorVariant: ShareDialog.ColorVariant?,
                             logoVariant: ShareDialog.LogoVariant?,
                             badgeVariant: ShareDialog.BadgeVariant?) -> [String : String] {
        let preset = colorVariant?.preset
        
        var params: [String : String] = [
            "id": "\(id)"
        ]
        
        if let color = preset?.background { params["background"] = color }
        if let color = preset?.primary { params["primary"] = color }
        if let color = preset?.secondary { params["secondary"] = color }
        if let color = preset?.badgeTextColor { params["badgeTextColor"] = color }
        params["logo"] = logoVariant == .phone ? "phone" : "camera"
        params["useBadge"] = badgeVariant == .circle ? "false" : "true"
        
        return params
    }
    
    static func tutorialUrl(id: Int,
                            colorVariant: ShareDialog.ColorVariant?,
                            logoVariant: ShareDialog.LogoVariant?,
                            badgeVariant: ShareDialog.BadgeVariant?) -> URL {
        
        let params = createParams(id: id, colorVariant: colorVariant, logoVariant: logoVariant, badgeVariant: badgeVariant)
        
        
        return URL(string: Constants.BASE_URL + "/tutorial?" + params.compactMap({ (key, value) in "\(key)=\(value)" }).joined(separator: "&"))!
    }
    
    static func loadAppclip(id: Int,
                            colorVariant: ShareDialog.ColorVariant?,
                            logoVariant: ShareDialog.LogoVariant?,
                            badgeVariant: ShareDialog.BadgeVariant?,
                            svg: Bool,
                            width: Int = 2048,
                            completion: @escaping (ApiStatus<URL>) -> Void) {
        
        var params = createParams(id: id, colorVariant: colorVariant, logoVariant: logoVariant, badgeVariant: badgeVariant)
        params["type"] = svg ? "svg" : "png"
        params["width"] = "\(width)"
        
        AF.request(Constants.BASE_URL + "/api/appclip-code", method: .get, parameters: params)
            .response(completionHandler: { res in
                if let data = res.data {
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let filePath =  "\(path)/AppClip.\(svg ? "svg" : "png")";
                    
                    do {
                        let url = URL(fileURLWithPath: filePath)
                        try data.write(to: url)
                        completion(.successWith(url))
                    } catch {
                        completion(.error)
                    }
                    
                } else {
                    if res.error?.responseCode == 13 {
                        completion(.errorNoInternet)
                    } else {
                        completion(.error)
                    }
                }
            })
    }
}
