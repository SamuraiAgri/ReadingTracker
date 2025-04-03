// ファイル名: ReadingTracker/Common/Extensions/Color+Extension.swift

import SwiftUI

extension Color {
    // 基本色を直接定義
    static let primary = Color.blue
    static let secondary = Color.purple
    static let background = Color(.systemBackground)
    static let accent = Color.orange
    static let text = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    
    // ステータス用の色
    static let statusUnread = Color.gray
    static let statusReading = Color.blue
    static let statusFinished = Color.green
    
    // グラフ表示用の色
    static let chartPrimary = Color.blue
    static let chartSecondary = Color.purple
}
