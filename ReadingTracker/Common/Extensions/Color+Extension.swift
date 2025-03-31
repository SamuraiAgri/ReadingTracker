// ファイル名: ReadingTracker/Common/Extensions/Color+Extension.swift

import SwiftUI

extension Color {
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let background = Color("Background")
    static let accent = Color("Accent")
    static let text = Color("TextColor")
    static let textSecondary = Color("TextSecondary")
    
    // ステータス用の色
    static let statusUnread = Color("StatusUnread")
    static let statusReading = Color("StatusReading")
    static let statusFinished = Color("StatusFinished")
    
    // グラフ表示用の色
    static let chartPrimary = Color("ChartPrimary")
    static let chartSecondary = Color("ChartSecondary")
}
