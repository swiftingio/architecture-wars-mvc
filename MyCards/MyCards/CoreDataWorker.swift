//
//  CoreDataWorker.swift
//  Created by swifting.io Team
//

import Foundation
import CoreData

protocol CoreDataWorkerProtocol {
    func get<Entity: ManagedObjectConvertible>
        (with predicate: NSPredicate?,
         sortDescriptors: [NSSortDescriptor]?,
         fetchLimit: Int?,
         completion: @escaping (Result<[Entity]>) -> Void)
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

enum CoreDataWorkerError: Error {
    case cannotFetch(String)
    case cannotSave(Error)
}

class CoreDataWorker: CoreDataWorkerProtocol {
    let coreData: CoreDataServiceProtocol

    init(coreData: CoreDataServiceProtocol = CoreDataService.shared) {
        self.coreData = coreData
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

    func upsert<Entity: ManagedObjectConvertible>
        (entities: [Entity],
         completion: @escaping (Error?) -> Void) {

        coreData.performBackgroundTask { context in
            _ = entities.flatMap({ (entity) -> Entity.ManagedObject? in
                return entity.toManagedObject(in: context)
            })
            do {
                try context.save()
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
                if let managedEntity = entity.toManagedObject(in: context) {
                    context.delete(managedEntity)
                }
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
