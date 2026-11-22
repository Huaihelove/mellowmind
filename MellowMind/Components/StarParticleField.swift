import SwiftUI

struct StarParticleSeed {
    let baseX: Double
    let baseY: Double
    let size: Double
    let speed: Double
    let phase: Double
    let drift: Double
    let opacity: Double
}

struct StarParticleField: View {
    let particles: [StarParticleSeed]
    let tint: Color

    init(count: Int = 54, tint: Color = .white) {
        self.tint = tint
        self.particles = (0..<count).map { index in
            let x = Double((index * 37 + 17) % 101) / 100
            let y = Double((index * 61 + 29) % 97) / 96
            let size = 1.2 + Double((index * 13) % 7) * 0.55
            let speed = 0.10 + Double((index * 19) % 13) * 0.018
            let phase = Double(index) * 0.73
            let drift = 8 + Double((index * 11) % 18)
            let opacity = 0.18 + Double((index * 7) % 8) * 0.065
            return StarParticleSeed(baseX: x, baseY: y, size: size, speed: speed, phase: phase, drift: drift, opacity: opacity)
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for particle in particles {
                    let oscillation = sin(time * particle.speed * 2.0 + particle.phase)
                    let vertical = cos(time * particle.speed * 1.37 + particle.phase)
                    let x = particle.baseX * size.width + oscillation * particle.drift
                    let y = particle.baseY * size.height + vertical * particle.drift * 0.7
                    let twinkle = 0.72 + 0.28 * sin(time * 1.4 + particle.phase)
                    let rect = CGRect(
                        x: x,
                        y: y,
                        width: particle.size * twinkle,
                        height: particle.size * twinkle
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(tint.opacity(particle.opacity * twinkle)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct StarlightConvergenceView: View {
    let onFinished: () -> Void

    @State private var progress: Double = 0
    @State private var flash = false

    private let particles: [(angle: Double, radius: Double, size: Double, delay: Double)] = (0..<56).map { index in
        let angle = Double(index) * (2 * .pi / 56) + Double(index % 5) * 0.12
        let radius = 0.58 + Double((index * 17) % 37) / 100
        let size = 1.5 + Double(index % 4) * 0.8
        let delay = Double(index % 9) * 0.025
        return (angle, radius, size, delay)
    }

    var body: some View {
        GeometryReader { proxy in
            let minSide = min(proxy.size.width, proxy.size.height)
            ZStack {
                Color.black.opacity(0.08)
                ForEach(Array(particles.enumerated()), id: \.offset) { _, particle in
                    let localProgress = min(max((progress - particle.delay) / (1 - particle.delay), 0), 1)
                    let radius = minSide * particle.radius * (1 - localProgress)
                    let x = proxy.size.width / 2 + cos(particle.angle) * radius
                    let y = proxy.size.height / 2 + sin(particle.angle) * radius
                    Circle()
                        .fill(Color.white)
                        .frame(width: particle.size, height: particle.size)
                        .shadow(color: AppTheme.lavender.opacity(0.8), radius: 8)
                        .position(x: x, y: y)
                        .opacity(localProgress > 0.92 ? (1 - localProgress) * 12 : 0.85)
                }

                Circle()
                    .fill(RadialGradient(colors: [Color.white.opacity(flash ? 0.92 : 0.10), AppTheme.lavender.opacity(flash ? 0.4 : 0.05), .clear], center: .center, startRadius: 0, endRadius: 150))
                    .frame(width: 300, height: 300)
                    .scaleEffect(flash ? 1.7 : 0.2)
                    .opacity(flash ? 0.85 : 0.3)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.15)) {
                progress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                withAnimation(.easeOut(duration: 0.35)) {
                    flash = true
                }
                HapticManager.shared.success()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.42) {
                onFinished()
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct FloatingOrb: View {
    var tint: Color = AppTheme.lavender
    var size: CGFloat = 160
    @State private var floating = false

    var body: some View {
        Circle()
            .fill(RadialGradient(colors: [tint.opacity(0.52), tint.opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: size / 2))
            .frame(width: size, height: size)
            .blur(radius: 2)
            .offset(y: floating ? -10 : 10)
            .scaleEffect(floating ? 1.04 : 0.97)
            .onAppear {
                withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
                    floating = true
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}