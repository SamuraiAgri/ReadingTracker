// ファイル名: ReadingTracker/Views/ReminderView.swift
import SwiftUI
import CoreData

class ReminderViewModel: ObservableObject {
    @Published var reminders: [ReadingReminder] = []
    
    private let reminderModel: ReminderModel
    
    init(viewContext: NSManagedObjectContext) {
        self.reminderModel = ReminderModel(viewContext: viewContext)
        fetchReminders()
    }
    
    func fetchReminders() {
        reminders = reminderModel.fetchReminders()
    }
    
    func addReminder(time: Date, daysOfWeek: [Int]) {
        _ = reminderModel.addReminder(time: time, daysOfWeek: daysOfWeek)
        fetchReminders()
    }
    
    func updateReminder(_ reminder: ReadingReminder, time: Date, daysOfWeek: [Int], isEnabled: Bool) {
        reminderModel.updateReminder(reminder, time: time, daysOfWeek: daysOfWeek, isEnabled: isEnabled)
        fetchReminders()
    }
    
    func toggleReminder(_ reminder: ReadingReminder) {
        reminderModel.toggleReminder(reminder)
        fetchReminders()
    }
    
    func deleteReminder(_ reminder: ReadingReminder) {
        reminderModel.deleteReminder(reminder)
        fetchReminders()
    }
    
    // 曜日名の表示用ヘルパーメソッド
    func weekdayNames(for reminder: ReadingReminder) -> String {
        guard let daysString = reminder.daysOfWeek, !daysString.isEmpty else {
            return "設定なし"
        }
        
        let weekdayNames = ["日", "月", "火", "水", "木", "金", "土"]
        let days = daysString.components(separatedBy: ",").compactMap { Int($0) }
        
        if days.count == 7 {
            return "毎日"
        } else if days.count == 5 && !days.contains(1) && !days.contains(7) {
            return "平日"
        } else if days.count == 2 && days.contains(1) && days.contains(7) {
            return "週末"
        } else {
            return days.map { weekdayNames[$0 - 1] }.joined(separator: "・")
        }
    }
    
    // 時間の表示用ヘルパーメソッド
    func timeString(for reminder: ReadingReminder) -> String {
        guard let time = reminder.time else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}
