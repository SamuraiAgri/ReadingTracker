// ファイル名: ReadingTracker/Views/BookDetailView.swift

import SwiftUI

struct BookDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var viewModel: BookDetailViewModel
    
    @State private var showingReadingSessionSheet = false
    @State private var showingNoteSheet = false
    @State private var showingStatusActionSheet = false
    @State private var showingProgressUpdateSheet = false
    
    init(book: Book) {
        self.viewModel = BookDetailViewModel(book: book, viewContext: book.managedObjectContext!)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ヘッダー部分（基本情報）
                bookHeaderView
                
                Divider()
                
                // 読書進捗セクション（読書記録機能を統合）
                readingProgressSection
                
                Divider()
                
                // メモセクション
                notesSection
            }
            .padding()
        }
        .navigationTitle("本の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingStatusActionSheet = true
                }) {
                    Text(viewModel.statusText)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(viewModel.statusColor.opacity(0.2))
                        )
                        .foregroundColor(viewModel.statusColor)
                }
            }
        }
        .confirmationDialog("読書状態を変更", isPresented: $showingStatusActionSheet, titleVisibility: .visible) {
            Button("積読") {
                viewModel.updateStatus(newStatus: .unread)
            }
            
            Button("読書中") {
                viewModel.updateStatus(newStatus: .reading)
            }
            
            Button("読了") {
                viewModel.updateStatus(newStatus: .finished)
            }
            
            Button("キャンセル", role: .cancel) { }
        }
        .sheet(isPresented: $showingReadingSessionSheet) {
            AddReadingSessionView(viewModel: viewModel, isPresented: $showingReadingSessionSheet)
        }
        .sheet(isPresented: $showingNoteSheet) {
            AddNoteView(viewModel: viewModel, isPresented: $showingNoteSheet)
        }
        .sheet(isPresented: $showingProgressUpdateSheet) {
            UpdateProgressView(viewModel: viewModel, isPresented: $showingProgressUpdateSheet)
        }
    }
    
    private var bookHeaderView: some View {
        HStack(alignment: .top, spacing: 16) {
            // 本の基本情報
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.book.title ?? "不明なタイトル")
                    .font(AppConstants.Fonts.title)
                    .lineLimit(3)
                
                Text(viewModel.book.author ?? "不明な著者")
                    .font(AppConstants.Fonts.body)
                    .foregroundColor(.secondary)
                
                if let startDate = viewModel.book.startDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        
                        Text("開始: \(formatDate(startDate))")
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let finishDate = viewModel.book.finishDate {
                    HStack {
                        Image(systemName: "flag")
                            .foregroundColor(.secondary)
                        
                        Text("完了: \(formatDate(finishDate))")
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !viewModel.readingSessions.isEmpty {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        
                        Text("総読書時間: \(viewModel.formattedTotalReadingTime)")
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var readingProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("読書進捗")
                    .font(AppConstants.Fonts.headline)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        showingReadingSessionSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("記録")
                        }
                        .font(AppConstants.Fonts.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.primary.opacity(0.1))
                        )
                    }
                    
                    Button(action: {
                        showingProgressUpdateSheet = true
                    }) {
                        Text("更新")
                            .font(AppConstants.Fonts.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.primary.opacity(0.1))
                        )
                    }
                }
            }
            
            // 進捗バー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景バー
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    // 進捗バー
                    RoundedRectangle(cornerRadius: 6)
                        .fill(viewModel.statusColor)
                        .frame(width: max(0, min(CGFloat(viewModel.progress) * geometry.size.width, geometry.size.width)), height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(viewModel.currentPage)/\(Int(viewModel.book.totalPages))ページ")
                
                Spacer()
                
                Text(viewModel.formattedProgress)
                    .foregroundColor(viewModel.statusColor)
                    .fontWeight(.bold)
            }
            .font(AppConstants.Fonts.caption)
            
            // 読書記録の表示
            if !viewModel.readingSessions.isEmpty {
                Text("読書記録")
                    .font(AppConstants.Fonts.headline)
                    .padding(.top, 12)
                
                ForEach(viewModel.readingSessions.prefix(3)) { session in
                    ReadingSessionRow(session: session)
                }
                
                if viewModel.readingSessions.count > 3 {
                    Button(action: {
                        // すべての読書記録を表示する詳細ビューへ
                    }) {
                        Text("すべての記録を表示")
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("メモ")
                    .font(AppConstants.Fonts.headline)
                
                Spacer()
                
                Button(action: {
                    showingNoteSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("メモ")
                    }
                    .font(AppConstants.Fonts.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                    )
                }
            }
            
            if viewModel.notes.isEmpty {
                Text("メモがありません")
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.notes) { note in
                    NoteRow(note: note, onDelete: {
                        viewModel.deleteNote(note)
                    })
                }
            }
        }
    }
        private func formatDate(_ date: Date) -> String {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        }

        // 読書セッション行コンポーネント
        struct ReadingSessionRow: View {
            let session: ReadingSession
            
            var body: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(session.date ?? Date()))
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(session.startPage))ページ → \(Int(session.endPage))ページ")
                            .font(AppConstants.Fonts.body)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(session.endPage - session.startPage))ページ")
                            .font(AppConstants.Fonts.body)
                            .foregroundColor(.primary)
                        
                        Text("\(Int(session.duration))分")
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            private func formatDate(_ date: Date) -> String {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        }

        // メモ行コンポーネント
        struct NoteRow: View {
            let note: Note
            let onDelete: () -> Void
            
            @State private var showingDeleteAlert = false
            
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("P.\(note.pageNumber)")
                            .font(AppConstants.Fonts.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.secondary.opacity(0.2))
                            )
                        
                        Spacer()
                        
                        Text(formatDate(note.createdAt ?? Date()))
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    Text(note.content ?? "")
                        .font(AppConstants.Fonts.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .alert("メモを削除", isPresented: $showingDeleteAlert) {
                    Button("キャンセル", role: .cancel) { }
                    Button("削除", role: .destructive) {
                        onDelete()
                    }
                } message: {
                    Text("このメモを削除しますか？")
                }
            }
            
            private func formatDate(_ date: Date) -> String {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
        }

        // 読書セッション追加ビュー
        struct AddReadingSessionView: View {
            @ObservedObject var viewModel: BookDetailViewModel
            @Binding var isPresented: Bool
            
            @State private var startPage: String = ""
            @State private var endPage: String = ""
            @State private var duration: String = ""
            
            var body: some View {
                NavigationView {
                    Form {
                        Section(header: Text("読書記録")) {
                            TextField("開始ページ", text: $startPage)
                                .keyboardType(.numberPad)
                            
                            TextField("終了ページ", text: $endPage)
                                .keyboardType(.numberPad)
                            
                            TextField("読書時間（分）", text: $duration)
                                .keyboardType(.numberPad)
                        }
                        
                        Section {
                            Button("読書記録を追加") {
                                guard let start = Int(startPage),
                                      let end = Int(endPage),
                                      let time = Double(duration),
                                      start >= 0,
                                      end > start,
                                      end <= viewModel.book.totalPages,
                                      time > 0 else {
                                    return
                                }
                                
                                viewModel.addReadingSession(startPage: start, endPage: end, duration: time)
                                isPresented = false
                            }
                            .disabled(startPage.isEmpty || endPage.isEmpty || duration.isEmpty)
                        }
                    }
                    .navigationTitle("読書記録を追加")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("キャンセル") {
                                isPresented = false
                            }
                        }
                    }
                    .onAppear {
                        // 初期値を設定
                        startPage = "\(viewModel.currentPage)"
                        endPage = ""
                        duration = "30"
                    }
                }
            }
        }

        // メモ追加ビュー
        struct AddNoteView: View {
            @ObservedObject var viewModel: BookDetailViewModel
            @Binding var isPresented: Bool
            
            @State private var content: String = ""
            @State private var pageNumber: String = ""
            
            var body: some View {
                NavigationView {
                    Form {
                        Section(header: Text("メモ内容")) {
                            TextField("ページ番号", text: $pageNumber)
                                .keyboardType(.numberPad)
                            
                            TextEditor(text: $content)
                                .frame(minHeight: 150)
                        }
                        
                        Section {
                            Button("メモを追加") {
                                guard let page = Int(pageNumber),
                                      !content.isEmpty,
                                      page >= 0,
                                      page <= viewModel.book.totalPages else {
                                    return
                                }
                                
                                viewModel.addNote(content: content, pageNumber: page)
                                isPresented = false
                            }
                            .disabled(pageNumber.isEmpty || content.isEmpty)
                        }
                    }
                    .navigationTitle("メモを追加")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("キャンセル") {
                                isPresented = false
                            }
                        }
                    }
                    .onAppear {
                        // 初期値を設定
                        pageNumber = "\(viewModel.currentPage)"
                    }
                }
            }
        }

        // 進捗更新ビュー
        struct UpdateProgressView: View {
            @ObservedObject var viewModel: BookDetailViewModel
            @Binding var isPresented: Bool
            
            @State private var currentPage: String = ""
            
            var body: some View {
                NavigationView {
                    Form {
                        Section(header: Text("現在の読書位置")) {
                            TextField("現在のページ", text: $currentPage)
                                .keyboardType(.numberPad)
                            
                            Text("総ページ数: \(Int(viewModel.book.totalPages))ページ")
                                .foregroundColor(.secondary)
                        }
                        
                        Section {
                            Button("進捗を更新") {
                                guard let page = Int(currentPage),
                                      page >= 0,
                                      page <= viewModel.book.totalPages else {
                                    return
                                }
                                
                                viewModel.updateReadingProgress(newPage: page)
                                isPresented = false
                            }
                            .disabled(currentPage.isEmpty)
                        }
                    }
                    .navigationTitle("進捗を更新")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("キャンセル") {
                                isPresented = false
                            }
                        }
                    }
                    .onAppear {
                        // 初期値を設定
                        currentPage = "\(viewModel.currentPage)"
                    }
                }
            }
        }
