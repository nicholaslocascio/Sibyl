//
//  Prediction.swift
//  WKPredictiveKeyboardSample
//
//  Created by Nick Locascio on 11/8/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import Foundation

class Prediction {
    var word: String?
    var score: Float?
    
    init() {
        self.word = ""
        self.score = -1 * Float.infinity
    }
    
    init(word : String, score : Float) {
        self.word = word
        self.score = score
    }
    
    var description : String {
        return self.word!
    }
}