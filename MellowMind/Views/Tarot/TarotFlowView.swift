import SwiftUI
import SwiftData

struct TarotFlowView: View {
    let profile: UserProfile
    let settings: AppSettings

    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = TarotViewModel()
    @State private var lastShuffleX: CGFloat = 0
    @State private var lastRubX: CGFloat = 0

    private var skin: MellowSkin {
        SkinCatalog.tarotSkin(id: settings.selectedTarotSkinID)
    }

    var body: some View {
        ZStack {
            MellowBackground()
            StarParticleField(count: 44, tint: AppTheme.lavender)
                .opacity(0.45)

            ScrollView {
                VStack(spacing: 18) {
                    header
                    phaseContent
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .task(id: profile.updatedAt) {
            viewModel.configure(profile: profile)
        }
        .onDisappear {
            lastShuffleX = 0
            lastRubX = 0
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
                    Text("Mood Cards")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("See the present, not the future")
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
                Text("The reading always has three parts: current emotion, an overlooked thought, and gentle guidance. It is for self-care only.")
            }
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .charge:
            chargeView
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
        case .shuffle:
            shuffleView
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .spread:
            spreadView
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .reveal, .complete:
            revealView
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }

    private var chargeView: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                Text("Place your hand here first")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("Hold to gather energy and slowly bring your attention back from the outside. There is no correct answer, only the real you in this moment.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 24)

            HoldProgressButton(
                title: "Hold to gather energy",
                subtitle: "Keep holding for 2.4 seconds · Starlight responds to your attention"
                systemImage: "sparkles",
                duration: 2.4,
                tint: AppTheme.lavenderDeep
            ) {
                withAnimation(AppTheme.slowSpring) {
                    viewModel.completeCharge(profile: profile)
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "hand.raised.fill")
                Text("After gathering energy, you will shuffle and choose a card by hand.")
            }
            .font(.mellowCaption)
            .foregroundStyle(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    private var shuffleView: some View {
        VStack(spacing: 22) {
            VStack(spacing: 6) {
                Text("Shuffle by hand")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("Swipe the deck left or right and let the cards meet the rhythm of this moment.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    TarotCardBack(skin: skin, glyph: "✦", isShuffling: true)
                        .frame(width: 208, height: 336)
                        .rotationEffect(.degrees(Double(index - 1) * 5 + Double(viewModel.shuffleCount % 5) * 0.7))
                        .offset(x: CGFloat(index - 1) * 8, y: CGFloat(index) * 3)
                        .shadow(color: AppTheme.lavenderDeep.opacity(0.18), radius: 18, x: 0, y: 12)
                }
                FloatingOrb(tint: AppTheme.lavender, size: 210)
                    .offset(y: -20)
            }
            .frame(height: 360)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        let delta = value.translation.width - lastShuffleX
                        if abs(delta) >= 44 {
                            lastShuffleX = value.translation.width
                            viewModel.registerShuffleStep()
                        }
                    }
                    .onEnded { _ in
                        lastShuffleX = 0
                    }
            )

            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(0..<viewModel.targetShuffles, id: \.self) { index in
                        Circle()
                            .fill(index < viewModel.shuffleCount ? AppTheme.lavenderDeep : AppTheme.separator)
                            .frame(width: index < viewModel.shuffleCount ? 8 : 6, height: index < viewModel.shuffleCount ? 8 : 6)
                            .animation(.easeInOut(duration: 0.25), value: viewModel.shuffleCount)
                    }
                }
                Text(viewModel.shuffleInstruction)
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.top, 12)
    }

    private var spreadView: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("Choose the card that meets you")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("No system decides for you. Follow your intuition and tap one card; for this moment, it is yours.")
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            GeometryReader { proxy in
                let cardWidth = min(76.0, proxy.size.width / 5.2)
                let spacing = min(27.0, proxy.size.width / 14)
                ZStack {
                    ForEach(viewModel.spreadCards) { card in
                        let index = viewModel.spreadCards.firstIndex(where: { $0.id == card.id }) ?? 0
                        let distance = Double(index) - Double(viewModel.spreadCards.count - 1) / 2
                        TarotCardBack(skin: skin, glyph: "✦", isShuffling: false)
                            .frame(width: cardWidth, height: cardWidth * 1.62)
                            .rotationEffect(.degrees(distance * 7.2))
                            .offset(x: CGFloat(distance) * spacing, y: abs(distance) * 9)
                            .onTapGesture {
                                withAnimation(AppTheme.slowSpring) {
                                    viewModel.choose(card: card, profile: profile)
                                }
                            }
                            .accessibilityLabel("Card \(index + 1)")
                            .accessibilityHint("Tap to choose this card")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 300)

            Text("Tap any card · You choose by hand")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.top, 14)
    }

    private var revealView: some View {
        VStack(spacing: 20) {
            ZStack {
                FloatingOrb(tint: AppTheme.mistRose, size: 260)
                Card3DFlip(isFlipped: viewModel.isFlipped) {
                    TarotCardBack(skin: skin, glyph: "✦", isShuffling: false)
                } back: {
                    if let card = viewModel.selectedCard {
                        TarotCardFront(card: card, skin: skin)
                    }
                }
                .frame(width: 210, height: 338)
                .gesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { value in
                            let delta = value.translation.width - lastRubX
                            lastRubX = value.translation.width
                            viewModel.rub(delta: delta)
                        }
                        .onEnded { _ in
                            lastRubX = 0
                        }
                )
                .accessibilityHint("Swipe left or right across the card to finish the cleansing gesture")
            }
            .frame(height: 360)

            soothePanel

            if let reading = viewModel.reading {
                readingSections(reading)
                actionButtons
            }
        }
        .padding(.top, 4)
    }

    private var soothePanel: some View {
        VStack(spacing: 10) {
            HStack {
                Text(viewModel.phase == .complete ? "The tension has been gently set down" : "Swipe the card to soften the tension")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Text("\(Int(viewModel.sootheProgress * 100))%")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            GeometryReader { proxy in
                Capsule()
                    .fill(AppTheme.separator)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(LinearGradient(colors: [AppTheme.lavender, AppTheme.milkBlueDeep, AppTheme.mistRose], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * viewModel.sootheProgress)
                    }
            }
            .frame(height: 6)

            if !viewModel.keyword.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle")
                    Text("Today's emotional keyword: \(viewModel.keyword)")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.lavenderDeep)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.lavender.opacity(0.12), in: Capsule())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(14)
        .background(AppTheme.surface.opacity(0.68), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func readingSections(_ reading: TarotReading) -> some View {
        VStack(spacing: 14) {
            readingBlock(title: "Your current emotional state", icon: "cloud.moon", text: reading.emotionState, tint: AppTheme.milkBlueDeep)
            readingBlock(title: "A thought you may be overlooking", icon: "eye", text: reading.ignoredThought, tint: AppTheme.lavenderDeep)
            readingBlock(title: "Gentle emotional-care guidance", icon: "heart", text: reading.gentleAdvice, tint: AppTheme.warning)
            VStack(alignment: .leading, spacing: 10) {
                Text("A response from your three layers")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                Text(reading.fusionNote)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineSpacing(4)
                DividerSoft()
                Text(reading.affirmation)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.lavenderDeep)
            }
            .mellowCard()
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

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                _ = viewModel.collect(context: context)
            } label: {
                Label(viewModel.collectionSaved ? "Saved" : "Save reflection", systemImage: viewModel.collectionSaved ? "heart.fill" : "heart")
            }
            .buttonStyle(MellowSecondaryButtonStyle())

            Button {
                withAnimation(AppTheme.slowSpring) {
                    viewModel.reset()
                    lastShuffleX = 0
                    lastRubX = 0
                }
            } label: {
                Label("Draw again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(MellowPrimaryButtonStyle())
        }
    }
}