//
//  NotificationCenter+Extension.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 08/01/17.
//

import Foundation
import CoreData

protocol NotificationCenterProtocol {
    func addObserver(_: Any, selector: Selector, name: NSNotification.Name?,
                     object: Any?)

    func addObserver(forName: NSNotification.Name?, object: Any?,
                     queue: OperationQueue?,
                     using: @escaping (Notification) -> Void) -> NSObjectProtocol
    func observeChanges<Entity>(for type: Entity.Type,
                        block: @escaping () -> Void) -> NSObjectProtocol
    where Entity : NSManagedObject

    func removeObserver(_: Any)
    func removeObserver(_: Any, name: NSNotification.Name?,
                        object: Any?)

    func post(_: Notification)
    func post(name: NSNotification.Name, object: Any?)
    func post(name: NSNotification.Name, object: Any?,
              userInfo: [AnyHashable : Any]?)
}

extension Notification.Name {

    static func entitiesChanged<Entity>(_ type: Entity.Type) -> Notification.Name
        where Entity : NSManagedObject {

            return Notification.Name("entitiesChanged" + String(describing: type))
    }
}

extension NotificationCenter: NotificationCenterProtocol {

    func observeChanges<Entity>(for type: Entity.Type,
                        block: @escaping () -> Void) -> NSObjectProtocol
        where Entity : NSManagedObject {
            return addObserver(forName: .entitiesChanged(type),
                               object: nil,
                               queue: .main) { (_) in
                                block()
            }
    }
}
