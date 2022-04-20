//
//  CodeGeneratorProvider.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.04.2022.
//

import Foundation
import Alamofire

class CodeGeneratorProvider{
    enum Constants {
        static let BASE_URL = "https://polymap.ru/api"
    }
    
    static func load<T:Codable>(url: String, metod: HTTPMethod, params: Dictionary<String, String>, enecodig: ParameterEncoding = URLEncoding.default, completion: @escaping (ApiStatus<T>) -> Void) {
        NetworkShared.load(url: Constants.BASE_URL + url, metod: metod, params: params, enecodig: enecodig, completion: completion)
    }
    
    static func loadStatus(completion: @escaping (ApiStatus<CodeGeneratorModel.ServerStatus>) -> Void) {
        load(url: "/generator/status", metod: .get, params: [:], completion: completion)
    }
    
    static func loadData(id: String, completion: @escaping (ApiStatus<CodeGeneratorModel.DataResponse>) -> Void) {
        load(url: "/l/\(id)", metod: .get, params: [:], completion: completion)
    }
    
    static func generateCode(isQR: Bool, from: UUID, to: UUID, text: String?, completion: @escaping (ApiStatus<CodeGeneratorModel.GenerateResponse>) -> Void) {
        let settings =  [
            "codeVariant": isQR ? "qr" : "appclip",
            "from": from.uuidString,
            "to": to.uuidString,
            "helloText": text ?? ""
        ]
        
        load(url: "/generate", metod: .post, params: settings, enecodig: JSONEncoding.default, completion: completion)
    }
    
    static func loadAppclip(id: Int,
                     colorVariant: ShareDialog.ColorVariant?,
                     logoVariant: ShareDialog.LogoVariant?,
                     badgeVariant: ShareDialog.BadgeVariant?,
                     completion: @escaping (ApiStatus<UIImage>) -> Void) {
        
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
        params["type"] = "png"
    
        
        AF.request(Constants.BASE_URL + "/appclip-code", method: .get, parameters: params)
            .response(completionHandler: { res in
                if let data = res.data,
                   let img = UIImage(data: data) {
                    completion(.successWith(img))
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
