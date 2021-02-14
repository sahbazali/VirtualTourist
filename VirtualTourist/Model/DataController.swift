//
//  DataController.swift
//  VirtualTourist
//
//  Created by Ali Şahbaz on 31.01.2021.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    var backgroundContext:NSManagedObjectContext!
    
    static let shared = DataController()
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    }
    
    func configureContexts(){
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSave()
            self.configureContexts()
            completion?()
        }
    }
}

extension DataController {
    func autoSave(interval:TimeInterval = 30) {
        guard interval > 0 else {
            print("negative interval, wtf are you doing?")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSave()
        }
    }
}
