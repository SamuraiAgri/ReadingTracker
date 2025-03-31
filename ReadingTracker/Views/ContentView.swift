// ファイル名: ReadingTracker/Views/ContentView.swift

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var bookListViewModel: BookListViewModel
    
    init(viewContext: NSManagedObjectContext) {
        _bookListViewModel = StateObject(wrappedValue: BookListViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        TabView {
            BookListView(viewModel: bookListViewModel)
                .tabItem {
                    Label("本棚", systemImage: "books.vertical")
                }
            
            StatisticsView(viewContext: viewContext)
                .tabItem {
                    Label("統計", systemImage: "chart.bar")
                }
            
            ReminderView(viewContext: viewContext)
                .tabItem {
                    Label("リマインダー", systemImage: "bell")
                }
        }
    }
}
