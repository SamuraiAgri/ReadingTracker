// ファイル名: ReadingTracker/Views/StatisticsView.swift
import SwiftUI
import CoreData
import Charts

class StatisticsViewModel: ObservableObject {
    @Published var monthlyBookCount: [(month: Date, count: Int)] = []
    @Published var monthlyPageCount: [(month: Date, pages: Int)] = []
    @Published var totalBooks: Int = 0
    @Published var totalFinishedBooks: Int = 0
    @Published var totalReadingBooks: Int = 0
    @Published var totalPages: Int = 0
    @Published var totalReadPages: Int = 0
    
    private let bookModel: BookModel
    
    init(viewContext: NSManagedObjectContext) {
        self.bookModel = BookModel(viewContext: viewContext)
        fetchStatistics()
    }
    
    func fetchStatistics() {
        // 月別統計
        monthlyBookCount = bookModel.fetchMonthlyCompletedBooks()
        monthlyPageCount = bookModel.fetchMonthlyReadPages()
        
        // 総冊数と総ページ数
        let allBooks = bookModel.fetchBooks()
        
        totalBooks = allBooks.count
        totalFinishedBooks = allBooks.filter { $0.status == AppConstants.ReadingStatus.finished.rawValue }.count
        totalReadingBooks = allBooks.filter { $0.status == AppConstants.ReadingStatus.reading.rawValue }.count
        
        totalPages = allBooks.reduce(0) { $0 + Int($1.totalPages) }
        totalReadPages = allBooks.reduce(0) { $0 + min(Int($1.currentPage), Int($1.totalPages)) }
    }
    
    // グラフ表示用の整形されたデータ
    var formattedMonthlyBookData: [(month: String, count: Int)] {
        return monthlyBookCount.map { (formatMonth($0.month), $0.count) }
    }
    
    var formattedMonthlyPageData: [(month: String, pages: Int)] {
        return monthlyPageCount.map { (formatMonth($0.month), $0.pages) }
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: date)
    }
    
    // 棒グラフの最大値（グラフスケール用）
    var maxBookCount: Int {
        return monthlyBookCount.map { $0.count }.max() ?? 5
    }
    
    var maxPageCount: Int {
        return monthlyPageCount.map { $0.pages }.max() ?? 500
    }
    
    // 読書完了率
    var completionRateText: String {
        if totalBooks == 0 {
            return "0%"
        }
        let rate = Double(totalFinishedBooks) / Double(totalBooks) * 100
        return String(format: "%.1f%%", rate)
    }
    
    // 読書進捗率
    var overallProgressText: String {
        if totalPages == 0 {
            return "0%"
        }
        let rate = Double(totalReadPages) / Double(totalPages) * 100
        return String(format: "%.1f%%", rate)
    }
}
