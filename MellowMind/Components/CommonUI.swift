import SwiftUI

struct MellowPageTitle: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil, eyebrow: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.eyebrow = eyebrow
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let eyebrow {
                Text(eyebrow)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(AppTheme.lavenderDeep)
            }
            Text(title)
                .font(.mellowLargeTitle)
                .foregroundStyle(AppTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionHeading: View {
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                if let subtitle {
                    Text(subtitle)
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            Spacer(minLength: 10)
            if let trailing {
                trailing
            }
        }
    }
}

struct MellowPill: View {
    let text: String
    var glyph: String? = nil
    var tint: Color = AppTheme.lavender

    var body: some View {
        HStack(spacing: 5) {
            if let glyph {
                Image(systemName: glyph)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 10, weight: .medium, design: .rounded))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(tint.opacity(0.16), lineWidth: 1))
    }
}

struct MetricRing: View {
    let value: Int
    let caption: String
    var tint: Color = AppTheme.lavenderDeep

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.12), lineWidth: 9)
            Circle()
                .trim(from: 0, to: min(max(Double(value) / 100.0, 0), 1))
                .stroke(
                    AngularGradient(colors: [AppTheme.milkBlueDeep, tint, AppTheme.mistRose, AppTheme.milkBlueDeep], center: .center),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(caption)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(width: 92, height: 92)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(caption) \(value)")
    }
}

struct IconBadge: View {
    let systemName: String
    var tint: Color = AppTheme.lavenderDeep
    var size: CGFloat = 38

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: size * 0.34, style: .continuous))
    }
}

struct MellowPrimaryButtonStyle: ButtonStyle {
    var tint: Color = AppTheme.lavenderDeep

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [tint.opacity(0.92), AppTheme.milkBlueDeep.opacity(0.86)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
            )
            .shadow(color: tint.opacity(configuration.isPressed ? 0.10 : 0.22), radius: configuration.isPressed ? 4 : 12, x: 0, y: configuration.isPressed ? 2 : 7)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct MellowSecondaryButtonStyle: ButtonStyle {
    var tint: Color = AppTheme.lavenderDeep

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(tint.opacity(configuration.isPressed ? 0.16 : 0.09), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(tint.opacity(0.18), lineWidth: 1)
            )
    }
}

struct WarmEmptyState: View {
    let title: String
    let message: String
    var systemImage: String = "sparkles"

    var body: some View {
        VStack(spacing: 12) {
            IconBadge(systemName: systemImage, tint: AppTheme.lavenderDeep, size: 54)
            Text(title)
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text(message)
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
    }
}

struct MoodChip: View {
    let mood: EmotionMood
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(mood.glyph)
            Text(mood.rawValue)
                .font(.system(size: 11, weight: .medium, design: .rounded))
        }
        .foregroundStyle(isSelected ? Color.white : AppTheme.secondaryText)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(isSelected ? AppTheme.lavenderDeep : AppTheme.surface.opacity(0.8), in: Capsule())
        .overlay(Capsule().stroke(AppTheme.lavender.opacity(isSelected ? 0 : 0.2), lineWidth: 1))
    }
}

struct AudioWaveView: View {
    let isPlaying: Bool
    var tint: Color = AppTheme.lavenderDeep

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !isPlaying)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<18, id: \.self) { index in
                    let wave = sin(time * 2.1 + Double(index) * 0.63)
                    let height = isPlaying ? 6 + (wave + 1) * 10 + Double(index % 3) * 2 : 5 + Double(index % 4)
                    Capsule()
                        .fill(tint.opacity(isPlaying ? 0.66 : 0.25))
                        .frame(width: 3, height: height)
                }
            }
            .frame(height: 34)
        }
        .accessibilityHidden(true)
    }
}

struct TypingDots: View {
    @State private var phase = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppTheme.secondaryText.opacity(0.5))
                    .frame(width: 5, height: 5)
                    .offset(y: phase ? -3 : 3)
                    .animation(
                        .easeInOut(duration: 0.62).repeatForever(autoreverses: true).delay(Double(index) * 0.12),
                        value: phase
                    )
            }
        }
        .onAppear { phase = true }
    }
}

struct DividerSoft: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.separator)
            .frame(height: 0.5)
    }
}

struct PrivacyBadge: View {
    var text: String = "Stored only on this device"

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock.fill")
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(.system(size: 10, weight: .medium, design: .rounded))
        }
        .foregroundStyle(AppTheme.secondaryText)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(AppTheme.surface.opacity(0.7), in: Capsule())
    }
}