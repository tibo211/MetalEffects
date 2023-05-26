//
//  MetalEffectView.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import SwiftUI

public struct MetalEffectView<Content: View>: View {
    @ViewBuilder public let content: () -> Content
    
    @State private var image: CGImage?
    
    public var body: some View {
        Group {
            content()
                .onAppear {
                    createImage()
                }
        }
    }
    
    @MainActor
    private func createImage() {
        let renderer = ImageRenderer(content: content())
        renderer.scale = 3
        image = renderer.cgImage
    }
}

struct MetalEffectsView_Previews: PreviewProvider {
    static var previews: some View {
        MetalEffectView {
            Text("Rendered in metal")
                .font(.title.bold())
                .foregroundColor(.white)
                .padding()
                .background(Color.blue.gradient)
                .cornerRadius(12)
        }
    }
}
