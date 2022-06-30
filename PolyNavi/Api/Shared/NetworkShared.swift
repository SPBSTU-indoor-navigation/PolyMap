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
    
    var isErrorNoInternet: Bool {
        if case .errorNoInternet = self { return true }
        return false
    }
    
    var isGenericError: Bool {
        if case .error = self { return true }
        return false
    }
}

class NetworkShared {
    enum Constants {
        static let BASE_URL = "https://polymap.ru"
    }
    
    static func load<T:Codable>(url: String, metod: HTTPMethod, params: Dictionary<String, String>, enecodig: ParameterEncoding = URLEncoding.default, timeoutInterval: TimeInterval = 30, completion: @escaping (ApiStatus<T>) -> Void) {
        AF.request(url,
                   method: metod,
                   parameters: params,
                   encoding: enecodig) { $0.timeoutInterval = timeoutInterval }
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
                    } else {
                        completion(.error)
                    }
                }
            }
    }
}
