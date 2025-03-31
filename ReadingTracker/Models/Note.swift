// ファイル名: ReadingTracker/Models/Note.swift
import Foundation
import CoreData

class Note: NSManagedObject, Identifiable {
    @NSManaged var id: UUID?
    @NSManaged var content: String?
    @NSManaged var pageNumber: Int32
    @NSManaged var createdAt: Date?
    @NSManaged var book: Book?
}

// MARK: - フェッチリクエスト
extension Note {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }
}
