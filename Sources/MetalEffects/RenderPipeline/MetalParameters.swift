//
//  MetalParameters.swift
//
//
//  Created by Tibor Felföldy on 2023-05-30.
//

import Metal

public protocol MetalParameters {
    var function: MTLFunction { get }
    var textures: [MTLTexture] { get }
}

// Default implementaions.
extension MetalParameters {
    var textures: [MTLTexture] { [] }
}
