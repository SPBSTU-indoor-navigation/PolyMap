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
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: APP_METRICA_API_KEY)!
        configuration.locationTracking = false
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    // Пользователь посмотрел инфу об аннотации с id
    func openUnitDetail(with id: UUID) {
        YMMYandexMetrica.reportEvent("OpenUnitDetail", parameters: ["id": id])
    }
    
    // Пользователь открыл аннотацию по длинной ссылке
    func openSharedAnnotation(with id: UUID) {
        YMMYandexMetrica.reportEvent("OpenSharedAnnotation", parameters: ["id": id])
    }
    
    // Пользователь создал маршрут от from до to с параметрами asphalt и serviceRoute
    func createRoute(from: UUID, to: UUID, params: RouteParameters) {
        YMMYandexMetrica.reportEvent("CreateRoute", parameters: [
            "from": from.uuidString,
            "to": to.uuidString,
            "asphalt": params.asphalt,
            "serviceRoute": params.serviceRoute
        ])
    }
    
    // Пользователь открыл маршрут по ссылке
    func openSharedRoute(from: UUID, to: UUID, params: RouteParameters) {
        YMMYandexMetrica.reportEvent("OpenSharedRoute", parameters: [
            "from": from.uuidString,
            "to": to.uuidString,
            "asphalt": params.asphalt,
            "serviceRoute": params.serviceRoute
        ])
    }
    
    // Пользователь открыл приглашение с id
    func openSharedQR(with id: String) {
        YMMYandexMetrica.reportEvent("OpenSharedQR", parameters: ["id": id])
    }
    
    // Пользователь открыл диалог поделиться, чтоб создать приглашение
    func openShareQRDialog() {
        YMMYandexMetrica.reportEvent("OpenShareQRDialog")
    }
    
    // Пользователь создал приглашение
    func shareQR(with id: String, settings: ShareDialog.Settings) {
        YMMYandexMetrica.reportEvent("ShareQR", parameters: [
            "id": id,
            "isQR": settings.isQR,
            "color": String(describing: settings.color.self),
            "useLogo": String(describing: settings.qrLogoVariant.self),
            "useBadge": settings.bage == .badge,
            "useHelloText": !(settings.text?.isEmpty ?? true)
        ])
    }
    
    // Пользователь поделился маршрутом по длинной ссылке
    func shareRoute(from: UUID, to: UUID, params: RouteParameters) {
        YMMYandexMetrica.reportEvent("ShareRoute", parameters: [
            "from": from.uuidString,
            "to": to.uuidString,
            "asphalt": params.asphalt,
            "serviceRoute": params.serviceRoute
        ])
    }
    
    // Пользователь поделился аннотацией по длинной ссылке
    func shareAnnotation(with id: UUID) {
        YMMYandexMetrica.reportEvent("ShareAnnotation", parameters: ["id": id.uuidString])
    }
}
