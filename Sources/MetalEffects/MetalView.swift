//
//  MetalView.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import SwiftUI
import MetalKit

extension MTKView {
    static func make(renderer: EffectRenderer) -> MTKView {
        let view = MTKView()
        view.device = renderer.renderHelper.device
        view.delegate = renderer
        view.clearColor = MTLClearColor(red: 1, green: 0, blue: 1, alpha: 1)
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = true
        return view
    }
}

#if os(macOS)
struct MetalView: NSViewRepresentable {
    let renderHelper: RenderHelper
    
    func makeNSView(context: Context) -> MTKView {
        .make(renderer: context.coordinator)
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
    
    func makeCoordinator() -> EffectRenderer {
        EffectRenderer(helper: renderHelper)
    }
}
#else
struct MetalView: UIViewRepresentable {
    let renderHelper: RenderHelper
    
    func makeUIView(context: Context) -> MTKView {
        .make(renderer: context.coordinator)
    }
    
    func updateUIView(_ view: MTKView, context: Context) {}
    
    func makeCoordinator() -> EffectRenderer {
        EffectRenderer(helper: renderHelper)
    }
}
#endif
