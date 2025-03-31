// ファイル名: ReadingTracker/Models/ReadingSession.swift
import Foundation
import CoreData

class ReadingSession: NSManagedObject, Identifiable {
    @NSManaged var id: UUID?
    @NSManaged var date: Date?
    @NSManaged var startPage: Int32
    @NSManaged var endPage: Int32
    @NSManaged var duration: Double
    @NSManaged var book: Book?
}

// MARK: - フェッチリクエスト
extension ReadingSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadingSession> {
        return NSFetchRequest<ReadingSession>(entityName: "ReadingSession")
    }
}
