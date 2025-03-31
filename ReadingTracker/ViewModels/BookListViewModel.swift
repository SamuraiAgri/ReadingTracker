// ファイル名: ReadingTracker/ViewModels/BookListViewModel.swift
import Foundation
import Combine
import CoreData
import SwiftUI

class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var filteredBooks: [Book] = []
    @Published var selectedStatus: AppConstants.ReadingStatus?
    @Published var searchText: String = ""
    
    private let bookModel: BookModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.bookModel = BookModel(viewContext: viewContext)
        
        // 検索テキストとステータスフィルターの変更を監視
        Publishers.CombineLatest($searchText, $selectedStatus)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, status) in
                self?.filterBooks(searchText: searchText, status: status)
            }
            .store(in: &cancellables)
    }
    
    func fetchBooks() {
        books = bookModel.fetchBooks()
        filterBooks(searchText: searchText, status: selectedStatus)
    }
    
    func addBook(title: String, author: String, coverImageName: String, totalPages: Int) {
        _ = bookModel.addBook(title: title, author: author, coverImageName: coverImageName, totalPages: totalPages)
        fetchBooks()
    }
    
    func updateBookStatus(book: Book, newStatus: AppConstants.ReadingStatus) {
        bookModel.updateBookStatus(book: book, newStatus: newStatus)
        fetchBooks()
    }
    
    func deleteBook(_ book: Book) {
        bookModel.deleteBook(book)
        fetchBooks()
    }
    
    private func filterBooks(searchText: String, status: AppConstants.ReadingStatus?) {
        if searchText.isEmpty && status == nil {
            // フィルタなし
            filteredBooks = books
        } else if !searchText.isEmpty && status == nil {
            // 検索テキストのみでフィルタ
            filteredBooks = bookModel.searchBooks(byText: searchText)
        } else if searchText.isEmpty && status != nil {
            // ステータスのみでフィルタ
            filteredBooks = bookModel.fetchBooks(withStatus: status)
        } else {
            // 検索テキストとステータスの両方でフィルタ
            let statusFilteredBooks = bookModel.fetchBooks(withStatus: status)
            filteredBooks = statusFilteredBooks.filter {
                $0.title?.localizedCaseInsensitiveContains(searchText) ?? false ||
                $0.author?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}
