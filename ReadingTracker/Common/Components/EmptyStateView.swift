// ファイル名: ReadingTracker/Common/Components/EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let iconName: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(AppConstants.Fonts.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(AppConstants.Fonts.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .primaryButtonStyle()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
