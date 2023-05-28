//
//  MetalEffectView.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import SwiftUI

public struct MetalEffectView<Content: View>: View {
    let content: Content
    let helper: RenderHelper?
    
    @ObservedObject private var imageRenderer: ImageRenderer<Content>
    
    @MainActor
    public init(_ function: FragmentFunction, @ViewBuilder content: () -> Content) {
        let view = content()
        self.content = view
        imageRenderer = ImageRenderer(content: view)
        do {
            helper = try RenderHelper(function: function)
        } catch {
            print(error.localizedDescription)
            helper = nil
        }
        renderImage()
    }
    
    public var body: some View {
        Group {
            if let helper, let size = helper.size {
                MetalView(renderHelper: helper)
                    .frame(width: size.width,
                           height: size.height)
            } else {
                content
            }
        }
        .onReceive(imageRenderer.objectWillChange) {
            renderImage()
        }
    }
    
    private func renderImage() {
        if let image = imageRenderer.cgImage {
            do {
                try helper?.updateTexture(from: image)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct MetalEffectsView_Previews: PreviewProvider {
    struct ExampleView: View {
        var body: some View {
            ZStack {
                Rectangle().fill(.blue.gradient)
                
                Text("Rendered in metal")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            .frame(width: 200, height: 200)
        }
    }
    
    
    static var previews: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                MetalEffectView(.water_fragment) {
                    ExampleView()
                }
                
                MetalEffectView(.flame_fragment) {
                    ExampleView()
                }
            }
            GridRow {
                MetalEffectView(.linear_dissolve) {
                    VStack {
                        Text("TEXT")
                        Text("TO")
                        Text("DISSOLVE")
                    }
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                }
                
                MetalEffectView(.wave_fragment) {
                    ExampleView()
                }
            }
        }
    }
}
