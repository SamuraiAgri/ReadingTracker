// ファイル名: ReadingTracker/Common/Components/CustomButton.swift
import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = .primary
    var foregroundColor: Color = .white
    var fullWidth: Bool = false
    var icon: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var fullWidth: Bool = false
    var icon: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(Color.primary.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(AppConstants.UI.cornerRadius)
        }
    }
}
