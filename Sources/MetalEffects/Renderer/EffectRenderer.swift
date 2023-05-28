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
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.isPaused = false
    }

    func draw(in view: MTKView) {
        guard let baseTexture = renderHelper.texture,
              let commandBuffer = renderHelper.commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        renderHelper.renderPipeline.encode(with: encoder, texture: baseTexture)
        
        encoder.endEncoding()
        
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
