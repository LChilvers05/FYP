//
//  Modifiers.swift
//  FYP
//
//  Created by Lee Chilvers on 06/03/2024.
//

import SwiftUI


extension View {
    func blueCircularStyle() -> some View {
        modifier(BlueCircular())
    }
}

struct BlueCircular: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40.0))
            .foregroundColor(.primary)
            .padding(16.0)
            .background(.background)
            .clipShape(Circle())
            .overlay(Circle().stroke(.secondary))
    }
}
