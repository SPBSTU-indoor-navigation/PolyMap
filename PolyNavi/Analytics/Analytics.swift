import AppMetricaCore

class Analytics {
    static let shared = Analytics()
    
    func start() {
        let configuration = AppMetricaConfiguration(apiKey: APP_METRICA_API_KEY)!
        configuration.locationTracking = false
        
        AppMetrica.activate(with: configuration)
    }
    
    // Пользователь посмотрел инфу об аннотации с id
    func openUnitDetail(with id: UUID) {
        AppMetrica.reportEvent(name: "OpenUnitDetail", parameters: ["id": id.uuidString])
    }
    
    // Пользователь открыл аннотацию по длинной ссылке
    func openSharedAnnotation(with id: UUID) {
        AppMetrica.reportEvent(name: "OpenSharedAnnotation", parameters: ["id": id.uuidString])
    }
    
    // Пользователь создал маршрут от from до to с параметрами asphalt и serviceRoute
    func createRoute(from: UUID, to: UUID, params: RouteParameters) {
        AppMetrica.reportEvent(name: "CreateRoute", parameters: [
            "from": from.uuidString,
            "to": to.uuidString,
            "asphalt": params.asphalt,
            "serviceRoute": params.serviceRoute
        ])
    }
    
    // Пользователь открыл маршрут по ссылке
    func openSharedRoute(from: UUID, to: UUID, params: RouteParameters) {
        AppMetrica.reportEvent(name: "OpenSharedRoute", parameters: [
            "from": from.uuidString,
            "to": to.uuidString,
            "asphalt": params.asphalt,
            "serviceRoute": params.serviceRoute
        ])
    }
    
    // Пользователь открыл приглашение с id
    func openSharedQR(with id: String) {
        AppMetrica.reportEvent(name: "OpenSharedQR", parameters: ["id": id])
    }
    
    // Пользователь открыл диалог поделиться, чтоб создать приглашение
    func openShareQRDialog() {
        AppMetrica.reportEvent(name: "OpenShareQRDialog")
    }
    
    // Пользователь создал приглашение
    func shareQR(with id: String, settings: ShareDialog.Settings) {
        var color = ""
        
        if let variant = settings.color?.currentVariant {
            color = String(describing: variant.self)
        }
        
        AppMetrica.reportEvent(name: "ShareQR", parameters: [
            "id": id,
            "isQR": settings.isQR,
            "color": color,
            "useLogo": settings.qrLogoVariant == .use,
            "useBadge": settings.bage == .badge,
            "useHelloText": !(settings.text?.isEmpty ?? true)
        ])
    }
    
    // Пользователь поделился маршрутом по длинной ссылке
    func shareRoute(from: UUID, to: UUID, params: RouteParameters) {
        AppMetrica.reportEvent(name: "ShareRoute", parameters: [
            "from": from.uuidString,
            "to": to.uuidString,
            "asphalt": params.asphalt,
            "serviceRoute": params.serviceRoute
        ])
    }
    
    // Пользователь поделился аннотацией по длинной ссылке
    func shareAnnotation(with id: UUID) {
        AppMetrica.reportEvent(name: "ShareAnnotation", parameters: ["id": id.uuidString])
    }
    
    
    
    
    // Timetable
    func openTimeTable(insitute: String, group: String) {
        AppMetrica.reportEvent(name: "OpenTimeTable", parameters: [
            "insitute": insitute,
            "group": group
        ])
    }
    
    func applyInstitute(insitute: String, group: String) {
        let profile = MutableUserProfile()
        
        profile.apply(from: [
            ProfileAttribute.customString("insitute").withValue(insitute),
            ProfileAttribute.customString("group").withValue(group)
        ])
        
        AppMetrica.reportUserProfile(profile)
    }
}
