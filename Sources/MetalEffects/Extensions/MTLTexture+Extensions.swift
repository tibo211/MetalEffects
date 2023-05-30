//
//  MTLTexture+Extensions.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-30.
//

import MetalKit

extension MTLTexture {
    static func loadNoise(device: MTLDevice) throws -> MTLTexture {
        try MTKTextureLoader(device: device)
            .newTexture(name: "noise.png", scaleFactor: 1, bundle: .module)
    }
}
