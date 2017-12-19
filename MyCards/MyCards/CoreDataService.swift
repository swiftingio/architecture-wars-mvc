//
//  CoreDataStack.swift
//  Created by swifting.io Team
//

import CoreData

protocol CoreDataServiceProtocol: class {
    var errorHandler: (Error) -> Void { get set }
    var persistentContainer: NSPersistentContainer { get }
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}

final class CoreDataService: CoreDataServiceProtocol {

    static let shared = CoreDataService()
    var errorHandler: (Error) -> Void = { _ in }
    private let notificationCenter: NotificationCenterProtocol = NotificationCenter.default
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { [weak self](_, error) in
            if let error = error {
                NSLog("CoreData error \(error), \(String(describing: error._userInfo))")
                self?.errorHandler(error)
            }
        })
        return container
    }()

    lazy var viewContext: NSManagedObjectContext = {
        let context: NSManagedObjectContext = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }

    private func startObservingChanges(in context: NSManagedObjectContext) {
        notificationCenter.addObserver(self,
                                       selector: #selector(handleSaveNotification(_:)),
                                       name: .NSManagedObjectContextDidSave,
                                       object: context)
    }

    private func stopObservingChanges(in context: NSManagedObjectContext) {
        notificationCenter.removeObserver(self,
                                          name: .NSManagedObjectContextDidSave,
                                          object: context)
    }

    private func objects(from notification: Notification) -> Set<NSManagedObject> {
        guard let userInfo = notification.userInfo else { return Set() }

        var allObjects: Set<NSManagedObject> = Set()

        if let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updated.isEmpty {
            allObjects.formUnion(updated)
        }

        if let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deleted.isEmpty {
            allObjects.formUnion(deleted)
        }

        if let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, !inserted.isEmpty {
            allObjects.formUnion(inserted)
        }

        return allObjects
    }

    @objc private func handleSaveNotification(_ notification: Notification) {

        let allObjects: Set<NSManagedObject> = objects(from: notification)

        var notificationNames: Set<Notification.Name> = Set()

        for object in allObjects {
            let name: Notification.Name = Notification.Name.entitiesChanged(type(of: object))
            notificationNames.insert(name)
        }

        DispatchQueue.main.async {
            for name in notificationNames {
                self.notificationCenter.post(name: name, object: self)
            }
        }
    }
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { [weak self] context in
            self?.startObservingChanges(in: context)
            block(context)
            self?.stopObservingChanges(in: context)
        }
    }
}
