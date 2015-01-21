//
//  NGram.swift
//  WKPredictiveKeyboardSample
//
//  Created by Nick Locascio on 11/3/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import Foundation

class NGram {
    var text: String?
    var lastWord: String?
    var count: Float?
    var score: Float?
    
    init() {
        self.text = ""
    }
    
    var description : String {
        return self.text!
    }
    
    var debugDescription : String {
        return self.text!
    }
}