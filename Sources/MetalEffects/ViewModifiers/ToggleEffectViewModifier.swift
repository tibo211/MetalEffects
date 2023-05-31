//
//  ToggleEffectViewModifier.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-31.
//

import SwiftUI

struct ToggleEffectModifier: ViewModifier {
    let target: Double
    
    @State private var animation = ToggleEffectAnimation()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: target) { newValue in
                animation.targetTime = Float32(newValue)
            }
            .environment(\.effectAnimation, animation)
    }
}

public extension View {
    func effectAnimation(target: Double) -> some View {
        modifier(ToggleEffectModifier(target: target))
    }
}
