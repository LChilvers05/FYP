//
//  FeedbackKeyView.swift
//  FYP
//
//  Created by Lee Chilvers on 06/03/2024.
//

import SwiftUI

struct FeedbackKeyView: View {
    private let keys = ["good", "early", "late", "stick", "missed"]
    private let dots: [Color] = [.green, .yellow, .orange, .red, .gray]
    
    var body: some View {
        HStack {
            ForEach(Array(zip(dots, keys)), id: \.0) { color, label in
                VStack {
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                    Text(label)
                }
                .padding()
            }
        }
    }
}
