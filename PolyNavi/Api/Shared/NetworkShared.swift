//
//  NetworkShared.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.04.2022.
//

import Foundation
import Alamofire

enum ApiStatus<T> {
    case successWith(T)
    case errorNoInternet
    case error
    
    var data: T? {
        get {
            switch self {
            case .successWith(let t):
                return t
            case .errorNoInternet, .error:
                return nil
            }
        }
    }
}

class NetworkShared {
    static func load<T:Codable>(url: String, metod: HTTPMethod, params: Dictionary<String, String>, enecodig: ParameterEncoding = URLEncoding.default, completion: @escaping (ApiStatus<T>) -> Void) {
        AF.request(url,
                   method: metod,
                   parameters: params,
                   encoding: enecodig)
            .responseDecodable(of: T.self) { response in
                if let responseCode = response.response?.statusCode {
                    switch responseCode {
                    case (200...300):
                        if let data = response.value {
                            completion(.successWith(data))
                        }
                        else {
                            completion(.error)
                        }
                    default:
                        completion(.error)
                    }
                } else {
                    if let error = response.error as NSError? {
                        switch error.code {
                        case 13:
                            completion(.errorNoInternet)
                        default:
                            completion(.error)
                        }
                    }
                    completion(.error)
                }
            }
    }
}
