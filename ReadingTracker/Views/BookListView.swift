// ファイル名: ReadingTracker/Views/BookListView.swift

import SwiftUI

struct BookListView: View {
    @ObservedObject var viewModel: BookListViewModel
    @State private var showingAddBookSheet = false
    @State private var showingFilterOptions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                searchBar
                
                // フィルターバー
                filterBar
                
                // ブックリスト
                if viewModel.filteredBooks.isEmpty {
                    emptyStateView
                } else {
                    bookListContent
                }
            }
            .navigationTitle("マイ本棚")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBookSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBookSheet) {
                AddBookView(isPresented: $showingAddBookSheet, onAdd: { title, author, coverImageName, totalPages in
                    viewModel.addBook(title: title, author: author, coverImageName: coverImageName, totalPages: totalPages)
                })
            }
            .onAppear {
                viewModel.fetchBooks()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("タイトルまたは著者で検索", text: $viewModel.searchText)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(AppConstants.UI.smallPadding)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(title: "すべて", isSelected: viewModel.selectedStatus == nil) {
                    viewModel.selectedStatus = nil
                }
                
                ForEach(AppConstants.ReadingStatus.allCases) { status in
                    FilterButton(
                        title: status.displayName,
                        isSelected: viewModel.selectedStatus == status,
                        color: status.color
                    ) {
                        viewModel.selectedStatus = status
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    private var bookListContent: some View {
        List {
            ForEach(viewModel.filteredBooks) { book in
                NavigationLink(destination: BookDetailView(book: book)) {
                    BookRowView(book: book)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteBook(book)
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        let currentStatus = AppConstants.ReadingStatus(rawValue: book.status) ?? .unread
                        let newStatus: AppConstants.ReadingStatus
                        
                        switch currentStatus {
                        case .unread:
                            newStatus = .reading
                        case .reading:
                            newStatus = .finished
                        case .finished:
                            newStatus = .unread
                        }
                        
                        viewModel.updateBookStatus(book: book, newStatus: newStatus)
                    } label: {
                        Label("状態変更", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .tint(AppConstants.ReadingStatus(rawValue: book.status)?.color ?? .gray)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("本がありません")
                .font(AppConstants.Fonts.headline)
                .foregroundColor(.gray)
            
            if viewModel.selectedStatus != nil || !viewModel.searchText.isEmpty {
                Text("フィルターを解除するか、別の検索条件をお試しください")
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Button(action: {
                    showingAddBookSheet = true
                }) {
                    Text("本を追加する")
                        .primaryButtonStyle()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// フィルターボタンコンポーネント
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(isSelected ? .bold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? color.opacity(0.2) : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? color : .primary)
        }
    }
}

// 本の行表示コンポーネント
struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            // 本の表紙イメージ
            Image(book.coverImageName ?? "default_book_cover")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 85)
                .cornerRadius(6)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title ?? "不明なタイトル")
                    .font(AppConstants.Fonts.headline)
                    .lineLimit(2)
                
                Text(book.author ?? "不明な著者")
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack {
                    // ステータスバッジ
                    StatusBadge(status: AppConstants.ReadingStatus(rawValue: book.status) ?? .unread)
                    
                    Spacer()
                    
                    // 進捗インジケータ（読書中のみ表示）
                    if book.status == AppConstants.ReadingStatus.reading.rawValue {
                        ProgressView(value: Double(book.currentPage) / Double(book.totalPages))
                            .frame(width: 80)
                        
                        Text("\(Int(book.currentPage))/\(Int(book.totalPages))")
                            .font(.system(.caption2))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// ステータスバッジコンポーネント
struct StatusBadge: View {
    let status: AppConstants.ReadingStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.system(.caption2, design: .rounded).weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(status.color.opacity(0.2))
            )
            .foregroundColor(status.color)
    }
}

// 本の追加ビュー
struct AddBookView: View {
    @Binding var isPresented: Bool
    let onAdd: (String, String, String, Int) -> Void
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var totalPages: String = ""
    @State private var selectedCoverImageName: String = "default_book_cover"
    @State private var showingImagePicker = false
    
    // サンプルのカバー画像セット
    let coverImages = ["book_cover_1", "book_cover_2", "book_cover_3", "book_cover_4", "book_cover_5", "default_book_cover"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("タイトル", text: $title)
                    TextField("著者", text: $author)
                    TextField("総ページ数", text: $totalPages)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("表紙画像")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(coverImages, id: \.self) { imageName in
                                CoverImageOption(
                                    imageName: imageName,
                                    isSelected: selectedCoverImageName == imageName
                                ) {
                                    selectedCoverImageName = imageName
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("本を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        guard !title.isEmpty, !author.isEmpty, let pages = Int(totalPages), pages > 0 else {
                            return
                        }
                        
                        onAdd(title, author, selectedCoverImageName, pages)
                        isPresented = false
                    }
                    .disabled(title.isEmpty || author.isEmpty || totalPages.isEmpty)
                }
            }
        }
    }
}

// 表紙画像オプションコンポーネント
struct CoverImageOption: View {
    let imageName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
            )
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(6)
                    .opacity(isSelected ? 1 : 0),
                alignment: .bottomTrailing
            )
            .shadow(radius: 2)
            .padding(4)
            .onTapGesture {
                onTap()
            }
    }
}
