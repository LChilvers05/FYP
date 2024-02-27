//
//  PlaybackView.swift
//  FYP
//
//  Created by Lee Chilvers on 27/02/2024.
//

import SwiftUI

struct ControlsView: View {
    
    let playAction: (() -> Void)
    let stopAction: (() -> Void)
    
    var body: some View {
        HStack {
            Spacer()
            circularActionButton(
                action: self.playAction,
                image: "play.fill"
            )
            Spacer()
            circularActionButton(
                action: self.stopAction,
                image: "stop.fill"
            )
            Spacer()
        }
    }
    
    private func circularActionButton(action: @escaping () -> Void,
                                      image: String) -> some View {
        return Button(action: action) {
            Image(systemName: image)
                .font(.system(size: 40.0))
                .foregroundColor(.primary)
                .padding(20.0)
                .background(.background)
                .clipShape(Circle())
                .overlay(Circle().stroke(.secondary))
        }
        
    }
}
