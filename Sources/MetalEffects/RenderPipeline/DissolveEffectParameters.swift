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

struct DissolveEffectParameters: MetalParameters {
    let function: MTLFunction
    let textures: [MTLTexture]
    
    init(type: DissolveType) throws {
        let functionName = {
            switch type {
            case .noise:
                return "noise_dissolve"
            case .linear:
                return "linear_dissolve"
            }
        }()
        
        function = try {
            try RenderHelper.setupDevice()
            return RenderHelper.library.makeFunction(name: functionName)!
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
    @ViewBuilder func dissolve(value: Double, type: DissolveType = .noise) -> some View {
        if let parameters = try? DissolveEffectParameters(type: type) {
            MetalEffectView(parameters) {
                self
            }
            .effectAnimation(target: value)
        } else {
            self
        }
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
