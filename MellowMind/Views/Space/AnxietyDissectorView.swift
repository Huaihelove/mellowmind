import SwiftUI
import SwiftData

struct AnxietyDissectorView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AnxietyDissectorViewModel()
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            MellowBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    inputCard
                    if viewModel.isAnalyzing {
                        analyzingCard
                    }
                    if let analysis = viewModel.analysis {
                        resultView(analysis)
                    }
                    footnote
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.feedback != nil },
            set: { if !$0 { viewModel.feedback = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.feedback = nil }
        } message: {
            Text(viewModel.feedback ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Anxiety Sorter")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Turn a tangle of strain into pieces you can understand and act on.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                IconBadge(systemName: "point.3.connected.trianglepath.dotted", tint: AppTheme.lavenderDeep, size: 46)
            }
            HStack(spacing: 7) {
                MellowPill(text: profile.bloodType.displayName, tint: Color(hexString: profile.bloodType.accentHex))
                MellowPill(text: profile.westernZodiac.displayName, tint: AppTheme.lavenderDeep)
                MellowPill(text: "Chinese zodiac: \(profile.chineseZodiac.displayName)", tint: AppTheme.milkBlueDeep)
            }
            Text("Your input is analyzed locally by built-in rules. It is never uploaded or used for training.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "What is troubling you most right now?", subtitle: "Write a specific situation, or just the tangled feeling")
            ZStack(alignment: .topLeading) {
                if viewModel.worry.isEmpty {
                    Text("For example: I have a presentation tomorrow and keep imagining something going wrong. Or: I always feel I am not good enough, but I cannot explain why...")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.66))
                        .padding(14)
                }
                TextEditor(text: $viewModel.worry)
                    .focused($inputFocused)
                    .font(.mellowBody)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 150)
            }
            .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.lavender.opacity(0.18), lineWidth: 1)
            )

            HStack {
                Text("\(viewModel.worry.count)/1200")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                PrivacyBadge()
            }

            Button {
                inputFocused = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.analyze(profile: profile)
                }
            } label: {
                Label(viewModel.analysis == nil ? "Sort this gently" : "Sort it again", systemImage: "sparkles")
            }
            .buttonStyle(MellowPrimaryButtonStyle())
            .disabled(viewModel.isAnalyzing)
        }
        .mellowCard()
    }

    private var analyzingCard: some View {
        HStack(spacing: 12) {
            TypingDots()
            VStack(alignment: .leading, spacing: 3) {
                Text("Organizing your sources of strain")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                Text("Using blood type, Western-zodiac, and Chinese-zodiac personality references for emotional reflection only.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
        }
        .mellowCard()
    }

    private func resultView(_ analysis: AnxietyAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    MellowPill(text: analysis.keyword, glyph: "sparkle", tint: AppTheme.lavenderDeep)
                    Spacer()
                    PrivacyBadge()
                }
                Text("Your emotional clues")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(analysis.currentState)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(5)
            }
            .mellowCard()

            VStack(alignment: .leading, spacing: 12) {
                SectionHeading(title: "Where the strain comes from", subtitle: "A view across all three personality layers")
                ForEach(analysis.roots) { root in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(AppTheme.lavender.opacity(0.22))
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(root.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(root.detail)
                                .font(.mellowCaption)
                                .foregroundStyle(AppTheme.secondaryText)
                                .lineSpacing(3)
                        }
                    }
                }
                DividerSoft()
                Text(analysis.gentleExplanation)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(4)
            }
            .mellowCard()

            VStack(alignment: .leading, spacing: 12) {
                SectionHeading(title: "Small things you can do now")
                ForEach(Array(analysis.actionPlan.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.lavenderDeep)
                            .frame(width: 23, height: 23)
                            .background(AppTheme.lavender.opacity(0.12), in: Circle())
                        Text(step)
                            .font(.mellowBody)
                            .foregroundStyle(AppTheme.primaryText)
                            .lineSpacing(3)
                    }
                }
            }
            .mellowCard()

            VStack(alignment: .leading, spacing: 11) {
                Label("One-minute grounding practice", systemImage: "lungs.fill")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(analysis.grounding)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(4)
                DividerSoft()
                Text(analysis.affirmation)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.lavenderDeep)
                    .lineSpacing(3)
            }
            .mellowCard()

            HStack(spacing: 12) {
                Button {
                    _ = viewModel.collect(profile: profile, context: context)
                } label: {
                    Label(viewModel.collectionSaved ? "Saved" : "Save this reflection", systemImage: viewModel.collectionSaved ? "heart.fill" : "heart")
                }
                .buttonStyle(MellowSecondaryButtonStyle())

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.reset()
                    }
                } label: {
                    Label("Start over", systemImage: "arrow.clockwise")
                }
                .buttonStyle(MellowSecondaryButtonStyle())
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var footnote: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("Important note", systemImage: "info.circle")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("The Anxiety Sorter is for emotional self-reflection. It does not diagnose, make medical judgments, or predict outcomes. If severe distress, sleep problems, or daily functioning continue to be affected, please seek support from a qualified professional.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .mellowCard()
    }
}