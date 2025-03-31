// ファイル名: ReadingTracker/Models/BookModel.swift

import Foundation
import CoreData
import Combine

class BookModel {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func fetchBooks(withStatus status: AppConstants.ReadingStatus? = nil) -> [Book] {
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        
        // ソート条件（デフォルトは追加日の新しい順）
        let sortDescriptor = NSSortDescriptor(key: "addedDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        // ステータスフィルタが指定されている場合、条件を追加
        if let status = status {
            request.predicate = NSPredicate(format: "status == %d", status.rawValue)
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("本の取得に失敗しました: \(error)")
            return []
        }
    }
    
    func searchBooks(byText searchText: String) -> [Book] {
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        
        // 検索条件（タイトルまたは著者名に部分一致）
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR author CONTAINS[cd] %@", searchText, searchText)
        request.predicate = predicate
        
        // ソート条件
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("本の検索に失敗しました: \(error)")
            return []
        }
    }
    
    func addBook(title: String, author: String, coverImageName: String, totalPages: Int) -> Book {
        let newBook = Book(context: viewContext)
        newBook.id = UUID()
        newBook.title = title
        newBook.author = author
        newBook.coverImageName = coverImageName
        newBook.totalPages = Int32(totalPages)
        newBook.currentPage = 0
        newBook.status = AppConstants.ReadingStatus.unread.rawValue
        newBook.addedDate = Date()
        
        saveContext()
        return newBook
    }
    
    func updateBookStatus(book: Book, newStatus: AppConstants.ReadingStatus) {
        // 以前のステータス
        let oldStatus = AppConstants.ReadingStatus(rawValue: book.status) ?? .unread
        
        // 現在のページ位置によって、自動的にステータスを変更する場合もある
        book.status = newStatus.rawValue
        
        // ステータスが変更された場合の追加処理
        if oldStatus != newStatus {
            switch newStatus {
            case .reading:
                // 未読→読書中になった場合、開始日を設定
                if book.startDate == nil {
                    book.startDate = Date()
                }
                
            case .finished:
                // 読了になった場合、完了日を設定し、現在のページを全ページ数に設定
                book.finishDate = Date()
                book.currentPage = book.totalPages
                
            case .unread:
                // 未読に戻す場合、日付とページ位置をリセット
                book.startDate = nil
                book.finishDate = nil
                book.currentPage = 0
            }
        }
        
        saveContext()
    }
    
    func updateReadingProgress(book: Book, currentPage: Int) {
        book.currentPage = Int32(currentPage)
        
        // 進捗に応じてステータスを自動更新
        if currentPage > 0 && currentPage < book.totalPages {
            // 読書中になった場合、開始日を設定
            if book.status == AppConstants.ReadingStatus.unread.rawValue {
                book.status = AppConstants.ReadingStatus.reading.rawValue
                if book.startDate == nil {
                    book.startDate = Date()
                }
            }
        } else if currentPage >= book.totalPages {
            // 最後まで読んだ場合、読了ステータスに変更
            book.status = AppConstants.ReadingStatus.finished.rawValue
            book.finishDate = Date()
        }
        
        saveContext()
    }
    
    func addReadingSession(book: Book, startPage: Int, endPage: Int, duration: Double) -> ReadingSession {
        let session = ReadingSession(context: viewContext)
        session.id = UUID()
        session.date = Date()
        session.startPage = Int32(startPage)
        session.endPage = Int32(endPage)
        session.duration = duration
        session.book = book
        
        // 本の現在のページを更新
        if Int(book.currentPage) < endPage {
            book.currentPage = Int32(endPage)
            
            // 進捗に応じてステータスを自動更新
            if endPage >= book.totalPages {
                book.status = AppConstants.ReadingStatus.finished.rawValue
                book.finishDate = Date()
            } else if book.status == AppConstants.ReadingStatus.unread.rawValue {
                book.status = AppConstants.ReadingStatus.reading.rawValue
                if book.startDate == nil {
                    book.startDate = Date()
                }
            }
        }
        
        saveContext()
        return session
    }
    
    func addNote(to book: Book, content: String, pageNumber: Int) -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.content = content
        note.pageNumber = Int32(pageNumber)
        note.createdAt = Date()
        note.book = book
        
        saveContext()
        return note
    }
    
    func deleteBook(_ book: Book) {
        // 関連するセッションとメモを削除
        if let sessions = book.sessions as? Set<ReadingSession> {
            for session in sessions {
                viewContext.delete(session)
            }
        }
        
        if let notes = book.notes as? Set<Note> {
            for note in notes {
                viewContext.delete(note)
            }
        }
        
        viewContext.delete(book)
        saveContext()
    }
    
    func fetchReadingSessions(for book: Book) -> [ReadingSession] {
        let request: NSFetchRequest<ReadingSession> = ReadingSession.fetchRequest()
        request.predicate = NSPredicate(format: "book == %@", book)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("読書セッションの取得に失敗しました: \(error)")
            return []
        }
    }
    
    func fetchNotes(for book: Book) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "book == %@", book)
        request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("メモの取得に失敗しました: \(error)")
            return []
        }
    }
    
    // 月別の読了冊数統計
    func fetchMonthlyCompletedBooks() -> [(month: Date, count: Int)] {
        let calendar = Calendar.current
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "status == %d AND finishDate >= %@",
                                       AppConstants.ReadingStatus.finished.rawValue, oneYearAgo as NSDate)
        
        do {
            let finishedBooks = try viewContext.fetch(request)
            
            // 月ごとにグループ化
            var monthlyData: [Date: Int] = [:]
            
            for book in finishedBooks {
                if let finishDate = book.finishDate {
                    // 月の始めの日付を取得
                    let components = calendar.dateComponents([.year, .month], from: finishDate)
                    if let monthStart = calendar.date(from: components) {
                        monthlyData[monthStart, default: 0] += 1
                    }
                }
            }
            
            // ソートして配列に変換
            let sortedData = monthlyData.sorted { $0.key < $1.key }
            return sortedData.map { (month: $0.key, count: $0.value) }
            
        } catch {
            print("月別読了統計の取得に失敗しました: \(error)")
            return []
        }
    }
    
    // 月別の読書ページ数統計
    func fetchMonthlyReadPages() -> [(month: Date, pages: Int)] {
        let calendar = Calendar.current
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        
        let request: NSFetchRequest<ReadingSession> = ReadingSession.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", oneYearAgo as NSDate)
        
        do {
            let sessions = try viewContext.fetch(request)
            
            // 月ごとにグループ化
            var monthlyData: [Date: Int] = [:]
            
            for session in sessions {
                let date = session.date ?? Date()
                // 月の始めの日付を取得
                let components = calendar.dateComponents([.year, .month], from: date)
                if let monthStart = calendar.date(from: components) {
                    let pagesRead = Int(session.endPage - session.startPage)
                    monthlyData[monthStart, default: 0] += pagesRead
                }
            }
            
            // ソートして配列に変換
            let sortedData = monthlyData.sorted { $0.key < $1.key }
            return sortedData.map { (month: $0.key, pages: $0.value) }
            
        } catch {
            print("月別読書ページ数統計の取得に失敗しました: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("コンテキストの保存に失敗しました: \(error)")
            }
        }
    }
}
