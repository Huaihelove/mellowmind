import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var showConvergence = false
    @State private var isZodiacCardFlipped = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        ZStack {
            MellowBackground()
            StarParticleField(count: 72, tint: AppTheme.lavender)
                .opacity(0.58)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    brandHeader
                    stepIndicator

                    Group {
                        switch viewModel.step {
                        case 0:
                            bloodTypeStep
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        case 1:
                            birthdayStep
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        default:
                            previewStep
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        }
                    }
                    .id(viewModel.step)

                    bottomControls
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            if showConvergence {
                StarlightConvergenceView {
                    let success = viewModel.complete(context: context)
                    showConvergence = false
                    if !success {
                        HapticManager.shared.error()
                    }
                }
                .zIndex(20)
                .transition(.opacity)
            }
        }
        .alert("Profile setup", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.step) { _, newStep in
            if newStep == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                        isZodiacCardFlipped = true
                    }
                }
            }
        }
    }

    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [AppTheme.lavender, AppTheme.milkBlueDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 42, height: 42)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppTheme.appName)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Know yourself first, then live gently")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge()
            }

            Text(AppTheme.slogan)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.top, 4)
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.step ? AppTheme.lavenderDeep : AppTheme.separator)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.step)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Profile setup progress, step \(viewModel.step + 1) of 3")
    }

    private var bloodTypeStep: some View {
        VStack(alignment: .leading, spacing: 22) {
            MellowPageTitle(
                title: "Your emotional foundation,\nwhich small clue should we begin with?",
                subtitle: "Blood type is used here only as a light personality reference. Choose the closest match; you can change it later.",
                eyebrow: "01 · Blood-type personality reference"
            )

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(BloodType.allCases) { type in
                    Button {
                        viewModel.selectBloodType(type)
                    } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(hexString: type.accentHex).opacity(0.15))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(Color(hexString: type.accentHex))
                                }
                                Spacer()
                                if viewModel.bloodType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppTheme.lavenderDeep)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            Text(type.displayName)
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(type.shortTrait)
                                .font(.mellowCaption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppTheme.surface.opacity(0.82))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    viewModel.bloodType == type
                                        ? Color(hexString: type.accentHex).opacity(0.9)
                                        : AppTheme.separator,
                                    lineWidth: viewModel.bloodType == type ? 1.6 : 1
                                )
                        )
                        .scaleEffect(viewModel.bloodType == type ? 1.015 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundStyle(AppTheme.lavenderDeep)
                Text("Your profile stays on this device. Blood type is not used for health assessment; it only shapes personality-reflection and emotional-care copy.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(AppTheme.lavender.opacity(0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var birthdayStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            MellowPageTitle(
                title: "Let time help you\ncomplete the other two personality clues",
                subtitle: "Choose your birth date. The Western zodiac and birth-year Chinese zodiac are derived only as playful personality references.",
                eyebrow: "02 · Automatic date mapping"
            )

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Birth date")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(viewModel.birthDate.formatted(.dateTime.year().month().day()))
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                }
                Spacer()
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(AppTheme.lavender)
            }
            .padding(.horizontal, 6)

            DatePicker(
                "Choose birth date",
                selection: $viewModel.birthDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "en_US"))
            .frame(height: 150)
            .clipped()
            .padding(.horizontal, -10)
            .onChange(of: viewModel.birthDate) { _, _ in
                withAnimation(.easeInOut(duration: 0.22)) {
                    isZodiacCardFlipped = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.72, dampingFraction: 0.8)) {
                        isZodiacCardFlipped = true
                    }
                    HapticManager.shared.selection()
                }
            }

            Card3DFlip(isFlipped: isZodiacCardFlipped) {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(AppTheme.lavenderDeep)
                    Text("Reading your time clues")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Zodiac references are for personality reflection only")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 184)
                .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } back: {
                HStack(spacing: 12) {
                    derivedZodiacTile(
                        title: "Western-zodiac personality reference",
                        name: viewModel.westernZodiac.displayName,
                        glyph: viewModel.westernZodiac.glyph,
                        detail: viewModel.westernZodiac.shortTrait,
                        tint: AppTheme.lavenderDeep
                    )
                    derivedZodiacTile(
                        title: "Chinese-zodiac personality reference",
                        name: "Chinese zodiac: \(viewModel.chineseZodiac.displayName)",
                        glyph: viewModel.chineseZodiac.glyph,
                        detail: viewModel.chineseZodiac.shortTrait,
                        tint: AppTheme.milkBlueDeep
                    )
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .frame(height: 184)
                .background(AppTheme.surface.opacity(0.86), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppTheme.lavender.opacity(0.2), lineWidth: 1)
                )
            }

            Text("The birth year maps to a Chinese-zodiac personality reference. This app never uses it for fate, fortune, or future judgment.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal, 4)
        }
    }

    private var previewStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            MellowPageTitle(
                title: "Your three layers of self\nhave met here",
                subtitle: "After your profile is created, daily strengths, the almanac, cards, wish slips, and Tree Hollow replies will all be generated around this combination.",
                eyebrow: "03 · First look at your personality"
            )

            if let bloodType = viewModel.bloodType {
                previewSummaryCard(bloodType: bloodType)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("What should we call you?")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                TextField("Leave blank to use 'Star Friend'", text: $viewModel.displayName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($nameFocused)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .padding(14)
                    .background(AppTheme.surface.opacity(0.84), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.lavender.opacity(0.18), lineWidth: 1)
                    )
            }

            SlideToUnlock(title: "Slide to unlock · Enter my healing space") {
                nameFocused = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    showConvergence = true
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                Text("No account required. Birth details and blood type are never uploaded. You can clear them anytime in Settings.")
            }
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
    }

    private var bottomControls: some View {
        HStack(spacing: 12) {
            if viewModel.step > 0 {
                Button {
                    viewModel.back()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(MellowSecondaryButtonStyle())
                .frame(width: 112)
            }

            if viewModel.step < 2 {
                Button {
                    if viewModel.step == 0 && viewModel.bloodType == nil {
                        HapticManager.shared.warning()
                    } else {
                        viewModel.next()
                    }
                } label: {
                    HStack {
                        Text(viewModel.step == 0 ? "Continue to time clues" : "Create my personality snapshot")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(MellowPrimaryButtonStyle())
                .opacity(viewModel.canAdvance ? 1 : 0.55)
                .disabled(!viewModel.canAdvance)
            }
        }
        .padding(.top, 4)
    }

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let lower = calendar.date(from: DateComponents(year: 1901, month: 1, day: 1)) ?? Date.distantPast
        return lower...Date()
    }

    private func derivedZodiacTile(title: String, name: String, glyph: String, detail: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
            Text(glyph)
                .font(.system(size: 30, weight: .light))
            Text(name)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(detail)
                .font(.mellowCaption)
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func previewSummaryCard(bloodType: BloodType) -> some View {
        let snapshot = PersonalitySnapshot(
            bloodType: bloodType,
            westernZodiac: viewModel.westernZodiac,
            chineseZodiac: viewModel.chineseZodiac,
            birthDate: viewModel.birthDate
        )
        let dossier = PersonalityEngine.dossier(for: snapshot)
        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                MellowPill(text: "\(bloodType.displayName)", glyph: "drop.fill", tint: AppTheme.lavenderDeep)
                MellowPill(text: viewModel.westernZodiac.displayName, glyph: "sparkles", tint: AppTheme.milkBlueDeep)
                MellowPill(text: "Chinese zodiac: \(viewModel.chineseZodiac.displayName)", glyph: "leaf.fill", tint: AppTheme.warning)
            }
            Text(dossier.fusionSummary)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(5)
            DividerSoft()
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .foregroundStyle(AppTheme.lavenderDeep)
                Text("Your personality strength updates daily. It does not judge your fate; it simply offers another way to understand yourself.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .mellowCard()
    }
}