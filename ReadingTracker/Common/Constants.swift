// ファイル名: ReadingTracker/Common/Constants.swift

import SwiftUI

enum AppConstants {
    // 読書ステータス
    enum ReadingStatus: Int16, CaseIterable, Identifiable {
        case unread = 0
        case reading = 1
        case finished = 2
        
        var id: Int16 { self.rawValue }
        
        var displayName: String {
            switch self {
            case .unread:
                return "積読"
            case .reading:
                return "読書中"
            case .finished:
                return "読了"
            }
        }
        
        var color: Color {
            switch self {
            case .unread:
                return .statusUnread
            case .reading:
                return .statusReading
            case .finished:
                return .statusFinished
            }
        }
    }
    
    // UI定数
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let iconSize: CGFloat = 24
        static let bookCoverAspectRatio: CGFloat = 0.7  // width:height = 7:10
    }
    
    // フォント
    enum Fonts {
        static let title = Font.system(.title, design: .rounded).weight(.bold)
        static let headline = Font.system(.headline, design: .rounded)
        static let body = Font.system(.body, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
    }
    
    // アニメーション
    enum Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}
