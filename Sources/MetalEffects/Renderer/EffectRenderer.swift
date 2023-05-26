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

    func draw(in view: MTKView) {
        guard let commandBuffer = renderHelper.commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        print("encode")
        renderHelper.renderPipeline.encode(with: encoder, texture: renderHelper.texture)
        
        encoder.endEncoding()
        
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
