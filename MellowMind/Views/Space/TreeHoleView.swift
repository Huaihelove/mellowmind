import SwiftUI
import SwiftData

struct TreeHoleView: View {
    let profile: UserProfile
    let settings: AppSettings

    @Environment(\.modelContext) private var context
    @Query(sort: \EmotionJournalEntry.createdAt, order: .forward) private var entries: [EmotionJournalEntry]
    @StateObject private var viewModel = TreeHoleViewModel()
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            MellowBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if viewModel.messages.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.messages) { message in
                                chatBubble(message)
                                    .id(message.id)
                            }
                        }
                        if viewModel.isTyping {
                            typingBubble
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: viewModel.isTyping) { _, _ in
                    scrollToBottom(proxy)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            composer
        }
        .task {
            viewModel.loadHistory(entries: entries)
        }
        .onDisappear {
            viewModel.cancelPending()
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tree Hollow")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Write anonymously and receive a gentle local reply")
                        .font(.mellowCaption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge(text: "Anonymous · Local")
            }
            HStack(spacing: 7) {
                MellowPill(text: "No judgment", glyph: "heart", tint: AppTheme.success)
                MellowPill(text: "Offline", glyph: "wifi.slash", tint: AppTheme.lavenderDeep)
                MellowPill(text: "Not diagnosis", glyph: "cross.case", tint: AppTheme.milkBlueDeep)
            }
            Text("If you are having thoughts of hurting yourself, contact local emergency services or a crisis line immediately, or ask someone you trust to stay with you.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.warning.opacity(0.08), in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            if viewModel.lastCompanionReply != nil {
                Button {
                    _ = viewModel.collectLastExchange(context: context)
                } label: {
                    Label(viewModel.collectionSaved ? "Reply saved" : "Save this reply", systemImage: viewModel.collectionSaved ? "heart.fill" : "heart")
                }
                .font(.mellowCaption)
                .foregroundStyle(AppTheme.lavenderDeep)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                FloatingOrb(tint: AppTheme.lavender, size: 180)
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 42, weight: .ultraLight))
                    .foregroundStyle(AppTheme.lavenderDeep)
            }
            .frame(height: 170)

            Text("There is no audience here")
                .font(.mellowHeadline)
                .foregroundStyle(AppTheme.primaryText)
            Text("You can write what you do not know how to say to anyone, or what you fear will be misunderstood. It does not need to be organized.")
                .font(.mellowBody)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(spacing: 8) {
                promptButton("I have been feeling tired lately, but I cannot explain why")
                promptButton("I am always afraid of disappointing people")
                promptButton("At night, my mind will not stop")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private func promptButton(_ text: String) -> some View {
        Button {
            viewModel.draft = text
            inputFocused = true
            HapticManager.shared.softTap()
        } label: {
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(AppTheme.surface.opacity(0.7), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user { Spacer(minLength: 44) }

            if message.role == .companion {
                ZStack {
                    Circle()
                        .fill(AppTheme.lavender.opacity(0.16))
                        .frame(width: 30, height: 30)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.lavenderDeep)
                }
            }

            Text(message.text)
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundStyle(message.role == .user ? Color.white : AppTheme.primaryText)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    message.role == .user
                        ? AnyShapeStyle(LinearGradient(colors: [AppTheme.lavenderDeep, AppTheme.milkBlueDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(AppTheme.surface.opacity(0.82)),
                    in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(message.role == .user ? Color.white.opacity(0.15) : AppTheme.separator, lineWidth: 1)
                )

            if message.role == .companion { Spacer(minLength: 30) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.role == .user ? "Me: \(message.text)" : "Tree Hollow reply: \(message.text)")
    }

    private var typingBubble: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.lavender.opacity(0.16))
                    .frame(width: 30, height: 30)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.lavenderDeep)
            }
            HStack {
                TypingDots()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(AppTheme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            Spacer(minLength: 40)
        }
    }

    private var composer: some View {
        VStack(spacing: 0) {
            DividerSoft()
            HStack(alignment: .bottom, spacing: 9) {
                TextField("Write a little of what you feel...", text: $viewModel.draft, axis: .vertical)
                    .focused($inputFocused)
                    .lineLimit(1...4)
                    .font(.mellowBody)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 11)
                    .background(AppTheme.surface.opacity(0.86), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onSubmit {
                        viewModel.send(profile: profile, context: context)
                    }

                Button {
                    viewModel.send(profile: profile, context: context)
                    inputFocused = false
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 33))
                        .foregroundStyle(viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.secondaryText.opacity(0.4) : AppTheme.lavenderDeep)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTyping)
                .accessibilityLabel("Send to Tree Hollow")
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.28)) {
                if viewModel.isTyping {
                    proxy.scrollTo("typing", anchor: .bottom)
                } else if let last = viewModel.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}