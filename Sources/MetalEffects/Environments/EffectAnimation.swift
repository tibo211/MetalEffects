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
