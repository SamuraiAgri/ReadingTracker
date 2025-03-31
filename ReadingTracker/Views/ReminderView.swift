// ファイル名: ReadingTracker/Views/ReminderView.swift
import CoreData
import SwiftUI

struct ReminderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ReminderViewModel
    
    @State private var showingAddReminderSheet = false
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ReminderViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.reminders.isEmpty {
                    Text("リマインダーが設定されていません")
                        .font(AppConstants.Fonts.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .padding()
                } else {
                    ForEach(viewModel.reminders) { reminder in
                        ReminderRow(
                            reminder: reminder,
                            timeString: viewModel.timeString(for: reminder),
                            weekdayNames: viewModel.weekdayNames(for: reminder),
                            onToggle: {
                                viewModel.toggleReminder(reminder)
                            }
                        )
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteReminder(reminder)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("リマインダー")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminderSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminderSheet) {
                AddReminderView(viewModel: viewModel, isPresented: $showingAddReminderSheet)
            }
            .onAppear {
                viewModel.fetchReminders()
            }
        }
    }
}

// リマインダー行コンポーネント
struct ReminderRow: View {
    let reminder: ReadingReminder
    let timeString: String
    let weekdayNames: String
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(timeString)
                    .font(AppConstants.Fonts.headline)
                
                Text(weekdayNames)
                    .font(AppConstants.Fonts.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

// リマインダー追加ビュー
struct AddReminderView: View {
    @ObservedObject var viewModel: ReminderViewModel
    @Binding var isPresented: Bool
    
    @State private var time = Date()
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6] // 月〜金を初期選択
    
    let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("時間")) {
                    DatePicker("通知時間", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                Section(header: Text("曜日")) {
                    HStack {
                        ForEach(1...7, id: \.self) { day in
                            WeekdayButton(
                                day: weekdays[day - 1],
                                isSelected: selectedDays.contains(day),
                                action: {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        Button("平日") {
                            selectedDays = [2, 3, 4, 5, 6]
                        }
                        
                        Spacer()
                        
                        Button("週末") {
                            selectedDays = [1, 7]
                        }
                        
                        Spacer()
                        
                        Button("毎日") {
                            selectedDays = Set(1...7)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button("リマインダーを追加") {
                        guard !selectedDays.isEmpty else { return }
                        
                        viewModel.addReminder(time: time, daysOfWeek: Array(selectedDays))
                        isPresented = false
                    }
                    .disabled(selectedDays.isEmpty)
                }
            }
            .navigationTitle("リマインダーを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// 曜日選択ボタンコンポーネント
struct WeekdayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.system(.body, design: .rounded))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.primary : Color.clear)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
