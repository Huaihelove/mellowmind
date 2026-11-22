import SwiftUI
import SwiftData

struct CollectionView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @Query(sort: \CollectItem.createdAt, order: .reverse) private var items: [CollectItem]
    @StateObject private var viewModel = CollectionViewModel()
    @State private var activeItem: CollectItem?

    private var filteredItems: [CollectItem] {
        viewModel.filtered(items)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                filterBar
                if filteredItems.isEmpty {
                    WarmEmptyState(
                        title: "No cards here yet",
                        message: "Tap Save on a mood card, healing wish, daily almanac, or anxiety reflection and it will appear in your healing album.",
                        systemImage: "heart.text.square"
                    )
                    .mellowCard()
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(filteredItems, id: \.id) { item in
                            collectionCard(item)
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: Binding(
            get: { activeItem != nil },
            set: { if !$0 { activeItem = nil } }
        )) {
            if let item = activeItem {
                CollectionDetailView(item: item) {
                    activeItem = nil
                }
            }
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
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved healing cards")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Keep the words that once helped you breathe a little easier.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge()
            }
            Text("\(items.count) saved \(items.count == 1 ? "item" : "items"). Everything stays on this device and can be deleted anytime.")
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", selected: viewModel.selectedKind == nil) {
                    viewModel.selectedKind = nil
                }
                ForEach(CollectionKind.allCases) { kind in
                    filterChip(title: kind.displayName, selected: viewModel.selectedKind == kind) {
                        viewModel.selectedKind = kind
                    }
                }
            }
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                action()
            }
            HapticManager.shared.selection()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(selected ? Color.white : AppTheme.secondaryText)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(selected ? AppTheme.lavenderDeep : AppTheme.surface.opacity(0.72), in: Capsule())
                .overlay(Capsule().stroke(selected ? Color.clear : AppTheme.separator, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func collectionCard(_ item: CollectItem) -> some View {
        Button {
            activeItem = item
            HapticManager.shared.softTap()
        } label: {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    IconBadge(systemName: item.kind.glyph, tint: tint(for: item.kind), size: 32)
                    Spacer()
                    Text(item.createdAt.formatted(.dateTime.month().day()))
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(item.body)
                    .font(.system(size: 11.5, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)
                    .lineLimit(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !item.keyword.isEmpty {
                    Text(item.keyword)
                        .font(.system(size: 9.5, weight: .medium, design: .rounded))
                        .foregroundStyle(tint(for: item.kind))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(tint(for: item.kind).opacity(0.1), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, minHeight: 188, alignment: .topLeading)
            .padding(14)
            .background(
                LinearGradient(colors: [tint(for: item.kind).opacity(0.10), AppTheme.surface.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(item, context: context)
            } label: {
                Label("Delete saved card", systemImage: "trash")
            }
        }
    }

    private func tint(for kind: CollectionKind) -> Color {
        switch kind {
        case .tarot: return AppTheme.lavenderDeep
        case .wish: return Color(hex: 0x8BA58D)
        case .star: return AppTheme.milkBlueDeep
        case .anxiety: return Color(hex: 0xC49C82)
        case .companion: return Color(hex: 0xB98FA5)
        }
    }
}

private struct CollectionDetailView: View {
    let item: CollectItem
    let onDeleted: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.kind.displayName)
                            .font(.mellowMicro)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(item.title)
                            .font(.mellowTitle)
                            .foregroundStyle(AppTheme.primaryText)
                    }
                    Spacer()
                    Button("Close") { dismiss() }
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                HStack(spacing: 7) {
                    MellowPill(text: item.kind.displayName, glyph: item.kind.glyph, tint: AppTheme.lavenderDeep)
                    if !item.keyword.isEmpty {
                        MellowPill(text: item.keyword, glyph: "sparkle", tint: AppTheme.milkBlueDeep)
                    }
                    Spacer()
                    Text(item.createdAt.formatted(.dateTime.year().month().day()))
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 9) {
                    if !item.subtitle.isEmpty {
                        Text(item.subtitle)
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    Text(item.body)
                        .font(.system(size: 15.5, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineSpacing(6)
                        .textSelection(.enabled)
                }
                .mellowCard()

                if !item.detail.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional reflection")
                            .font(.mellowHeadline)
                            .foregroundStyle(AppTheme.primaryText)
                        Text(item.detail)
                            .font(.mellowBody)
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineSpacing(5)
                            .textSelection(.enabled)
                    }
                    .mellowCard()
                }

                ShareLink(item: "\(item.title)\n\n\(item.body)\n\n— From \(AppTheme.appName)") {
                    Label("Share this card", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(MellowSecondaryButtonStyle())

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete this saved item", systemImage: "trash")
                }
                .buttonStyle(MellowSecondaryButtonStyle(tint: Color(hex: 0xB87575)))

                Text("Saved content is for personal emotional reflection only. It is not fate judgment, psychological diagnosis, or medical advice.")
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 22)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
        .confirmationDialog("Delete this saved item?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(item)
                try? context.save()
                HapticManager.shared.warning()
                onDeleted()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}