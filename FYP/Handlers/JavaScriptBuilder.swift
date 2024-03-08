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
            switch elem {
            case .success, .nextSuccess:
                result += colourChangeForNote(i, "#34C759") // green
            case .early, .nextEarly:
                result += colourChangeForNote(i, "#FFCC00") // yellow
            case .late:
                result += colourChangeForNote(i, "#FF9500") // orange
            case .sticking:
                result += colourChangeForNote(i, "#FF3B30") // red
            case .missed:
                result += colourChangeForNote(i, "#8E8E93") // gray
            case .error:
                result += colourChangeForNote(i, "blue") // blue
            default:
                result += colourChangeForNote(i, "black") // black
            }
        }
        
        return result + draw
    }
}
