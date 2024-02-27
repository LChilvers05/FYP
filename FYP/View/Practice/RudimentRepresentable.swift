//
//  RudimentRepresentable.swift
//  FYP
//
//  Created by Lee Chilvers on 27/02/2024.
//

import SwiftUI
import WebKit

struct RudimentRepresentable: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let rudimentViewRequest: URLRequest?
    @Binding var isLoading: Bool
    @Binding var javaScript: String
    
    private let webview = WKWebView()
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isLoading,
           let rudimentViewRequest {
            // load the rudiment view
            uiView.load(rudimentViewRequest)
            return
        }
            
        // update the rudiment view
        uiView.evaluateJavaScript(javaScript) { _, error in
            if let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension RudimentRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        private var parent: RudimentRepresentable
        
        init(_ parent: RudimentRepresentable) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webview.navigationDelegate = context.coordinator
        return webview
    }
}
