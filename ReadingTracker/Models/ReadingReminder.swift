// ファイル名: ReadingTracker/Models/ReadingReminder.swift
import Foundation
import CoreData

class ReadingReminder: NSManagedObject, Identifiable {
    @NSManaged var id: UUID?
    @NSManaged var time: Date?
    @NSManaged var isEnabled: Bool
    @NSManaged var daysOfWeek: String?
}

// MARK: - フェッチリクエスト
extension ReadingReminder {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadingReminder> {
        return NSFetchRequest<ReadingReminder>(entityName: "ReadingReminder")
    }
}
