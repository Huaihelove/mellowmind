import Foundation
import CoreMotion
import Combine

// MARK: - Module 3: Shaking the wish tube
// Uses the accelerometer to identify intentional shaking only while the wish-tube page is open. Motion data is never stored or uploaded.

final class ShakeDetector: ObservableObject {
    @Published private(set) var shakeCount = 0
    @Published private(set) var isRunning = false

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var lastShakeAt = Date.distantPast
    private let threshold: Double = 2.15
    private let cooldown: TimeInterval = 0.38

    func start() {
        guard motionManager.isAccelerometerAvailable, !isRunning else { return }
        queue.maxConcurrentOperationCount = 1
        motionManager.accelerometerUpdateInterval = 0.06
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let self, let acceleration = data?.acceleration else { return }
            let magnitude = sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )
            guard magnitude > self.threshold else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastShakeAt) > self.cooldown else { return }
            self.lastShakeAt = now
            DispatchQueue.main.async {
                self.shakeCount += 1
                Task { @MainActor in
                    HapticManager.shared.heavyTap()
                }
            }
        }
        isRunning = true
    }

    func stop() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
    }

    func reset() {
        shakeCount = 0
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}