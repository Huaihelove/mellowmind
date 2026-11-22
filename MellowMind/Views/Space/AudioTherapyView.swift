import SwiftUI

struct AudioTherapyView: View {
    let profile: UserProfile
    let settings: AppSettings

    @StateObject private var player = AudioPlayerService()
    @State private var breathing = false

    private var selectedTrack: AudioTrack? { player.currentTrack }

    var body: some View {
        ZStack {
            MellowBackground()
            StarParticleField(count: 38, tint: AppTheme.milkBlue)
                .opacity(0.42)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    nowPlayingCard
                    trackList
                    breathingCard
                    privacyNote
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            player.setVolume(profile.audioVolume)
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                breathing = true
            }
        }
        .onDisappear {
            player.stop()
        }
        .alert("Audio notice", isPresented: Binding(
            get: { player.errorMessage != nil },
            set: { if !$0 { player.errorMessage = nil } }
        )) {
            Button("Got it", role: .cancel) { player.errorMessage = nil }
        } message: {
            Text(player.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Relaxation Audio")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("Let a piece of sound slowly lower today's tension.")
                        .font(.mellowBody)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                PrivacyBadge(text: "Local audio")
            }
            HStack(spacing: 7) {
                MellowPill(text: "White noise", glyph: "cloud.rain", tint: AppTheme.milkBlueDeep)
                MellowPill(text: "Light meditation", glyph: "moon.stars", tint: AppTheme.lavenderDeep)
                MellowPill(text: "No ads", glyph: "hand.raised.fill", tint: AppTheme.success)
            }
            Text("Audio therapy is for everyday relaxation and scene-setting. It does not replace medical care or psychological treatment.")
                .font(.mellowMicro)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var nowPlayingCard: some View {
        VStack(spacing: 16) {
            ZStack {
                FloatingOrb(tint: selectedTrack.map { Color(hexString: $0.accentHex) } ?? AppTheme.lavender, size: 190)
                    .scaleEffect(player.isPlaying ? (breathing ? 1.08 : 0.96) : 1)
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 126, height: 126)
                    .overlay(Circle().stroke((selectedTrack.map { Color(hexString: $0.accentHex) } ?? AppTheme.lavender).opacity(0.25), lineWidth: 1))
                Image(systemName: selectedTrack?.glyph ?? "waveform")
                    .font(.system(size: 38, weight: .ultraLight))
                    .foregroundStyle(selectedTrack.map { Color(hexString: $0.accentHex) } ?? AppTheme.lavenderDeep)
            }
            .frame(height: 180)

            VStack(spacing: 4) {
                Text(selectedTrack?.title ?? "Choose a sound")
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                Text(selectedTrack?.subtitle ?? "Put on headphones, or simply lower the volume")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            AudioWaveView(isPlaying: player.isPlaying, tint: selectedTrack.map { Color(hexString: $0.accentHex) } ?? AppTheme.lavenderDeep)

            if selectedTrack != nil {
                VStack(spacing: 5) {
                    Slider(value: Binding(
                        get: { player.duration > 0 ? player.elapsed / player.duration : 0 },
                        set: { player.seek(to: $0) }
                    ), in: 0...1)
                    .tint(selectedTrack.map { Color(hexString: $0.accentHex) } ?? AppTheme.lavenderDeep)
                    HStack {
                        Text(player.elapsedText)
                        Spacer()
                        Text(player.durationText)
                    }
                    .font(.mellowMicro)
                    .foregroundStyle(AppTheme.secondaryText)
                }
            }

            HStack(spacing: 24) {
                Button {
                    player.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.surface.opacity(0.72), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Stop playback")

                Button {
                    if let selectedTrack {
                        player.toggle()
                    } else if let first = AudioPlayerService.tracks.first {
                        player.play(track: first)
                    }
                } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            LinearGradient(colors: [AppTheme.lavenderDeep, AppTheme.milkBlueDeep], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Circle()
                        )
                        .shadow(color: AppTheme.lavenderDeep.opacity(0.25), radius: 12, x: 0, y: 7)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(player.isPlaying ? "Pause" : "Play")

                Button {
                    playNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.surface.opacity(0.72), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next track")
            }

            HStack(spacing: 9) {
                Image(systemName: "speaker.wave.1")
                    .foregroundStyle(AppTheme.secondaryText)
                Slider(value: Binding(
                    get: { player.volume },
                    set: { player.setVolume($0) }
                ), in: 0...1)
                .tint(AppTheme.lavenderDeep)
                Image(systemName: "speaker.wave.3")
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .font(.system(size: 12))
        }
        .mellowCard()
    }

    private var trackList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Sound scenes", subtitle: "All resources are bundled locally with the app")
            ForEach(AudioPlayerService.tracks) { track in
                Button {
                    player.play(track: track)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(Color(hexString: track.accentHex).opacity(0.14))
                                .frame(width: 44, height: 44)
                            Image(systemName: track.glyph)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color(hexString: track.accentHex))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(track.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(track.subtitle)
                                .font(.mellowMicro)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        Spacer()
                        if selectedTrack?.id == track.id {
                            AudioWaveView(isPlaying: player.isPlaying, tint: Color(hexString: track.accentHex))
                                .frame(width: 50)
                        } else {
                            Image(systemName: "play.circle")
                                .font(.system(size: 21, weight: .light))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    .padding(.vertical, 7)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .mellowCard()
    }

    private var breathingCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [AppTheme.lavender.opacity(0.34), .clear], center: .center, startRadius: 0, endRadius: 55))
                    .frame(width: 106, height: 106)
                    .scaleEffect(breathing ? 1.05 : 0.88)
                Text(breathing ? "Breathe out" : "Breathe in")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.lavenderDeep)
            }
            .frame(width: 106, height: 106)
            VStack(alignment: .leading, spacing: 5) {
                Text("Breathe slowly with the sound")
                    .font(.mellowHeadline)
                    .foregroundStyle(AppTheme.primaryText)
                Text("Inhale for four counts and exhale for six. If you feel dizzy or unwell, stop and return to natural breathing.")
                    .font(.mellowCaption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(3)
            }
        }
        .mellowCard()
    }

    private var privacyNote: some View {
        Text("Audio playback needs no microphone or media-library permission. The app does not record audio or read your music library.")
            .font(.mellowMicro)
            .foregroundStyle(AppTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    private func playNext() {
        let tracks = AudioPlayerService.tracks
        guard !tracks.isEmpty else { return }
        let currentIndex = selectedTrack.flatMap { track in tracks.firstIndex(where: { $0.id == track.id }) } ?? -1
        let nextIndex = (currentIndex + 1) % tracks.count
        player.play(track: tracks[nextIndex])
    }
}