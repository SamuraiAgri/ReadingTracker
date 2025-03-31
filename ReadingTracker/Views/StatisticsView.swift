// ファイル名: ReadingTracker/Views/StatisticsView.swift

import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: StatisticsViewModel
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // サマリーカード
                    summaryCards
                    
                    // 月別読了冊数グラフ
                    monthlyBooksChart
                    
                    // 月別読書ページ数グラフ
                    monthlyPagesChart
                }
                .padding()
            }
            .navigationTitle("読書統計")
            .onAppear {
                viewModel.fetchStatistics()
            }
        }
    }
    
    private var summaryCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "合計本数",
                    value: "\(viewModel.totalBooks)冊",
                    icon: "books.vertical",
                    color: .primary
                )
                
                StatCard(
                    title: "読了率",
                    value: viewModel.completionRateText,
                    icon: "checkmark.circle",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "読書中",
                    value: "\(viewModel.totalReadingBooks)冊",
                    icon: "book.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "読了",
                    value: "\(viewModel.totalFinishedBooks)冊",
                    icon: "flag.fill",
                    color: .red
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "総ページ数",
                    value: "\(viewModel.totalPages)ページ",
                    icon: "doc.text",
                    color: .purple
                )
                
                StatCard(
                    title: "進捗",
                    value: viewModel.overallProgressText,
                    icon: "chart.bar.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var monthlyBooksChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月別読了冊数")
                .font(AppConstants.Fonts.headline)
            
            if viewModel.monthlyBookCount.isEmpty {
                Text("データがありません")
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart {
                    ForEach(viewModel.formattedMonthlyBookData, id: \.month) { item in
                        BarMark(
                            x: .value("月", item.month),
                            y: .value("冊数", item.count)
                        )
                        .foregroundStyle(Color.chartPrimary.gradient)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...(viewModel.maxBookCount + 1))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var monthlyPagesChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月別読書ページ数")
                .font(AppConstants.Fonts.headline)
            
            if viewModel.monthlyPageCount.isEmpty {
                Text("データがありません")
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart {
                    ForEach(viewModel.formattedMonthlyPageData, id: \.month) { item in
                        BarMark(
                            x: .value("月", item.month),
                            y: .value("ページ数", item.pages)
                        )
                        .foregroundStyle(Color.chartSecondary.gradient)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...(viewModel.maxPageCount + 100))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 統計カードコンポーネント
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(AppConstants.Fonts.title)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
