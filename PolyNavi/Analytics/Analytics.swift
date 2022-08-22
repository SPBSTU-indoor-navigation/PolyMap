//
//  Analytics.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 21.08.2022.
//

import YandexMobileMetrica


class Analytics {
    static let shared = Analytics()
    
    func start() {
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: APP_METRICA_API_KEY)
        configuration?.locationTracking = false
        
        YMMYandexMetrica.activate(with: configuration!)
    }
}
