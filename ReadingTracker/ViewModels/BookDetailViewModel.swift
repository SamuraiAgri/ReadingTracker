// ファイル名: ReadingTracker/ViewModels/BookDetailViewModel.swift
import Foundation
import Combine
import CoreData
import SwiftUI

class BookDetailViewModel: ObservableObject {
    @Published var book: Book
    @Published var readingSessions: [ReadingSession] = []
    @Published var notes: [Note] = []
    @Published var currentPage: Int
    @Published var progress: Double = 0.0
    
    private let bookModel: BookModel
    
    init(book: Book, viewContext: NSManagedObjectContext) {
        self.book = book
        self.bookModel = BookModel(viewContext: viewContext)
        self.currentPage = Int(book.currentPage)
        
        // 進捗率を計算
        if book.totalPages > 0 {
            self.progress = Double(book.currentPage) / Double(book.totalPages)
        }
        
        fetchReadingSessions()
        fetchNotes()
    }
    
    func fetchReadingSessions() {
        readingSessions = bookModel.fetchReadingSessions(for: book)
    }
    
    func fetchNotes() {
        notes = bookModel.fetchNotes(for: book)
    }
    
    func updateReadingProgress(newPage: Int) {
        // 不正な値をチェック
        guard newPage >= 0 && newPage <= book.totalPages else { return }
        
        bookModel.updateReadingProgress(book: book, currentPage: newPage)
        self.currentPage = newPage
        
        // 進捗率を更新
        if book.totalPages > 0 {
            self.progress = Double(newPage) / Double(book.totalPages)
        }
    }
    
    func addReadingSession(startPage: Int, endPage: Int, duration: Double) {
        guard startPage >= 0 && endPage <= book.totalPages && endPage > startPage else { return }
        
        _ = bookModel.addReadingSession(book: book, startPage: startPage, endPage: endPage, duration: duration)
        fetchReadingSessions()
        
        // ページ位置が進んだ場合は現在のページも更新
        if endPage > currentPage {
            currentPage = endPage
            if book.totalPages > 0 {
                progress = Double(currentPage) / Double(book.totalPages)
            }
        }
    }
    
    func addNote(content: String, pageNumber: Int) {
        guard pageNumber >= 0 && pageNumber <= book.totalPages else { return }
        
        _ = bookModel.addNote(to: book, content: content, pageNumber: pageNumber)
        fetchNotes()
    }
    
    func deleteNote(_ note: Note) {
        guard let viewContext = note.managedObjectContext else { return }
        
        viewContext.delete(note)
        
        do {
            try viewContext.save()
            fetchNotes()
        } catch {
            print("メモの削除に失敗しました: \(error)")
        }
    }
    
    func updateStatus(newStatus: AppConstants.ReadingStatus) {
        bookModel.updateBookStatus(book: book, newStatus: newStatus)
    }
    
    var statusText: String {
        return AppConstants.ReadingStatus(rawValue: book.status)?.displayName ?? "不明"
    }
    
    var statusColor: Color {
        return AppConstants.ReadingStatus(rawValue: book.status)?.color ?? .gray
    }
    
    var formattedProgress: String {
        return String(format: "%.1f%%", progress * 100)
    }
    
    var totalReadingTime: Double {
        return readingSessions.reduce(0) { $0 + $1.duration }
    }
    
    var formattedTotalReadingTime: String {
        let hours = Int(totalReadingTime) / 60
        let minutes = Int(totalReadingTime) % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}
