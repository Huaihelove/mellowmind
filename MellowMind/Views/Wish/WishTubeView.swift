import SwiftUI
import SwiftData

struct WishTubeView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = WishTubeViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var stickDragOffsets: [WishTheme: CGFloat] = [:]

    private var skin: MellowSkin {
        SkinCatalog.tubeSkin(id: settings.selectedTubeSkinID)
    }

    var body: some View {
        ZStack {
            MellowBackground()
            StarParticleField(count: 46, tint: AppTheme.lavender)
                .opacity(0.48)

            ScrollView {
                VStack(spacing: 20) {
                    header
                    phaseContent
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: shakeDetector.shakeCount) { _, _ in
            if viewModel.phase == .shaking {
                viewModel.registerShake()
            }
            if viewModel.phase == .drawing {
                shakeDetector.stop()
            }
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            if newPhase == .drawing {
                shakeDetector.stop()
            }
        }
        .onDisappear {
            shakeDetector.stop()
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Healing Wish Slips")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("A wish is a promise to this moment, not an answer about the future")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Button {
                    router.push(.audioTherapy)
                } label: {
                    Image(systemName: "waveform")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.lavenderDeep)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.lavender.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open relaxation audio")
                MellowPill(text: skin.name, glyph: skin.symbol, tint: AppTheme.lavenderDeep)
            }
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                Text("The five themes offer present-moment comfort and encouragement only. They contain no outcome judgments.")
            }
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .prayer:
            prayerView
        case .shaking:
            shakingView
        case .drawing:
            drawingView
        case .result:
            resultView
        }
    }

    private var prayerView: some View {
        VStack(spacing: 22) {
            VStack(spacing: 7) {
                Text("Press your palms together and make a gentle wish")
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                Text("You do not need to wish for a different life. Gently entrust the part of yourself that needs care to this moment.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 20)

            WishTubeVisual(skin: skin, shakeCount: 0)

            HoldProgressButton(
                title: "Palms together",
                subtitle: "Hold for 1.8 seconds · Then gently shake your phone"
                systemImage: "heart.fill",
                duration: 1.8,
                tint: AppTheme.lavenderDeep
            ) {
                withAnimation(AppTheme.slowSpring) {
                    viewModel.beginShaking()
                }
                shakeDetector.reset()
                shakeDetector.start()
            }

            Text("If your device cannot be shaken, use the assistive shake in the next step.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.top, 12)
    }

    private var shakingView: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("Gently shake the wish tube")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("Let the tube hear your movement. After three shakes, the slips will settle and wait for you to draw one by hand.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            WishTubeVisual(skin: skin, shakeCount: viewModel.shakeCount)
                .animation(.spring(response: 0.26, dampingFraction: 0.52), value: viewModel.shakeCount)

            HStack(spacing: 8) {
                ForEach(0..<viewModel.requiredShakes, id: \.self) { index in
                    Capsule()
                        .fill(index < viewModel.shakeCount ? AppTheme.lavenderDeep : AppTheme.separator)
                        .frame(width: 30, height: 5)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.shakeCount)
                }
            }
            Text("Shakes \(viewModel.shakeCount)/\(viewModel.requiredShakes)")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)

            Button {
                viewModel.registerShake()
                HapticManager.shared.mediumTap()
            } label: {
                Label("Assistive shake once", systemImage: "hand.tap")
            }
            .buttonStyle(MellowSecondaryButtonStyle())
            .padding(.horizontal, 30)
        }
        .padding(.top, 16)
    }

    private var drawingView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Draw one by hand")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("Drag any slip upward. You are not assigned a slip; you choose the one that meets your present state.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            HStack(alignment: .bottom, spacing: 9) {
                ForEach(WishTheme.allCases) { theme in
                    WishStickView(theme: theme, tint: Color(hexString: theme.accentHex)) { selected in
                        withAnimation(AppTheme.slowSpring) {
                            viewModel.draw(theme: selected, profile: profile)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            Text("Drag upward · You draw the slip yourself")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.top, 8)
    }

    private var resultView: some View {
        VStack(spacing: 18) {
            if let reading = viewModel.reading {
                VStack(spacing: 14) {
                    MellowPill(text: reading.theme.rawValue, glyph: reading.theme.glyph, tint: Color(hexString: reading.theme.accentHex))
                    Text(reading.title)
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(reading.verse)
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .foregroundStyle(AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                    HStack(spacing: 6) {
                        Image(systemName: "sparkle")
                        Text("Today's emotional keyword: \(reading.keyword)")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.lavenderDeep)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 18)
                .background(
                    LinearGradient(colors: [Color(hexString: reading.theme.accentHex).opacity(0.15), AppTheme.surface.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color(hexString: reading.theme.accentHex).opacity(0.22), lineWidth: 1)
                )

                readingBlock(title: "Present reflection", icon: "eye", text: reading.interpretation, tint: AppTheme.lavenderDeep)
                readingBlock(title: "Gentle action", icon: "heart", text: reading.gentleAction, tint: AppTheme.warning)

                HStack(spacing: 12) {
                    Button {
                        _ = viewModel.collect(profile: profile, context: context)
                    } label: {
                        Label(viewModel.collectionSaved ? "Saved" : "Save wish slip", systemImage: viewModel.collectionSaved ? "heart.fill" : "heart")
                    }
                    .buttonStyle(MellowSecondaryButtonStyle())

                    Button {
                        withAnimation(AppTheme.slowSpring) {
                            viewModel.reset()
                            shakeDetector.reset()
                        }
                    } label: {
                        Label("Draw again", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(MellowPrimaryButtonStyle())
                }
            }
        }
    }

    private func readingBlock(title: String, icon: String, text: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                IconBadge(systemName: icon, tint: tint, size: 32)
                Text(title)
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            Text(text)
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mellowCard()
    }
}

private struct WishTubeVisual: View {
    let skin: MellowSkin
    let shakeCount: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            FloatingOrb(tint: Color(hexString: skin.primaryHex), size: 230)
                .offset(y: -20)

            VStack(spacing: -12) {
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { index in
                        Capsule()
                            .fill(LinearGradient(colors: [Color(hexString: skin.secondaryHex), Color(hexString: skin.primaryHex)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 7, height: 74 + CGFloat(index % 3) * 10)
                            .offset(y: CGFloat(index % 3) * -5)
                    }
                }
                .rotationEffect(.degrees(shakeCount % 2 == 0 ? -3 : 3))
                .offset(y: 12)

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(colors: [Color(hexString: skin.primaryHex), Color(hexString: skin.secondaryHex)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 168, height: 230)
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.42), lineWidth: 1)
                        .frame(width: 168, height: 230)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.26), lineWidth: 0.8)
                        .frame(width: 146, height: 210)
                    VStack(spacing: 7) {
                        Image(systemName: skin.symbol)
                            .font(.system(size: 30, weight: .light))
                        Text("Wish")
                            .font(.system(size: 24, weight: .medium, design: .serif))
                        Text("Gently shake")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .tracking(1.6)
                    }
                    .foregroundStyle(Color.white.opacity(0.85))
                }
            }
            .rotationEffect(.degrees(Double(shakeCount % 2 == 0 ? -1 : 1) * Double(min(shakeCount, 4)) * 1.8))
        }
        .frame(height: 320)
        .accessibilityHidden(true)
    }
}

private struct WishStickView: View {
    let theme: WishTheme
    let tint: Color
    let onDraw: (WishTheme) -> Void

    @State private var offset: CGFloat = 0
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .top) {
                Capsule()
                    .fill(LinearGradient(colors: [Color(hexString: theme.accentHex).opacity(0.35), Color(hexString: theme.accentHex)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 42, height: 225)
                    .overlay(alignment: .top) {
                        VStack(spacing: 3) {
                            Text(theme.glyph)
                                .font(.system(size: 16, weight: .light))
                            Text(theme.rawValue)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(1.5)
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.top, 18)
                    }
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.38), lineWidth: 1)
                    )
                Capsule()
                    .fill(tint.opacity(0.18))
                    .frame(width: 50, height: 24)
                    .offset(y: 210)
            }
            .offset(y: offset)
            .shadow(color: tint.opacity(isHovering ? 0.35 : 0.16), radius: isHovering ? 16 : 8, x: 0, y: 8)
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        offset = min(0, value.translation.height)
                        isHovering = offset < -16
                    }
                    .onEnded { value in
                        if value.translation.height < -70 {
                            HapticManager.shared.heavyTap()
                            onDraw(theme)
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                offset = 0
                                isHovering = false
                            }
                        }
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(theme.rawValue) wish slip")
            .accessibilityHint("Drag upward to draw")
            .accessibilityAction {
                onDraw(theme)
            }
        }
    }
}
