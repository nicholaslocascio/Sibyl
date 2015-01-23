//
//  WKPredictiveKeyboardAPI.swift
//  WKPredictiveKeyboardSample
//
//  Created by Nick Locascio on 11/3/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import Foundation
import SQLite

class WKPredictiveKeyboardAPI {
    
    init() {
        // perform some initialization here
    }
    
/**
    Dumps DB and relearns from Corpus.
**/
    func relearnCorpus() {
        var text : String = getText()
        
        clearData()
        initDB()
        
        learnForText(text)
    }
    
    func getText() -> String {
        let path = NSBundle.mainBundle().pathForResource("CorpusTextSmall", ofType: "txt")
        var text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        return text
    }
    
    func initDB() {
        let db : Database = getDb()
        
        let onegram = db["onegram"]
        let twogram = db["twogram"]
        let threegram = db["threegram"]
        
        let id = Expression<Int>("id")
        let frequency = Expression<Int>("frequency")
        let text = Expression<String>("text")
        let prev = Expression<String>("prev")
        let prevTwo = Expression<String>("prev_two")
        
        db.create(table: onegram, ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text, unique: true)
            t.column(frequency)
        }
        
        db.create(table: twogram, ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text, unique: true)
            t.column(prev)
            t.column(frequency)
        }
        db.create(table: threegram, ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text, unique: true)
            t.column(prev)
            t.column(prevTwo)
            t.column(frequency)
        }
    }
    
    
    func clearData() {
        let db : Database = getDb()
        
        let onegram = db["onegram"]
        let twogram = db["twogram"]
        let threegram = db["threegram"]
        
        // What I'd like to do:
        
        db.drop(table: onegram, ifExists: true)
        db.drop(table: twogram, ifExists: true)
        db.drop(table: threegram, ifExists: true)

    }
    
    func recommendationsBasedOnText(text : String) ->Array<String> {
        var clean = cleanText(text)
        clean = clean.lowercaseString
        var words = clean.componentsSeparatedByString(" ")
        println(words)
        if words.last == "" {
            words.removeLast()
        }
        var numWords = countElements(words)
        var lastWord = ""
        var secondToLastWord = ""
        if numWords > 0 {
            lastWord = words[numWords-1]
        }
        if numWords > 1 {
            secondToLastWord = words[numWords-2]
        }
        var unsortedRecommendations = recommendations(secondToLastWord, previousWord: lastWord)
        var sortedRecommondationText = sorted(unsortedRecommendations, {
            (pred1: Prediction, pred2: Prediction) -> Bool in
            return pred1.score > pred2.score
        }).map { (pred : Prediction) -> String in
            return pred.word!
        }
        
        return sortedRecommondationText
    }
    
    func recommendations(previousPreviousWord : String, previousWord : String) ->Array<Prediction> {
        var predictions : Array<Prediction> = Array<Prediction>()
        
        predictions += recommendationsFromOneGram()
        predictions += recommendationsFromTwoGram(previousWord)

        return predictions
    }
    
    func recommendationsFromOneGram() ->Array<Prediction> {
        let db = getDb()
        let oneGramTable = db["onegram"]
        let frequency = Expression<Int>("frequency")
        let text = Expression<String>("text")
        
        var recommendations = Array<Prediction>()

        let oneGramPredictionQuery = oneGramTable.order(frequency.desc).limit(3)
        for gram in oneGramPredictionQuery {
            if var fCount = gram[frequency] as Int? {
                var gramText : String = gram[text]
                var lastWord = gramText.componentsSeparatedByString(" ").last!
                var score = Float(fCount)*1.0
                var prediction = Prediction(word: lastWord, score: score)
                recommendations.append(prediction)
            }
        }
        
        return recommendations
    }
    
    func recommendationsFromTwoGram(previousWord : String) ->Array<Prediction> {
        let db = getDb()
        let twoGramTable = db["twogram"]
        let frequency = Expression<Int>("frequency")
        let text = Expression<String>("text")
        let prev = Expression<String>("prev")
        
        var recommendations = Array<Prediction>()
        
        let oneGramPredictionQuery = twoGramTable.filter(prev == previousWord).order(frequency.desc).limit(3)
        for gram in oneGramPredictionQuery {
            if var fCount = gram[frequency] as Int? {
                var gramText : String = gram[text]
                var lastWord = gramText.componentsSeparatedByString(" ").last!
                var score = Float(fCount)*1000.0
                var prediction = Prediction(word: lastWord, score: score)
                recommendations.append(prediction)
            }
        }
        
        return recommendations
    }
    
    func appendOrIncrement(dict: Dictionary<String, NGram>, gram : NGram) ->Dictionary<String, NGram> {
        var mutableDict : Dictionary<String, NGram> = dict
        var key : String = gram.text!
        if mutableDict.indexForKey(key) != nil {
            gram.count = gram.count! + 1.0
            mutableDict.updateValue(gram, forKey: key)
        } else {
            mutableDict[key] = gram
        }
        
        return mutableDict
    }
    
    func getGramsAndUpdateCounts(text: String) {
        print("make grams")
        var db = getDb()
        var clean = cleanText(text)
        let words = clean.componentsSeparatedByString(" ")
        var numWords = countElements(words)
        for i in 0..<numWords {
            var word = words[i]
            var onegram = OneGram(word:word)
            updateCountsWithGram(onegram, db: db)
            
            if i > 0 {
                var previousWord = words[i-1]
                var twogram = TwoGram(previousWord: previousWord, word: word)
                updateCountsWithGram(twogram, db: db)

                if i > 1 {
                    var previousPreviousWord = words[i-2]
                    var threegram = ThreeGram(previousPreviousWord: previousPreviousWord, previousWord: previousWord, word: word)
                    updateCountsWithGram(threegram, db: db)
                }
            }
        }
    }
    
    /**
    Cleans text for ngrams. Removes punctuation and regularizes whitespace.
    :param: text The text to be cleaned
    */
    func cleanText(text:String)->String! {
        var puctuationAndNumbersRegex = NSRegularExpression(pattern: "[\\.,+\\?\"/#!$%@//^&*;:{}=_~()0-9]", options: nil, error: nil);
        var range  = Range(start:text.startIndex, end:text.endIndex)
        var clean = puctuationAndNumbersRegex?.stringByReplacingMatchesInString(text, options: nil, range: NSMakeRange(0,countElements(text)), withTemplate: "")
        
        var whiteSpaceRegex = NSRegularExpression(pattern: "\\s+", options: nil, error: nil);
        clean = whiteSpaceRegex?.stringByReplacingMatchesInString(clean!, options: nil, range: NSMakeRange(0,countElements(clean!)), withTemplate: " ")
        return clean
    }
    
    func learnForText(text: String) {
        getGramsAndUpdateCounts(text)
    }
    
    func getDb() -> Database {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first as String
        
        let db = Database("\(path)/db.sqlite3")
        
        return db
    }
    
    func updateCountsWithGram(gram: NGram, db: Database) {
        if gram is OneGram {
            insertOrUpdateOneGram(db, gram : gram as OneGram)
        } else if gram is TwoGram {
            insertOrUpdateTwoGram(db, gram : gram as TwoGram)
        } else if gram is ThreeGram {
            insertOrUpdateThreeGram(db, gram : gram as ThreeGram)
        }
    }
    
    func insertOrUpdateOneGram(db : Database, gram : NGram) {
        let onegramTable = db["onegram"]
        let frequency = Expression<Int>("frequency")
        let text = Expression<String>("text")
        
        let insertQuery = db.prepare("INSERT INTO onegram (text, frequency) VALUES (?,?)")
        var toUpdate = false
        
        let existingQuery = onegramTable.filter(text == gram.text!).limit(1)
        var exists = false
            for existingGram in existingQuery {
                exists = true
                if var fCount = existingGram[frequency] as Int? {
                    fCount = fCount + 1
                    let updates: Int = existingQuery.update(frequency <- fCount)!
                }
        }
        
        if !exists {
            insertQuery.run(gram.text,1)
        }
    }
    
    func insertOrUpdateTwoGram(db : Database, gram : TwoGram) {

        let twoGramTable = db["twogram"]
        let frequency = Expression<Int>("frequency")
        let text = Expression<String>("text")
        
        let insertQuery = db.prepare("INSERT INTO twogram (text, frequency, prev) VALUES (?,?,?)")
        var toUpdate = false
        
        let existingQuery = twoGramTable.filter(text == gram.text!).limit(1)
        var exists = false
        for existingGram in existingQuery {
            exists = true
            if var fCount : Int = existingGram[frequency] as Int? {
                fCount = fCount + 1
                let updates: Int = existingQuery.update(frequency <- fCount)!
            }
        }
        
        if !exists {
            insertQuery.run(gram.text!,1, gram.previousWord!)
        }
    }
    
    func insertOrUpdateThreeGram(db : Database, gram : ThreeGram) {
        let insertQuery = db.prepare("INSERT INTO threegram (text, frequency, prev_two) VALUES (?,?,?)")

        let threeGramTable = db["threegram"]
        let frequency = Expression<Int>("frequency")
        let text = Expression<String>("text")
        
        var toUpdate = false
        let existingQuery = threeGramTable.filter(text == gram.text!).limit(1)
        var exists = false
        for existingGram in existingQuery {
            exists = true
            if var fCount = existingGram[frequency] as Int? {
                fCount = fCount + 1
                let updates: Int = existingQuery.update(frequency <- fCount)!
            }
        }
        
        var previousTwo = "\(gram.previousPreviousWord!) \(gram.previousWord!)"
        
        if !exists {
            insertQuery.run(gram.text,1, previousTwo)
        }
    }

}