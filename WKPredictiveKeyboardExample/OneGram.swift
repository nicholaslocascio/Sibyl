//
//  OneGram.swift
//  WKPredictiveKeyboardSample
//
//  Created by Nick Locascio on 11/3/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import Foundation

class OneGram:NGram {
    
    init(word: String) {
        super.init()
        self.lastWord = word
        self.text = word
    }
}