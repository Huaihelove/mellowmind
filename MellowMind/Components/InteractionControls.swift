import SwiftUI
import UIKit

struct SlideToUnlock: View {
    let title: String
    let onUnlock: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var hasCompleted = false

    var body: some View {
        GeometryReader { proxy in
            let height: CGFloat = 58
            let knob: CGFloat = 48
            let maxOffset = max(1, proxy.size.width - knob - 8)
            let threshold = maxOffset * 0.68

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().stroke(AppTheme.lavender.opacity(0.24), lineWidth: 1))
                    .frame(height: height)

                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .opacity(1 - Double(min(dragOffset / threshold, 1)) * 0.72)

                HStack {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AppTheme.lavender, AppTheme.milkBlueDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: AppTheme.lavenderDeep.opacity(0.28), radius: 8, x: 0, y: 4)
                        Image(systemName: "chevron.right.2")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: knob, height: knob)
                    .padding(5)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged { value in
                                guard !hasCompleted else { return }
                                dragOffset = min(max(0, value.translation.width), maxOffset)
                                if dragOffset > 8 {
                                    HapticManager.shared.softTap()
                                }
                            }
                            .onEnded { _ in
                                guard !hasCompleted else { return }
                                if dragOffset >= threshold {
                                    complete(maxOffset: maxOffset)
                                } else {
                                    withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
            }
            .frame(height: height)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityHint("Swipe right to complete")
            .accessibilityAction {
                complete(maxOffset: maxOffset)
            }
        }
        .frame(height: 58)
    }

    private func complete(maxOffset: CGFloat) {
        guard !hasCompleted else { return }
        hasCompleted = true
        withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
            dragOffset = maxOffset
        }
        HapticManager.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onUnlock()
        }
    }
}

struct HoldProgressButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var duration: Double = 2.4
    var tint: Color = AppTheme.lavender
    let onStart: (() -> Void)?
    let onComplete: () -> Void

    @State private var progress: Double = 0
    @State private var isPressing = false
    @State private var hasCompleted = false
    @State private var holdTask: Task<Void, Never>?

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        duration: Double = 2.4,
        tint: Color = AppTheme.lavender,
        onStart: (() -> Void)? = nil,
        onComplete: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.duration = duration
        self.tint = tint
        self.onStart = onStart
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(AppTheme.separator, lineWidth: 2)
                    .frame(width: 148, height: 148)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(LinearGradient(colors: [tint, AppTheme.milkBlueDeep], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 148, height: 148)
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 126, height: 126)
                    .overlay(Circle().stroke(tint.opacity(0.20), lineWidth: 1))
                VStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(tint)
                        .symbolEffect(.pulse, isActive: isPressing)
                    Text(isPressing ? "Keep holding..." : title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
            }
            .scaleEffect(isPressing ? 1.025 : 1)
            .animation(AppTheme.gentleEase, value: isPressing)

            Text(subtitle)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    beginHold()
                }
                .onEnded { _ in
                    cancelHold()
                }
        )
        .onDisappear {
            cancelHold()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Press and hold to gather energy")
        .accessibilityAction {
            beginHold()
        }
    }

    private func beginHold() {
        guard !isPressing, !hasCompleted else { return }
        isPressing = true
        onStart?()
        HapticManager.shared.prepare()
        HapticManager.shared.lightTap()
        let startedAt = Date()
        holdTask?.cancel()
        holdTask = Task { @MainActor in
            while !Task.isCancelled {
                let value = min(1, Date().timeIntervalSince(startedAt) / max(duration, 0.2))
                progress = value
                if value >= 1 {
                    finish()
                    return
                }
                try? await Task.sleep(nanoseconds: 32_000_000)
            }
        }
    }

    private func finish() {
        guard !hasCompleted else { return }
        hasCompleted = true
        isPressing = false
        progress = 1
        HapticManager.shared.success()
        onComplete()
    }

    private func cancelHold() {
        guard !hasCompleted else { return }
        holdTask?.cancel()
        holdTask = nil
        if isPressing {
            isPressing = false
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                progress = 0
            }
        }
    }
}