//
//  EffectParameters.swift
//
//
//  Created by Tibor Felföldy on 2023-05-30.
//

import Metal

public protocol EffectParameters {
    var library: MTLLibrary? { get }
    var function: String { get }
    var textures: [MTLTexture] { get }
}

// Default implementaions.
extension EffectParameters {
    var textures: [MTLTexture] { [] }
}
