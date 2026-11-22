import SwiftUI
import SwiftData

struct EditProfileView: View {
    let profile: UserProfile

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = ProfileViewModel()
    @State private var didLoad = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MellowPageTitle(
                    title: "Edit my profile",
                    subtitle: "When your birth date or blood type changes, daily copy and interactive readings regenerate for your combination.",
                    eyebrow: "Local profile"
                )

                identityCard
                birthCard
                preferenceCard

                Button {
                    if viewModel.save(profile: profile, context: context) {
                        dismiss()
                    }
                } label: {
                    Label("Save profile", systemImage: "checkmark")
                }
                .buttonStyle(MellowPrimaryButtonStyle())

                Text("Birth date, blood type, and wishes can all be cleared in Settings.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            viewModel.load(profile: profile)
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

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Name")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
            TextField("Star Friend", text: $viewModel.displayName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(14)
                .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            DividerSoft()
            Text("Blood-type personality reference")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
            HStack(spacing: 8) {
                ForEach(BloodType.allCases) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.bloodType = type
                        }
                        HapticManager.shared.selection()
                    } label: {
                        Text(type.displayName)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(viewModel.bloodType == type ? Color.white : AppTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(viewModel.bloodType == type ? AppTheme.lavenderDeep : AppTheme.surface.opacity(0.7), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("Used only as a playful personality reference, never for health or medical judgment.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var birthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Birth date", subtitle: "Automatically derives Western- and Chinese-zodiac personality references")
            DatePicker(
                "Birth date",
                selection: $viewModel.birthDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .environment(\.locale, Locale(identifier: "en_US"))
            HStack(spacing: 8) {
                MellowPill(text: ZodiacCalculator.westernZodiac(for: viewModel.birthDate).displayName, glyph: "sparkles", tint: AppTheme.lavenderDeep)
                MellowPill(text: "Chinese zodiac: \(ZodiacCalculator.chineseZodiac(for: viewModel.birthDate).displayName)", glyph: "leaf.fill", tint: AppTheme.milkBlueDeep)
            }
        }
        .mellowCard()
    }

    private var preferenceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeading(title: "Experience preferences")
            Toggle(isOn: $viewModel.hapticsEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic feedback")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                    Text("Gentle touch feedback for cards, wish slips, and wish rituals")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .tint(AppTheme.lavenderDeep)

            DividerSoft()

            Toggle(isOn: $viewModel.anonymousByDefault) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anonymous by default on the wish wall")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                    Text("You can still switch each post between named and anonymous")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .tint(AppTheme.lavenderDeep)

            DividerSoft()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Default audio-therapy volume")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                    Spacer()
                    Text("\(Int(viewModel.audioVolume * 100))%")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Slider(value: $viewModel.audioVolume, in: 0...1)
                    .tint(AppTheme.lavenderDeep)
            }
        }
        .mellowCard()
    }

    private var dateRange: ClosedRange<Date> {
        let lower = Calendar.current.date(from: DateComponents(year: 1901, month: 1, day: 1)) ?? Date.distantPast
        return lower...Date()
    }
}