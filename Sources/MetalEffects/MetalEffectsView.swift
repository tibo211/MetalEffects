//
//  MetalEffectView.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import SwiftUI

public struct MetalEffectView<Content: View>: View {
    let helper: RenderHelper?
    
    @ObservedObject private var imageRenderer: ImageRenderer<Content>
    
    public init(_ effectParameters: EffectParameters, @ViewBuilder content: () -> Content) {
        let imageRenderer = ImageRenderer(content: content())
        imageRenderer.scale = 3
        self.imageRenderer = imageRenderer

        do {
            helper = try RenderHelper(parameters: effectParameters)
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
                imageRenderer.content
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
            VStack {
                Text("TEXT")
                Text("TO")
                Text("DISSOLVE")
            }
            .font(.largeTitle.bold())
            .foregroundColor(.white)
            .frame(width: 200, height: 200)
        }
    }
    
    static var previews: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                ExampleView()
                    .dissolve(.noise)
                    .frame(width: 200, height: 200)
                
                ExampleView()
                    .dissolve(.linear)
                    .frame(width: 200, height: 200)
            }
        }
        .background(.black)
    }
}
