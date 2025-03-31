// ファイル名: ReadingTracker/Models/ReminderModel.swift

import Foundation
import CoreData
import UserNotifications

class ReminderModel {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func fetchReminders() -> [ReadingReminder] {
        let request: NSFetchRequest<ReadingReminder> = ReadingReminder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("リマインダーの取得に失敗しました: \(error)")
            return []
        }
    }
    
    func addReminder(time: Date, daysOfWeek: [Int]) -> ReadingReminder {
        let reminder = ReadingReminder(context: viewContext)
        reminder.id = UUID()
        reminder.time = time
        reminder.isEnabled = true
        reminder.daysOfWeek = daysOfWeek.map { String($0) }.joined(separator: ",")
        
        saveContext()
        scheduleNotification(for: reminder)
        
        return reminder
    }
    
    func updateReminder(_ reminder: ReadingReminder, time: Date, daysOfWeek: [Int], isEnabled: Bool) {
        reminder.time = time
        reminder.daysOfWeek = daysOfWeek.map { String($0) }.joined(separator: ",")
        reminder.isEnabled = isEnabled
        
        saveContext()
        
        // 通知を更新
        removeNotification(for: reminder)
        if isEnabled {
            scheduleNotification(for: reminder)
        }
    }
    
    func toggleReminder(_ reminder: ReadingReminder) {
        reminder.isEnabled.toggle()
        
        saveContext()
        
        if reminder.isEnabled {
            scheduleNotification(for: reminder)
        } else {
            removeNotification(for: reminder)
        }
    }
    
    func deleteReminder(_ reminder: ReadingReminder) {
        removeNotification(for: reminder)
        viewContext.delete(reminder)
        saveContext()
    }
    
    private func scheduleNotification(for reminder: ReadingReminder) {
        guard reminder.isEnabled else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // まず通知許可を確認
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard granted else { return }
            
            // 曜日配列に変換
            let daysOfWeek = reminder.daysOfWeek?.components(separatedBy: ",")
                .compactMap { Int($0) } ?? []
            
            // 各曜日ごとに通知を設定
            for weekday in daysOfWeek {
                self.scheduleNotificationForWeekday(reminderID: reminder.id?.uuidString ?? UUID().uuidString,
                                                   time: reminder.time ?? Date(),
                                                   weekday: weekday)
            }
        }
    }
    
    private func scheduleNotificationForWeekday(reminderID: String, time: Date, weekday: Int) {
        let center = UNUserNotificationCenter.current()
        
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = "読書の時間です"
        content.body = "今日も少し読書をして習慣を続けましょう"
        content.sound = .default
        
        // 時間コンポーネントを取得
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        // トリガーの作成（特定の曜日の特定の時間）
        var dateComponents = DateComponents()
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.weekday = weekday  // 1が日曜、7が土曜
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 通知リクエストの作成
        let identifier = "\(reminderID)_\(weekday)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 通知のスケジュール
        center.add(request) { error in
            if let error = error {
                print("通知のスケジュールに失敗しました: \(error)")
            }
        }
    }
    
    private func removeNotification(for reminder: ReadingReminder) {
        guard let reminderID = reminder.id?.uuidString else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // 曜日配列に変換
        let daysOfWeek = reminder.daysOfWeek?.components(separatedBy: ",")
            .compactMap { Int($0) } ?? []
        
        // 各曜日の通知を削除
        let identifiers = daysOfWeek.map { "\(reminderID)_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
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
