//
//  EffectRenderer.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import MetalKit

class EffectRenderer: NSObject, MTKViewDelegate {
    let renderHelper: RenderHelper
    
    init(helper: RenderHelper) {
        renderHelper = helper
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    func draw(in view: MTKView) {}
}
