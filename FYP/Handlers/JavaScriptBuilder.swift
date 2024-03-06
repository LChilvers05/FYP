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
                result += colourChangeForNote(i, "green")
            case .early, .nextEarly:
                result += colourChangeForNote(i, "yellow")
            case .late:
                result += colourChangeForNote(i, "orange")
            case .sticking:
                result += colourChangeForNote(i, "red")
            case .missed:
                result += colourChangeForNote(i, "gray")
            case .error:
                result += colourChangeForNote(i, "blue")
            default:
                result += colourChangeForNote(i, "black")
            }
        }
        
        return result + draw
    }
}
