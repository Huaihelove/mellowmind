import Foundation
import AVFoundation
import Combine

// MARK: - Module 5: Relaxation audio player
// Audio is bundled locally with the app and does not require the network. Playback needs no microphone or media-library permission.

@MainActor
final class AudioPlayerService: NSObject, ObservableObject {
    static let tracks: [AudioTrack] = [
        AudioTrack(id: "rain", title: "Cloud Rain", subtitle: "Soft rain for putting the screen down", fileName: "cloud_rain", glyph: "cloud.rain", accentHex: "9FB8C8"),
        AudioTrack(id: "breath", title: "Moonlight Breath", subtitle: "A slow soundscape for three deep breaths", fileName: "moon_breath", glyph: "moon.stars", accentHex: "B7A6D4"),
        AudioTrack(id: "stream", title: "Quiet Stream", subtitle: "Flowing water for sorting your thoughts", fileName: "quiet_stream", glyph: "water.waves", accentHex: "8FB8B6"),
        AudioTrack(id: "hearth", title: "Late-Night Hearth", subtitle: "Warm crackle for winding down before sleep", fileName: "soft_hearth", glyph: "flame", accentHex: "C79278")
    ]

    @Published private(set) var currentTrack: AudioTrack?
    @Published private(set) var isPlaying = false
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var volume: Double = 0.55 {
        didSet { player?.volume = Float(volume) }
    }
    @Published var errorMessage: String?

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    func play(track: AudioTrack) {
        if currentTrack?.id == track.id {
            toggle()
            return
        }

        stop()
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "wav") else {
            errorMessage = "The local audio file \(track.fileName).wav could not be found."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = Float(volume)
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
            currentTrack = track
            duration = newPlayer.duration
            elapsed = 0
            isPlaying = true
            errorMessage = nil
            startTimer()
            HapticManager.shared.softTap()
        } catch {
            errorMessage = "Audio cannot play right now: \(error.localizedDescription)"
        }
    }

    func toggle() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            progressTimer?.invalidate()
        } else {
            player.play()
            isPlaying = true
            startTimer()
            HapticManager.shared.softTap()
        }
    }

    func seek(to fraction: Double) {
        guard let player else { return }
        let clamped = min(max(fraction, 0), 1)
        player.currentTime = player.duration * clamped
        elapsed = player.currentTime
    }

    func setVolume(_ value: Double) {
        volume = min(max(value, 0), 1)
    }

    func stop() {
        progressTimer?.invalidate()
        progressTimer = nil
        player?.stop()
        player = nil
        isPlaying = false
        elapsed = 0
        duration = 0
        currentTrack = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private func startTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let player = self.player else { return }
                self.elapsed = player.currentTime
                if !player.isPlaying, self.isPlaying {
                    self.isPlaying = false
                }
            }
        }
    }

    var elapsedText: String {
        timeText(elapsed)
    }

    var durationText: String {
        timeText(duration)
    }

    private func timeText(_ time: TimeInterval) -> String {
        guard time.isFinite, time >= 0 else { return "0:00" }
        let seconds = Int(time)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}