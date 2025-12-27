//
//  MatchHistoryHandler.swift
//  Beamway
//
//  Created by Zhao on 2025/12/24.
//

import UIKit
import CoreData

class MatchHistoryHandler {

    static let globalHandler = MatchHistoryHandler()

    private init() {}

    private var persistentStorage: NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        return appDelegate.persistentContainer
    }

    private var dataContext: NSManagedObjectContext {
        return persistentStorage.viewContext
    }

    // MARK: - Save Game Record

    func storeMatchHistory(points: Int, category: String, timestamp: Date = Date()) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "GameRecordEntity", in: dataContext)!
        let historyObject = NSManagedObject(entity: entityDescription, insertInto: dataContext)

        historyObject.setValue(points, forKey: "scoreValue")
        historyObject.setValue(category, forKey: "gameMode")
        historyObject.setValue(timestamp, forKey: "recordDate")
        historyObject.setValue(UUID().uuidString, forKey: "recordIdentifier")

        do {
            try dataContext.save()
        } catch {
        }
    }

    // MARK: - Save Longest Time Record

    func storePeakDurationHistory(duration: TimeInterval, category: String) {
        let userDefaults = UserDefaults.standard
        let key = "longestTime_\(category)"

        // Get current longest time
        let currentPeak = userDefaults.double(forKey: key)

        // Save if this is longer
        if duration > currentPeak {
            userDefaults.set(duration, forKey: key)
            userDefaults.synchronize()
        }
    }

    // MARK: - Get Longest Time Record

    func retrievePeakDurationHistory(category: String) -> TimeInterval {
        let userDefaults = UserDefaults.standard
        let key = "longestTime_\(category)"
        return userDefaults.double(forKey: key)
    }

    func obtainFormattedPeakDuration(category: String) -> String {
        let duration = retrievePeakDurationHistory(category: category)
        if duration > 0 {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "N/A"
    }

    // MARK: - Fetch Game Records

    func retrieveAllMatchHistories() -> [MatchHistoryData] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "recordDate", ascending: false)]

        do {
            let histories = try dataContext.fetch(fetchRequest)
            return histories.map { history in
                MatchHistoryData(
                    uniqueId: history.value(forKey: "recordIdentifier") as? String ?? "",
                    points: history.value(forKey: "scoreValue") as? Int ?? 0,
                    category: history.value(forKey: "gameMode") as? String ?? "",
                    timestamp: history.value(forKey: "recordDate") as? Date ?? Date()
                )
            }
        } catch {
            return []
        }
    }

    // MARK: - Delete Game Record

    func removeMatchHistory(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        fetchRequest.predicate = NSPredicate(format: "recordIdentifier == %@", uniqueId)

        do {
            let histories = try dataContext.fetch(fetchRequest)
            histories.forEach { dataContext.delete($0) }
            try dataContext.save()
        } catch {
            print("Failed to delete game record: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete All Game Records

    func removeAllMatchHistories() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameRecordEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try dataContext.execute(deleteRequest)
            try dataContext.save()
        } catch {
            print("Failed to delete all game records: \(error.localizedDescription)")
        }
    }
}

// MARK: - Game Record Model

struct MatchHistoryData {
    let uniqueId: String
    let points: Int
    let category: String
    let timestamp: Date

    var displayableTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

