//
//  GameRecordManager.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit
import CoreData

class GameRecordManager {
    
    static let sharedInstance = GameRecordManager()
    
    private init() {}
    
    private var persistentContainer: NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        return appDelegate.persistentContainer
    }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Game Record
    
    func saveGameRecord(score: Int, mode: String, date: Date = Date()) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "GameRecordEntity", in: context)!
        let recordObject = NSManagedObject(entity: entityDescription, insertInto: context)
        
        recordObject.setValue(score, forKey: "scoreValue")
        recordObject.setValue(mode, forKey: "gameMode")
        recordObject.setValue(date, forKey: "recordDate")
        recordObject.setValue(UUID().uuidString, forKey: "recordIdentifier")
        
        do {
            try context.save()
        } catch {
        }
    }
    
    // MARK: - Save Longest Time Record
    
    func saveLongestTimeRecord(time: TimeInterval, mode: String) {
        let userDefaults = UserDefaults.standard
        let key = "longestTime_\(mode)"
        
        // Get current longest time
        let currentLongest = userDefaults.double(forKey: key)
        
        // Save if this is longer
        if time > currentLongest {
            userDefaults.set(time, forKey: key)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Get Longest Time Record
    
    func getLongestTimeRecord(mode: String) -> TimeInterval {
        let userDefaults = UserDefaults.standard
        let key = "longestTime_\(mode)"
        return userDefaults.double(forKey: key)
    }
    
    func getFormattedLongestTime(mode: String) -> String {
        let time = getLongestTimeRecord(mode: mode)
        if time > 0 {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "N/A"
    }
    
    // MARK: - Fetch Game Records
    
    func fetchAllGameRecords() -> [GameRecordModel] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: false)]
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.map { record in
                GameRecordModel(
                    identifier: record.value(forKey: "recordIdentifier") as? String ?? "",
                    score: record.value(forKey: "scoreValue") as? Int ?? 0,
                    mode: record.value(forKey: "gameMode") as? String ?? "",
                    date: record.value(forKey: "recordDate") as? Date ?? Date()
                )
            }
        } catch {
            return []
        }
    }
    
    // MARK: - Delete Game Record
    
    func deleteGameRecord(identifier: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        fetchRequest.predicate = NSPredicate(format: "recordIdentifier == %@", identifier)
        
        do {
            let records = try context.fetch(fetchRequest)
            records.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Failed to delete game record: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete All Game Records
    
    func deleteAllGameRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameRecordEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete all game records: \(error.localizedDescription)")
        }
    }
}

// MARK: - Game Record Model

struct GameRecordModel {
    let identifier: String
    let score: Int
    let mode: String
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

