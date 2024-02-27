//
//  ContentView.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var motion = MovementHandler()
    
    var body: some View {
        VStack {
            if motion.isStreamingMovement {
                Text("Playing")
            } else {
                Text("Start on iPhone")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
