import SwiftUI
import SwiftData

struct WishWallView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = WishWallViewModel()
    @Query(sort: \Wish.createdAt, order: .reverse) private var wishes: [Wish]
    @State private var commentWish: Wish?

    private var visibleWishes: [Wish] {
        wishes.filter { !$0.isHidden }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if visibleWishes.isEmpty {
                    WarmEmptyState(
                        title: "The wish wall is still quiet",
                        message: "Write the first wish. It stays on this device, and you do not have to prove anything to anyone.",
                        systemImage: "heart.text.square"
                    )
                    .mellowCard()
                } else {
                    ForEach(visibleWishes, id: \.id) { wish in
                        wishCard(wish)
                    }
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.configure(profile: profile)
        }
        .sheet(isPresented: $viewModel.isComposerPresented) {
            WishComposerSheet(
                viewModel: viewModel,
                profile: profile,
                context: context
            )
        }
        .sheet(isPresented: Binding(
            get: { commentWish != nil },
            set: { if !$0 { commentWish = nil } }
        )) {
            if let wish = commentWish {
                WishCommentsSheet(
                    wish: wish,
                    viewModel: viewModel,
                    profile: profile,
                    context: context
                )
            }
        }
        .alert("Notice", isPresented: Binding(
            get: { viewModel.feedback != nil && !viewModel.isComposerPresented && commentWish == nil },
            set: { if !$0 { viewModel.feedback = nil } }
        )) {
            Button("Got it", role: .cancel) { viewModel.feedback = nil }
        } message: {
            Text(viewModel.feedback ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Wish Wall")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Even an anonymous worry can be met with warmth.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge()
            }

            HStack(spacing: 7) {
                MellowPill(text: "Local circle", glyph: "iphone", tint: AppTheme.lavenderDeep)
                MellowPill(text: "Anonymous available", glyph: "eye.slash", tint: AppTheme.milkBlueDeep)
                MellowPill(text: "No comparison", glyph: "heart", tint: AppTheme.success)
            }

            Button {
                viewModel.isComposerPresented = true
                HapticManager.shared.softTap()
            } label: {
                Label("Write a wish", systemImage: "square.and.pencil")
            }
            .buttonStyle(MellowPrimaryButtonStyle())

            Text("Sample wishes are marked 'Sample warmth'. If content feels uncomfortable, use the menu to report and hide it.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private func wishCard(_ wish: Wish) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hexString: wish.theme.accentHex).opacity(0.32), AppTheme.milkBlue.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 38, height: 38)
                    Text(String(wish.displayAuthor.prefix(1)))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(wish.displayAuthor)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                        if wish.isSeed {
                            MellowPill(text: "Sample warmth", tint: AppTheme.secondaryText)
                        }
                    }
                    Text(wish.createdAt.formatted(.relative(presentation: .named)))
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        viewModel.report(wish, context: context)
                    } label: {
                        Label("Report and hide", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 30, height: 30)
                }
            }

            Text(wish.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 9) {
                MellowPill(text: wish.theme.rawValue, glyph: wish.theme.glyph, tint: Color(hexString: wish.theme.accentHex))
                Spacer()
                Button {
                    viewModel.toggleLike(wish, context: context)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: wish.likedByMe ? "heart.fill" : "heart")
                        Text("\(wish.likeCount)")
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(wish.likedByMe ? AppTheme.mistRose : AppTheme.secondaryText)
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.commentDraft = ""
                    viewModel.feedback = nil
                    commentWish = wish
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left")
                        Text("\(wish.comments.count)")
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .mellowCard()
    }
}

private struct WishComposerSheet: View {
    @ObservedObject var viewModel: WishWallViewModel
    let profile: UserProfile
    let context: ModelContext

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Write a wish")
                        .font(.mellowTitle)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Stored only on this device. Nothing is uploaded.")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Button("Close") { dismiss() }
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            ZStack(alignment: .topLeading) {
                if viewModel.draft.isEmpty {
                    Text("What do you most want to say to yourself right now?")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.7))
                        .padding(16)
                }
                TextEditor(text: $viewModel.draft)
                    .focused($focused)
                    .font(.mellowBody)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 170)
            }
            .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.lavender.opacity(0.18), lineWidth: 1)
            )

            HStack {
                Toggle(isOn: $viewModel.isAnonymous) {
                    Label("Post anonymously", systemImage: viewModel.isAnonymous ? "eye.slash" : "person")
                        .font(.mellowCaption)
                }
                .tint(AppTheme.lavenderDeep)
                .labelsHidden()
                .frame(width: 44)
                Text(viewModel.isAnonymous ? "Post anonymously" : "Post as \(profile.displayName)")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("\(viewModel.draft.count)/\(ContentModerationService.wishLimit)")
                    .font(.mellowMicro)
                    .foregroundStyle(viewModel.draft.count > ContentModerationService.wishLimit ? Color.red : AppTheme.secondaryText)
            }

            if let feedback = viewModel.feedback {
                Text(feedback)
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.warning)
            }

            Button {
                if viewModel.post(profile: profile, context: context) {
                    dismiss()
                }
            } label: {
                Label("Post gently", systemImage: "paperplane.fill")
            }
            .buttonStyle(MellowPrimaryButtonStyle())

            Text("Please stay kind. This space does not accept attacks, humiliation, or harmful expression, and it makes no fate or future claims.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 22)
        .padding(.bottom, 12)
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
        .onAppear { focused = true }
    }
}

private struct WishCommentsSheet: View {
    let wish: Wish
    @ObservedObject var viewModel: WishWallViewModel
    let profile: UserProfile
    let context: ModelContext

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Warm comments")
                        .font(.mellowTitle)
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Leave a little warmth for this wish")
                        .font(.mellowMicro)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Button("Close") { dismiss() }
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.vertical, 16)

            DividerSoft()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(wish.content)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineSpacing(4)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.surface.opacity(0.75), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if wish.comments.isEmpty {
                        Text("No comments yet. Your first sentence can be the warmth it needs.")
                            .font(.mellowCaption)
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(wish.comments) { comment in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(comment.author)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppTheme.lavenderDeep)
                                    Spacer()
                                    Text(comment.createdAt.formatted(.relative(presentation: .named)))
                                        .font(.mellowMicro)
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                                Text(comment.content)
                                    .font(.mellowBody)
                                    .foregroundStyle(AppTheme.primaryText)
                                    .lineSpacing(3)
                            }
                            .padding(13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surface.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.vertical, 16)
            }

            DividerSoft()

            HStack(spacing: 10) {
                TextField("Write a kind, nonjudgmental note...", text: $viewModel.commentDraft, axis: .vertical)
                    .focused($focused)
                    .lineLimit(1...3)
                    .font(.mellowBody)
                    .padding(12)
                    .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Button {
                    _ = viewModel.addComment(to: wish, profile: profile, context: context)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Send comment")
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.vertical, 12)

            if let feedback = viewModel.feedback {
                Text(feedback)
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.warning)
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.bottom, 6)
            }
        }
        .background(MellowBackground())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComplianceFooter()
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            viewModel.commentDraft = ""
            focused = true
        }
    }
}