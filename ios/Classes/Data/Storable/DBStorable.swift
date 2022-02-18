// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  DBStorable.swift

import CoreData
import UIKit

protocol DBStorable: AnyObject {
    typealias DBOperationHandler = (DBOperationResult<Self>) -> Void
    typealias DBOperationErrorHandler = (DBOperationError?) -> Void
    
    static func create(
        entity: String,
        with keyedValues: [String: Any],
        then handler: DBOperationHandler?,
        in persistentContainer: NSPersistentContainer?
    )
    static func fetchAll(
        entity: String,
        with predicate: NSPredicate?,
        sortDescriptor: NSSortDescriptor?,
        then handler: DBOperationHandler?,
        in persistentContainer: NSPersistentContainer?
    )
    static func clear(entity: String, in persistentContainer: NSPersistentContainer?)
    
    func update(
        entity: String,
        with keyedValues: [String: Any],
        then handler: DBOperationHandler?,
        in persistentContainer: NSPersistentContainer?
    )
    func remove(entity: String, then handler: DBOperationHandler?, in persistentContainer: NSPersistentContainer?)
}

extension DBStorable where Self: NSManagedObject {
    static func create(
        entity: String,
        with keyedValues: [String: Any],
        then handler: DBOperationHandler? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) {
        guard let context = persistentContainer?.viewContext else {
            return
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: entity, in: context) else {
            handler?(.error(error: .noContext))
            return
        }
        
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValuesForKeys(keyedValues)
        
        do {
            try context.save()
            handler?(.result(object: object))
        } catch {
            handler?(.error(error: .writeFailed))
        }
    }
    
    static func fetchAll(
        entity: String,
        with predicate: NSPredicate? = nil,
        sortDescriptor: NSSortDescriptor? = nil,
        then handler: DBOperationHandler? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) {
        guard let context = persistentContainer?.viewContext else {
            return
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            handler?(.results(objects: response))
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    static func fetchAllSyncronous(
        entity: String,
        with predicate: NSPredicate? = nil,
        sortDescriptor: NSSortDescriptor? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) -> DBOperationResult<Self> {
        guard let context = persistentContainer?.viewContext else {
            return .error(error: .noContext)
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            return .results(objects: response)
        } catch {
            return .error(error: .readFailed)
        }
    }
    
    static func clear(
        entity: String,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) {
        guard let context = persistentContainer?.viewContext else {
            return
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        } catch {
        }
    }
    
    func update(
        entity: String,
        with keyedValues: [String: Any],
        then handler: DBOperationHandler? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) {
        guard let context = persistentContainer?.viewContext else {
            return
        }
        
        do {
            let object = try context.existingObject(with: objectID)
            object.setValuesForKeys(keyedValues)
            
            do {
                try context.save()
                handler?(.result(object: object))
            } catch {
                handler?(.error(error: .writeFailed))
            }
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    func removeValue(
        entity: String,
        with key: String,
        then handler: DBOperationHandler? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) {
        guard let context = persistentContainer?.viewContext else {
            return
        }
        
        do {
            let object = try context.existingObject(with: objectID)
            object.setValue(nil, forKey: key)
            
            do {
                try context.save()
                handler?(.result(object: object))
            } catch {
                handler?(.error(error: .writeFailed))
            }
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    func remove(
        entity: String,
        then handler: DBOperationHandler? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) {
        guard let context = persistentContainer?.viewContext else {
            return
        }
        
        do {
            let object = try context.existingObject(with: objectID)
            context.delete(object)
            
            do {
                try context.save()
                handler?(.result(object: object))
            } catch {
                handler?(.error(error: .writeFailed))
            }
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    static func hasResult(
        entity: String,
        with predicate: NSPredicate? = nil,
        in persistentContainer: NSPersistentContainer? = UIApplication.shared.appDelegate?.persistentContainer
    ) -> Bool {
        guard let context = persistentContainer?.viewContext else {
            return false
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            return !response.isEmpty
        } catch {
            return false
        }
    }
}

enum DBOperationError: Error {
    case readFailed
    case writeFailed
    case noContext
}

enum DBOperationResult<Object: DBStorable> {
    case result(object: NSManagedObject)
    case results(objects: [Any])
    case error(error: DBOperationError)
}
