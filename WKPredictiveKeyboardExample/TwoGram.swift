//
//  TwoGram.swift
//  WKPredictiveKeyboardSample
//
//  Created by Nick Locascio on 11/3/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import Foundation

class TwoGram:NGram {
    var previousWord: String?
    
    init(previousWord: String, word: String) {
        super.init()
        self.previousWord = previousWord
        self.lastWord = word
        self.text = previousWord + " " + word
    }
}