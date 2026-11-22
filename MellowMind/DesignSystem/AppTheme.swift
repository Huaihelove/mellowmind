import SwiftUI
import UIKit

enum AppTheme {
    static let appName = "Mellow Mind"
    static let slogan = "Set down emotional tension. Make ordinary days gentler."
    static let complianceFooter = "Disclaimer: All content is for personality reference and emotional comfort only. It is not a fortune-telling service and cannot predict the future."

    static let lavender = Color(hex: 0xB7A6D4)
    static let lavenderDeep = Color(hex: 0x7A6A9B)
    static let moonWhite = Color(hex: 0xF7F4FB)
    static let milkBlue = Color(hex: 0xDDEAF4)
    static let milkBlueDeep = Color(hex: 0x8BA7BC)
    static let mistRose = Color(hex: 0xE9D4D9)
    static let warmSand = Color(hex: 0xE8DDCF)
    static let ink = Color(hex: 0x332F3A)
    static let softInk = Color(hex: 0x655E70)

    static let canvas = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.067, blue: 0.105, alpha: 1)
            : UIColor(red: 0.969, green: 0.957, blue: 0.984, alpha: 1)
    })

    static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.125, green: 0.112, blue: 0.165, alpha: 1)
            : UIColor(white: 1, alpha: 0.72)
    })

    static let elevatedSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.15, blue: 0.22, alpha: 1)
            : UIColor(white: 1, alpha: 0.9)
    })

    static let primaryText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.91, blue: 0.96, alpha: 1)
            : UIColor(red: 0.20, green: 0.18, blue: 0.23, alpha: 1)
    })

    static let secondaryText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.68, green: 0.65, blue: 0.74, alpha: 1)
            : UIColor(red: 0.40, green: 0.37, blue: 0.44, alpha: 1)
    })

    static let separator = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.09)
            : UIColor(red: 0.40, green: 0.34, blue: 0.52, alpha: 0.12)
    })

    static let success = Color(hex: 0x8EB6A7)
    static let warning = Color(hex: 0xD6A77A)

    static let cardRadius: CGFloat = 24
    static let compactRadius: CGFloat = 16
    static let pagePadding: CGFloat = 20

    static let slowSpring = Animation.spring(response: 0.72, dampingFraction: 0.82)
    static let gentleEase = Animation.easeInOut(duration: 0.55)
    static let ambient = Animation.easeInOut(duration: 7.5).repeatForever(autoreverses: true)

    static let supportEmail = "support@mellowmind.app"
    static let privacyURL = "https://mellowmind.app/privacy"
    static let termsURL = "https://mellowmind.app/terms"
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(hexString: String, fallback: Color = AppTheme.lavender) {
        let cleaned = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard let value = UInt(cleaned, radix: 16) else {
            self = fallback
            return
        }
        self.init(hex: value)
    }
}

extension Font {
    static var mellowLargeTitle: Font { .system(size: 32, weight: .semibold, design: .rounded) }
    static var mellowTitle: Font { .system(size: 24, weight: .semibold, design: .rounded) }
    static var mellowHeadline: Font { .system(size: 18, weight: .semibold, design: .rounded) }
    static var mellowBody: Font { .system(size: 15, weight: .regular, design: .rounded) }
    static var mellowCaption: Font { .system(size: 12, weight: .medium, design: .rounded) }
    static var mellowMicro: Font { .system(size: 10, weight: .regular, design: .rounded) }
}

struct MellowBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var drifting = false

    var body: some View {
        ZStack {
            AppTheme.canvas

            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: 0x171421), Color(hex: 0x10131A), Color(hex: 0x1B1723)]
                    : [Color(hex: 0xF8F5FC), Color(hex: 0xEDF4FA), Color(hex: 0xF5EEF3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(RadialGradient(colors: [AppTheme.lavender.opacity(0.32), .clear], center: .center, startRadius: 8, endRadius: 240))
                .frame(width: 460, height: 460)
                .blur(radius: 22)
                .offset(x: drifting ? 130 : 60, y: drifting ? -310 : -250)

            Circle()
                .fill(RadialGradient(colors: [AppTheme.milkBlue.opacity(0.30), .clear], center: .center, startRadius: 10, endRadius: 220))
                .frame(width: 420, height: 420)
                .blur(radius: 28)
                .offset(x: drifting ? -150 : -90, y: drifting ? 300 : 250)

            Ellipse()
                .fill(RadialGradient(colors: [AppTheme.mistRose.opacity(0.22), .clear], center: .center, startRadius: 12, endRadius: 210))
                .frame(width: 380, height: 300)
                .blur(radius: 38)
                .rotationEffect(.degrees(-22))
                .offset(x: drifting ? 30 : -20, y: drifting ? 120 : 180)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(AppTheme.ambient) {
                drifting = true
            }
        }
    }
}

struct GlassCardModifier: ViewModifier {
    var padding: CGFloat = 18
    var cornerRadius: CGFloat = AppTheme.cardRadius

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.surface.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.42), AppTheme.lavender.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: AppTheme.lavenderDeep.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func mellowCard(padding: CGFloat = 18, cornerRadius: CGFloat = AppTheme.cardRadius) -> some View {
        modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func mellowPagePadding() -> some View {
        padding(.horizontal, AppTheme.pagePadding)
    }
}