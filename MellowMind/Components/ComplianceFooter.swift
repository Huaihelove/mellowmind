import SwiftUI

struct ComplianceFooter: View {
    var compact: Bool = true

    var body: some View {
        Text(AppTheme.complianceFooter)
            .font(.system(size: compact ? 9.5 : 11, weight: .regular, design: .rounded))
            .foregroundStyle(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 16)
            .padding(.vertical, compact ? 6 : 9)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(AppTheme.separator)
                    .frame(height: 0.5)
            }
            .accessibilityLabel(AppTheme.complianceFooter)
    }
}

struct ComplianceNote: View {
    var text: String = AppTheme.complianceFooter

    var body: some View {
        Text(text)
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
    }
}