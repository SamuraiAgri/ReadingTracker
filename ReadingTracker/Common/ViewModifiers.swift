// ファイル名: ReadingTracker/Common/ViewModifiers.swift

import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppConstants.UI.padding)
            .background(Color.background)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.primary)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: Color.primary.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
    
    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonStyle())
    }
}
