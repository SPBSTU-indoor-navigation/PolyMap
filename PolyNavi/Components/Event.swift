import Foundation

class Event<T> {
    
    typealias EventHandler = (T) -> ()
    
    private var eventHandlers = [EventHandler]()
    
    func addHandler(handler: @escaping EventHandler) {
        eventHandlers.append(handler)
    }
    
    func invoke(data: T) {
        for handler in eventHandlers {
            handler(data)
        }
    }
}
