//
//  SessionRecordRepository.swift
//  Beamway
//
//  Repository for game session record persistence and retrieval
//

import UIKit
import CoreData

/// Repository managing all game session record persistence operations
/// Provides abstracted access to Core Data and UserDefaults storage
final class SessionRecordRepository {

    // MARK: - Singleton Access

    /// Shared repository instance
    static let shared = SessionRecordRepository()

    // MARK: - Properties

    /// Core Data persistent container reference
    private var persistentStorageContainer: NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access application delegate for persistent storage")
        }
        return appDelegate.persistentContainer
    }

    /// Core Data managed object context
    private var managedObjectContext: NSManagedObjectContext {
        return persistentStorageContainer.viewContext
    }

    /// User defaults storage reference
    private let userDefaultsStorage: UserDefaults

    /// Core Data entity name constant
    private let sessionRecordEntityName = "GameRecordEntity"

    /// User defaults key prefix for duration records
    private let durationRecordKeyPrefix = "longestTime_"

    // MARK: - Initialization

    private init() {
        self.userDefaultsStorage = UserDefaults.standard
    }

    // MARK: - Session Record Persistence

    /// Persist new session result to storage
    func persistSessionResult(_ sessionResult: SessionResultDataModel) {
        let entityDescription = NSEntityDescription.entity(
            forEntityName: sessionRecordEntityName,
            in: managedObjectContext
        )!

        let recordManagedObject = NSManagedObject(
            entity: entityDescription,
            insertInto: managedObjectContext
        )

        recordManagedObject.setValue(sessionResult.achievedScoreValue, forKey: "scoreValue")
        recordManagedObject.setValue(sessionResult.playedGameCategory.rawValue, forKey: "gameMode")
        recordManagedObject.setValue(sessionResult.completionTimestamp, forKey: "recordDate")
        recordManagedObject.setValue(sessionResult.resultUniqueIdentifier, forKey: "recordIdentifier")

        executeSaveOperation()

        // Update peak duration record if applicable
        persistPeakDurationIfRecord(
            duration: sessionResult.sessionDurationSeconds,
            category: sessionResult.playedGameCategory
        )
    }

    /// Execute Core Data save operation
    private func executeSaveOperation() {
        guard managedObjectContext.hasChanges else { return }

        do {
            try managedObjectContext.save()
        } catch {
            logPersistenceError("Save operation failed", error: error)
        }
    }

    // MARK: - Session Record Retrieval

    /// Retrieve all session records sorted by date (newest first)
    func retrieveAllSessionRecords() -> [SessionResultDataModel] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sessionRecordEntityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "recordDate", ascending: false)
        ]

        do {
            let fetchedObjects = try managedObjectContext.fetch(fetchRequest)
            return fetchedObjects.map { transformManagedObjectToModel($0) }
        } catch {
            logPersistenceError("Fetch all records failed", error: error)
            return []
        }
    }

    /// Retrieve session records filtered by category
    func retrieveSessionRecords(category: GameCategoryDescriptor) -> [SessionResultDataModel] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sessionRecordEntityName)
        fetchRequest.predicate = NSPredicate(format: "gameMode == %@", category.rawValue)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "recordDate", ascending: false)
        ]

        do {
            let fetchedObjects = try managedObjectContext.fetch(fetchRequest)
            return fetchedObjects.map { transformManagedObjectToModel($0) }
        } catch {
            logPersistenceError("Fetch filtered records failed", error: error)
            return []
        }
    }

    /// Retrieve top N session records by score
    func retrieveTopSessionRecords(limit: Int) -> [SessionResultDataModel] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sessionRecordEntityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "scoreValue", ascending: false)
        ]
        fetchRequest.fetchLimit = limit

        do {
            let fetchedObjects = try managedObjectContext.fetch(fetchRequest)
            return fetchedObjects.map { transformManagedObjectToModel($0) }
        } catch {
            logPersistenceError("Fetch top records failed", error: error)
            return []
        }
    }

    /// Transform Core Data managed object to model
    private func transformManagedObjectToModel(_ managedObject: NSManagedObject) -> SessionResultDataModel {
        let identifier = managedObject.value(forKey: "recordIdentifier") as? String ?? UUID().uuidString
        let scoreValue = managedObject.value(forKey: "scoreValue") as? Int ?? 0
        let categoryString = managedObject.value(forKey: "gameMode") as? String ?? ""
        let timestamp = managedObject.value(forKey: "recordDate") as? Date ?? Date()

        let category = GameCategoryDescriptor(rawValue: categoryString) ?? .singleTileMode

        return SessionResultDataModel(
            resultIdentifier: identifier,
            scoreValue: scoreValue,
            gameCategory: category,
            durationSeconds: 0, // Duration not stored in current schema
            completionTime: timestamp
        )
    }

    // MARK: - Session Record Deletion

    /// Delete session record by identifier
    func deleteSessionRecord(identifier: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sessionRecordEntityName)
        fetchRequest.predicate = NSPredicate(format: "recordIdentifier == %@", identifier)

        do {
            let matchingRecords = try managedObjectContext.fetch(fetchRequest)
            matchingRecords.forEach { managedObjectContext.delete($0) }
            executeSaveOperation()
        } catch {
            logPersistenceError("Delete record failed", error: error)
        }
    }

    /// Delete all session records
    func deleteAllSessionRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: sessionRecordEntityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedObjectContext.execute(batchDeleteRequest)
            executeSaveOperation()
        } catch {
            logPersistenceError("Delete all records failed", error: error)
        }
    }

    // MARK: - Peak Duration Management

    /// Persist peak duration if it's a new record
    func persistPeakDurationIfRecord(duration: TimeInterval, category: GameCategoryDescriptor) {
        let storageKey = generateDurationStorageKey(for: category)
        let currentPeakDuration = userDefaultsStorage.double(forKey: storageKey)

        if duration > currentPeakDuration {
            userDefaultsStorage.set(duration, forKey: storageKey)
            userDefaultsStorage.synchronize()
        }
    }

    /// Retrieve peak duration for category
    func retrievePeakDuration(category: GameCategoryDescriptor) -> TimeInterval {
        let storageKey = generateDurationStorageKey(for: category)
        return userDefaultsStorage.double(forKey: storageKey)
    }

    /// Retrieve peak duration across all categories
    func retrieveOverallPeakDuration() -> TimeInterval {
        var maxDuration: TimeInterval = 0

        for category in GameCategoryDescriptor.allCases {
            let categoryDuration = retrievePeakDuration(category: category)
            maxDuration = max(maxDuration, categoryDuration)
        }

        return maxDuration
    }

    /// Generate duration storage key for category
    private func generateDurationStorageKey(for category: GameCategoryDescriptor) -> String {
        return "\(durationRecordKeyPrefix)\(category.rawValue)"
    }

    /// Format duration as display string
    func formatDurationForDisplay(category: GameCategoryDescriptor) -> String {
        let duration = retrievePeakDuration(category: category)

        if duration > 0 {
            let minutesPart = Int(duration) / 60
            let secondsPart = Int(duration) % 60
            return String(format: "%d:%02d", minutesPart, secondsPart)
        }

        return "N/A"
    }

    // MARK: - Statistics Aggregation

    /// Calculate aggregate statistics from all records
    func calculateAggregateStatistics() -> SessionStatisticsSummary {
        let allRecords = retrieveAllSessionRecords()
        return SessionStatisticsSummary(sessions: allRecords)
    }

    /// Get total games played count
    func getTotalGamesPlayedCount() -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sessionRecordEntityName)

        do {
            return try managedObjectContext.count(for: fetchRequest)
        } catch {
            logPersistenceError("Count records failed", error: error)
            return 0
        }
    }

    /// Get highest score achieved
    func getHighestScoreAchieved() -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sessionRecordEntityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "scoreValue", ascending: false)
        ]
        fetchRequest.fetchLimit = 1

        do {
            let topRecords = try managedObjectContext.fetch(fetchRequest)
            return topRecords.first?.value(forKey: "scoreValue") as? Int ?? 0
        } catch {
            logPersistenceError("Get highest score failed", error: error)
            return 0
        }
    }

    // MARK: - Error Logging

    /// Log persistence error
    private func logPersistenceError(_ message: String, error: Error) {
        #if DEBUG
        print("[SessionRecordRepository] \(message): \(error.localizedDescription)")
        #endif
    }
}

