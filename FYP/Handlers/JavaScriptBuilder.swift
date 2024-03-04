//
//  JavaScriptBuilder.swift
//  FYP
//
//  Created by Lee Chilvers on 04/03/2024.
//

import Foundation

final class JavaScriptBuilder {
    
    private let draw = """
        context.clear();
        draw();
    """
    
    private let colourChangeForNote: (Int, String) -> String = { (i, colour) in
        """
        notes[\(i)].setStyle({fillStyle: '\(colour)', strokeStyle: '\(colour)'});
        """
    }
    
    func build(from feedback: [Feedback?]) -> String {
        var result = ""
        for (i, elem) in feedback.enumerated() {
            guard let elem else { break } // note not played yet
            switch elem {
            case .success, .nextSuccess:
                result += colourChangeForNote(i, "green")
            case .late, .early, .nextEarly:
                result += colourChangeForNote(i, "orange")
            case .missed, .sticking:
                result += colourChangeForNote(i, "red")
            case .error:
                result += colourChangeForNote(i, "grey")
            }
        }
        
        return result + draw
    }
}
