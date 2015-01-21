//
//  ThreeGram.swift
//  WKPredictiveKeyboardSample
//
//  Created by Nick Locascio on 11/3/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import Foundation

class ThreeGram:NGram {
    var previousWord: String?
    var previousPreviousWord: String?

    init(previousPreviousWord: String, previousWord: String, word: String) {
        super.init()
        self.previousPreviousWord = previousPreviousWord
        self.previousWord = previousWord
        self.lastWord = word
        self.text = previousPreviousWord + " " + previousWord + " " + word
    }
}