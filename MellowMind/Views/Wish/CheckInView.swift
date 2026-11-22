import SwiftUI
import SwiftData

struct CheckInView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @Query(sort: \CheckInRecord.createdAt, order: .reverse) private var records: [CheckInRecord]
    @StateObject private var viewModel = CheckInViewModel()

    private var todayKey: String { DateKey.string(from: Date()) }
    private var todayRecord: CheckInRecord? { records.first(where: { $0.dateKey == todayKey }) }
    private var streak: Int { GrowthEngine.checkInStreak(records: records) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                streakHero
                weekStrip
                if let todayRecord {
                    completedCard(todayRecord)
                } else {
                    achievementPicker
                    noteEditor
                    checkInButton
                }
                if let feedback = viewModel.feedback {
                    Text(feedback)
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.surface.opacity(0.66), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                growthNote
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Echo")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Think of check-in as answering the wishes you once made for yourself.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge()
            }
            Text("Record one small achievement each day. You do not need a perfect streak; you only need to be willing to return.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var streakHero: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(AppTheme.lavender.opacity(0.15), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: min(Double(streak) / 7.0, 1))
                    .stroke(LinearGradient(colors: [AppTheme.lavender, AppTheme.milkBlueDeep], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(streak)")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Day streak")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 6) {
                Text(todayRecord == nil ? "You have not checked in today" : "You cared for yourself today")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text("\(records.count) small moments of consistency so far. Check-ins and accumulated wishes unlock free growth skins.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)
            }
        }
        .mellowCard()
    }

    private var weekStrip: some View {
        HStack(spacing: 7) {
            ForEach(weekDays, id: \.key) { item in
                VStack(spacing: 6) {
                    Text(item.weekday)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                    ZStack {
                        Circle()
                            .fill(item.done ? AppTheme.lavenderDeep.opacity(0.88) : AppTheme.surface.opacity(0.7))
                            .frame(width: 32, height: 32)
                        if item.done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text(item.day)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    Text(item.isToday ? "Today" : " ")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .mellowCard(padding: 14, cornerRadius: 20)
    }

    private var achievementPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Which small thing would you like to complete today?", subtitle: "No ranking and no comparison")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                ForEach(viewModel.achievements, id: \.self) { achievement in
                    Button {
                        viewModel.selectedAchievement = achievement
                        HapticManager.shared.selection()
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: viewModel.selectedAchievement == achievement ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 13, weight: .medium))
                            Text(achievement)
                                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(viewModel.selectedAchievement == achievement ? AppTheme.lavenderDeep : AppTheme.secondaryText)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .background(
                            viewModel.selectedAchievement == achievement
                                ? AppTheme.lavender.opacity(0.13)
                                : AppTheme.surface.opacity(0.66),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(viewModel.selectedAchievement == achievement ? AppTheme.lavenderDeep.opacity(0.4) : AppTheme.separator, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mellowCard()
    }

    private var noteEditor: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionHeading(title: "Leave a note for yourself", subtitle: "Optional")
            TextField("What felt small and real today?", text: $viewModel.note, axis: .vertical)
                .lineLimit(3...6)
                .font(.mellowBody)
                .padding(13)
                .background(AppTheme.surface.opacity(0.75), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .mellowCard()
    }

    private var checkInButton: some View {
        Button {
            _ = viewModel.checkIn(profile: profile, records: records, context: context)
        } label: {
            Label("Record today's echo", systemImage: "checkmark.seal.fill")
        }
        .buttonStyle(MellowPrimaryButtonStyle())
        .disabled(todayRecord != nil)
    }

    private func completedCard(_ record: CheckInRecord) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 9) {
                IconBadge(systemName: "checkmark.seal.fill", tint: AppTheme.success, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's echo is saved")
                        .font(.mellowHeadline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Completed: \(record.achievement)")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            if !record.note.isEmpty {
                Text(record.note)
                    .font(.mellowBody)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)
            }
            Text("Once a day is enough. Give the rest of today back to yourself.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .mellowCard()
    }

    private var growthNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Growth unlocks", systemImage: "sparkles")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("3 cumulative check-ins unlock the Mist Glow card skin, 7 unlock Flower Letter, and 5 wishes on the wall unlock the Porcelain Moon wish-tube skin.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)
        }
        .mellowCard()
    }

    private struct WeekDay {
        let key: String
        let weekday: String
        let day: String
        let done: Bool
        let isToday: Bool
    }

    private var weekDays: [WeekDay] {
        let calendar = Calendar.current
        let keys = Set(records.map(\.dateKey))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let key = DateKey.string(from: date)
            return WeekDay(
                key: key,
                weekday: formatter.string(from: date),
                day: "\(calendar.component(.day, from: date))",
                done: keys.contains(key),
                isToday: calendar.isDateInToday(date)
            )
        }
    }
}