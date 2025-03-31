// ファイル名: ReadingTracker/Models/Book.swift
import Foundation
import CoreData

class Book: NSManagedObject, Identifiable {
    @NSManaged var id: UUID?
    @NSManaged var title: String?
    @NSManaged var author: String?
    @NSManaged var coverImageName: String?
    @NSManaged var totalPages: Int32
    @NSManaged var currentPage: Int32
    @NSManaged var status: Int16
    @NSManaged var startDate: Date?
    @NSManaged var finishDate: Date?
    @NSManaged var addedDate: Date?
    @NSManaged var sessions: NSSet?
    @NSManaged var notes: NSSet?
}

// MARK: - フェッチリクエスト
extension Book {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
}

// MARK: - Session関連のアクセサ
extension Book {
    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: ReadingSession)
    
    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: ReadingSession)
    
    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)
    
    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)
}

// MARK: - Notes関連のアクセサ
extension Book {
    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)
    
    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)
    
    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)
    
    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)
}
