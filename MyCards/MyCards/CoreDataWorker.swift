//
//  CoreDataWorker.swift
//  MyCards
//
//  Created by Maciej Piotrowski on 16/10/16.
//  Copyright © 2016 Maciej Piotrowski. All rights reserved.
//

import Foundation
import CoreData


enum CoreDataWorkerError: Error {
    case cannotFetch(String)
    case cannotSave(Error)
}

protocol NotificationCenterProtocol {
    func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?)
    func removeObserver(_ observer: Any)
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?)
    func post(_ notification: Notification)
    func post(name aName: NSNotification.Name, object anObject: Any?)
    func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]?)
}

extension NotificationCenter: NotificationCenterProtocol {}


extension CoreDataWorkerError: Equatable {}
func == (lhs: CoreDataWorkerError, rhs: CoreDataWorkerError) -> Bool {
    switch (lhs, rhs) {
    case (.cannotFetch(_), .cannotFetch(_)),
         (.cannotSave(_), .cannotSave(_)):
        return true
    default:
        return false
    }
}

protocol ManagedObjectProtocol {
    associatedtype Entity
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    func toEntity() -> Entity?
}

protocol ManagedObjectConvertible {
    associatedtype ManagedObject: NSManagedObject, ManagedObjectProtocol
    func toManagedObject(in context: NSManagedObjectContext, create: Bool) -> ManagedObject?
}

protocol CoreDataWorkerProtocol {
    func get<Entity: ManagedObjectConvertible>
        (with predicate: NSPredicate?,
         sortDescriptors: [NSSortDescriptor]?,
         fetchLimit: Int?,
         completion: @escaping (Result<[Entity]>) -> Void)
    
    func getManaged<ManagedEntity: NSManagedObject>
        (with predicate: NSPredicate?,
         sortDescriptors: [NSSortDescriptor]?,
         fetchLimit: Int?,
         completion:  @escaping (Result<[ManagedEntity]>) -> Void)
    where ManagedEntity: ManagedObjectProtocol
    
    func update<Entity: ManagedObjectConvertible>
        (entities: [Entity],
         completion: @escaping (Error?) -> Void)
    
    func upsert<Entity: ManagedObjectConvertible>
        (entities: [Entity],
         completion: @escaping (Error?) -> Void)
    
    func remove<Entity: ManagedObjectConvertible>
        (entities: [Entity],
         completion: @escaping (Error?) -> Void)
}

extension CoreDataWorkerProtocol {
    func get<Entity: ManagedObjectConvertible>
        (with predicate: NSPredicate? = nil,
         sortDescriptors: [NSSortDescriptor]? = nil,
         fetchLimit: Int? = nil,
         completion: @escaping (Result<[Entity]>) -> Void) {
        get(with: predicate,
            sortDescriptors: sortDescriptors,
            fetchLimit: fetchLimit,
            completion: completion)
    }
}

class CoreDataWorker: CoreDataWorkerProtocol {
    
    let coreData: CoreDataServiceProtocol
    let notificationCenter: NotificationCenterProtocol
    
    init(coreData: CoreDataServiceProtocol = CoreDataService.shared,
         notificationCenter: NotificationCenterProtocol = NotificationCenter.default) {
        self.coreData = coreData
        self.notificationCenter = notificationCenter
    }
    
    func get<Entity: ManagedObjectConvertible>
        (with predicate: NSPredicate?,
         sortDescriptors: [NSSortDescriptor]?,
         fetchLimit: Int?,
         completion: @escaping (Result<[Entity]>) -> Void) {
        coreData.performForegroundTask { context in
            do {
                let fetchRequest = Entity.ManagedObject.fetchRequest()
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = sortDescriptors
                if let fetchLimit = fetchLimit {
                    fetchRequest.fetchLimit = fetchLimit
                }
                let results = try context.fetch(fetchRequest) as? [Entity.ManagedObject]
                let items: [Entity] = results?.flatMap { $0.toEntity() as? Entity } ?? []
                completion(.success(items))
            } catch {
                let fetchError = CoreDataWorkerError.cannotFetch("Cannot fetch error: \(error))")
                completion(.failure(fetchError))
            }
        }
    }
    
    func getManaged<ManagedEntity: NSManagedObject>
        (with predicate: NSPredicate?,
         sortDescriptors: [NSSortDescriptor]?,
         fetchLimit: Int? = nil,
         completion:  @escaping (Result<[ManagedEntity]>) -> Void)
        where ManagedEntity: ManagedObjectProtocol {
            coreData.performForegroundTask { context in
                do {
                    let fetchRequest = ManagedEntity.fetchRequest()
                    fetchRequest.predicate = predicate
                    fetchRequest.sortDescriptors = sortDescriptors
                    if let fetchLimit = fetchLimit {
                        fetchRequest.fetchLimit = fetchLimit
                    }
                    let results = try context.fetch(fetchRequest) as? [ManagedEntity]
                    completion(.success(results ?? []))
                } catch {
                    completion(.failure(CoreDataWorkerError.cannotFetch("Cannot fetch error: \(error)")))
                }
            }
    }
    
    func update<Entity: ManagedObjectConvertible>
        (entities: [Entity],
         completion: @escaping (Error?) -> Void) {
        coreData.performBackgroundTask { context in
            _ = entities.flatMap { entity in
                entity.toManagedObject(in: context, create: false)
            }
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(CoreDataWorkerError.cannotSave(error))
            }
        }
    }
    func upsert<Entity: ManagedObjectConvertible>
        (entities: [Entity],
         completion: @escaping (Error?) -> Void) {
        
        if entities.isEmpty {
            completion(nil)
            return
        }
        
        coreData.performBackgroundTask { context in
            _ = entities.flatMap({ (entity) -> Entity.ManagedObject? in
                return entity.toManagedObject(in: context, create: true)
            })
            do {
                try context.save()
                let name = Notification.Name("entitiesUpserted" + String(describing: Entity.self))
                let userInfo: [String: Any] = [
                    "entities": entities,
                    "sender": self
                ]
                let notification = Notification(name: name, object: self, userInfo: userInfo)
                self.notificationCenter.post(notification)
                
                completion(nil)
            } catch {
                completion(CoreDataWorkerError.cannotSave(error))
            }
        }
    }
    
    func remove<Entity: ManagedObjectConvertible>
        (entities: [Entity], completion: @escaping (Error?) -> Void) {
        coreData.performBackgroundTask { (context) in
            for entity in entities {
                if let managedEntity = entity.toManagedObject(in: context, create: false) as? NSManagedObject {
                    context.delete(managedEntity)
                }
                /*Attempting to use NSManagedObjectContext's delete(:) method may result in calling the UIKit-added
                 delete(:) method on NSObject instead (part of the UIResponderStandardEditActions category) if the
                 argument is optional (including ImplicitlyUnwrappedOptional). (27206368)*/
            }
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(CoreDataWorkerError.cannotSave(error))
            }
        }
    }
}
