//
//  PrefDB.swift
//  QalamCast
//
//  Created by Zakir Magdum on 12/7/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PrefDB {
    static let shared = PrefDB()
    let persistentContainer: NSPersistentContainer!
    
    //MARK: Init with dependency
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        //Use the default container for production environment
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get shared app delegate")
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

    //MARK: CRUD
    func insertStats( title: String, played: Double ) -> EpisodeStats? {
        guard let stats = NSEntityDescription.insertNewObject(forEntityName: "EpisodeStats", into: backgroundContext) as? EpisodeStats else { return nil }
        stats.title = title
        stats.played = played
        save()
        return stats
    }

    func updateStats(title: String, played: Double) -> EpisodeStats? {
//        print("Updating stats \(title) \(played)")
        let request: NSFetchRequest<EpisodeStats> = EpisodeStats.fetchRequest()
        request.predicate = NSPredicate(format: "title = %@", title)
        let results = try? persistentContainer.viewContext.fetch(request)
        if results != nil && results!.count > 0 {
            //print("Updating stats \(title) \(played)")
            let mo = results![0]
            mo.played = played
            try! persistentContainer.viewContext.save()
            return mo
        } else {
            return insertStats(title: title, played: played)
        }
    }
    
    func getStats(title: String) -> EpisodeStats? {
        let request: NSFetchRequest<EpisodeStats> = EpisodeStats.fetchRequest()
        request.predicate = NSPredicate(format: "title = %@", title)
        let results = try? persistentContainer.viewContext.fetch(request)
        if results != nil && results!.count > 0 {
            return results![0]
        } else {
            return insertStats(title: title, played: 0)
        }
    }
    
    func getEpisodePlayed(title: String) -> Double {
        let pl = getStats(title: title)!.played
        print("Fetched played \(title) \(pl)")
        return pl
    }

    func fetchAll() -> [EpisodeStats] {
        let request: NSFetchRequest<EpisodeStats> = EpisodeStats.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [EpisodeStats]()
    }

    func remove( objectID: NSManagedObjectID ) {
        let obj = backgroundContext.object(with: objectID)
        backgroundContext.delete(obj)
    }

    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }

    }
}
