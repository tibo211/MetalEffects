//
//  EffectAnimation.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-31.
//

import SwiftUI

public protocol EffectAnimation {
    var time: Float32 { get }
}

struct EffectAnimationEnvironmentKey: EnvironmentKey {
    static var defaultValue: EffectAnimation {
        ContinuousEffectAnimation()
    }
}

public extension EnvironmentValues {
    var effectAnimation: EffectAnimation {
        get { self[EffectAnimationEnvironmentKey.self] }
        set { self[EffectAnimationEnvironmentKey.self] = newValue }
    }
}

// MARK: - Default animations.

final class ContinuousEffectAnimation: EffectAnimation {
    private let initialTime = CFAbsoluteTimeGetCurrent()
    
    var time: Float32 {
        Float32(CFAbsoluteTimeGetCurrent() - initialTime)
    }
}

class ToggleEffectAnimation: EffectAnimation {
    var time: Float32 = 0.0
    private var timer: Timer?

    var targetTime: Float32 = 0.0 {
        didSet {
            timer?.invalidate()
            let duration = abs(targetTime - time)
            // Make it 120 fps.
            let interval = duration / 120.0
            let increment = (targetTime > time) ? interval : -interval
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                self.time += increment
                if (increment > 0 && self.time >= self.targetTime) || (increment < 0 && self.time <= self.targetTime) {
                    timer.invalidate()
                }
            }
        }
    }
}
