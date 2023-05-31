//
//  DissolveEffectParameters.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-30.
//

import MetalKit
import SwiftUI

public enum DissolveType {
    case linear
    case noise
}

struct DissolveEffectParameters: EffectParameters {
    let library: MTLLibrary? = nil
    let function: String
    let textures: [MTLTexture]
    
    init(type: DissolveType) {
        function = {
            switch type {
            case .noise:
                return "noise_dissolve"
            case .linear:
                return "linear_dissolve"
            }
        }()
        
        textures = {
            switch type {
            case .linear:
                return []
            case .noise:
                let url = Bundle.module.url(forResource: "noise", withExtension: "png")!
                guard let device = MTLCreateSystemDefaultDevice(),
                      let texture = try? MTKTextureLoader(device: device).newTexture(URL: url)
                else { return [] }
                return [texture]
            }
        }()
    }
}

// MARK: - Dissolve view modifier.

public extension View {
    func dissolve(value: Double, type: DissolveType = .noise) -> some View {
        MetalEffectView(DissolveEffectParameters(type: type)) {
            self
        }
        .effectAnimation(target: value)
    }
    
    func dissolve(isOn: Bool, type: DissolveType = .noise) -> some View {
        dissolve(value: isOn ? 1 : 0, type: type)
    }
}

struct DissolveEffectParameters_Previews: PreviewProvider {
    static var previews: some View {
        Text("text\nto\ndissolve")
            .multilineTextAlignment(.center)
            .font(.largeTitle.bold())
            .foregroundColor(.white)
            .padding()
            .dissolve(value: 1)
            .background(.black)
    }
}
