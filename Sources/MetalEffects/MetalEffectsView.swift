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
    
    @MainActor
    init(@ViewBuilder content: () -> Content) {
        let view = content()
        self.content = view
        do {
            helper = try RenderHelper(content: view)
        } catch {
            print(error.localizedDescription)
            helper = nil
        }
    }
    
    public var body: some View {
        if let helper {
            MetalView(renderHelper: helper)
                .frame(width: helper.size.width,
                       height: helper.size.height)
        } else {
            content
        }
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