// MARK: - Repository Query Builder

/// Query builder for complex repository queries
final class SessionRecordQueryBuilder {

    // MARK: - Properties

    private var categoryFilter: GameCategoryDescriptor?
    private var dateRangeStart: Date?
    private var dateRangeEnd: Date?
    private var minimumScore: Int?
    private var sortDescriptor: NSSortDescriptor?
    private var fetchLimit: Int?

    // MARK: - Builder Methods

    /// Filter by game category
    func filterByCategory(_ category: GameCategoryDescriptor) -> SessionRecordQueryBuilder {
        self.categoryFilter = category
        return self
    }

    /// Filter by date range
    func filterByDateRange(start: Date, end: Date) -> SessionRecordQueryBuilder {
        self.dateRangeStart = start
        self.dateRangeEnd = end
        return self
    }

    /// Filter by minimum score
    func filterByMinimumScore(_ score: Int) -> SessionRecordQueryBuilder {
        self.minimumScore = score
        return self
    }

    /// Sort by score descending
    func sortByScoreDescending() -> SessionRecordQueryBuilder {
        self.sortDescriptor = NSSortDescriptor(key: "scoreValue", ascending: false)
        return self
    }

    /// Sort by date descending
    func sortByDateDescending() -> SessionRecordQueryBuilder {
        self.sortDescriptor = NSSortDescriptor(key: "recordDate", ascending: false)
        return self
    }

    /// Limit results
    func limitResults(_ limit: Int) -> SessionRecordQueryBuilder {
        self.fetchLimit = limit
        return self
    }

    /// Build predicate from filters
    func buildPredicate() -> NSPredicate? {
        var predicates: [NSPredicate] = []

        if let category = categoryFilter {
            predicates.append(NSPredicate(format: "gameMode == %@", category.rawValue))
        }

        if let startDate = dateRangeStart, let endDate = dateRangeEnd {
            predicates.append(NSPredicate(format: "recordDate >= %@ AND recordDate <= %@", startDate as NSDate, endDate as NSDate))
        }

        if let minScore = minimumScore {
            predicates.append(NSPredicate(format: "scoreValue >= %d", minScore))
        }

        guard !predicates.isEmpty else { return nil }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    /// Get sort descriptors
    func getSortDescriptors() -> [NSSortDescriptor] {
        if let sort = sortDescriptor {
            return [sort]
        }
        return [NSSortDescriptor(key: "recordDate", ascending: false)]
    }

    /// Get fetch limit
    func getFetchLimit() -> Int? {
        return fetchLimit
    }

    /// Reset builder state
    func reset() -> SessionRecordQueryBuilder {
        categoryFilter = nil
        dateRangeStart = nil
        dateRangeEnd = nil
        minimumScore = nil
        sortDescriptor = nil
        fetchLimit = nil
        return self
    }
}
