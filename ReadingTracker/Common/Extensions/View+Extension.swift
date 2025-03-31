// ファイル名: ReadingTracker/Common/Extensions/View+Extension.swift
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// 角丸の一部のみを適用するための形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// プレースホルダーテキスト修飾子
struct PlaceholderStyle: ViewModifier {
    var showPlaceholder: Bool
    var placeholder: String
    var color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceholder {
                Text(placeholder)
                    .foregroundColor(color)
                    .padding(.horizontal, 4)
            }
            content
        }
    }
}

extension View {
    func placeholder(when shouldShow: Bool, placeholder: String, color: Color = .gray) -> some View {
        self.modifier(PlaceholderStyle(showPlaceholder: shouldShow, placeholder: placeholder, color: color))
    }
}
