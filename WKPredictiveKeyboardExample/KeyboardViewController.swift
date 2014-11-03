//
//  KeyboardViewController.swift
//  WKPredictiveKeyboardExample
//
//  Created by Nick Locascio on 11/3/14.
//  Copyright (c) 2014 Wanna Koala. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        var expandedHeight = 400
        //
        //        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 800)
        //
        //        self.view.addConstraint(heightConstraint);
        
        
        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles3 = ["CP", "Z", "X", "C", "V", "B", "N", "M", "BP"]
        let buttonTitles4 = ["CHG", "SPACE", "RETURN"]
        
        var row1 = createRowOfButtons(buttonTitles1)
        var row2 = createRowOfButtons(buttonTitles2)
        var row3 = createRowOfButtons(buttonTitles3)
        var row4 = createRowOfButtons(buttonTitles4)
        var suggestionsView = createRowOfSuggestions();
        
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        self.view.addSubview(suggestionsView);
        
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        suggestionsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        addConstraintsToInputView(self.view, rowViews: [suggestionsView,row1, row2, row3, row4])
    }
    
    func createRowOfButtons(buttonTitles: [NSString]) -> UIView {
        
        var buttons = [UIButton]()
        var keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        
        for buttonTitle in buttonTitles{
            
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        
        return keyboardRowView
    }
    
    func createRowOfSuggestions() -> UIView {
        
        var buttons = [UIButton]()
        var suggestionRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        
        for suggestionIndex in 0..<3{
            let button = createSuggestionButton()
            buttons.append(button)
            suggestionRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, mainView: suggestionRowView)
        
        return suggestionRowView
    }
    
    func createSuggestionButton() -> UIButton {
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, 106, 20)
        button.setTitle("hi", forState: .Normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFontOfSize(17)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        
        button.addTarget(self, action: "didTapSuggestionButton:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
    }
    
    
    
    func createButtonWithTitle(title: String) -> UIButton {
        
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, 20, 20)
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    func didTapSuggestionButton(sender: AnyObject?) {
        let button = sender as UIButton
        var proxy = textDocumentProxy as UITextDocumentProxy
        let precedingContext = proxy.documentContextBeforeInput
        var charactersToDelete = charactersToDeleteBeforeInserting(precedingContext)
        while charactersToDelete > 0 {
            proxy.deleteBackward()
            charactersToDelete -= 1
        }
        if var title = button.titleForState(.Normal) {
            title += " "
            proxy.insertText(title)
        }
    }
    
    func charactersToDeleteBeforeInserting(text: NSString)->Int {
        var charSet = NSCharacterSet.whitespaceCharacterSet()
        let range = text.rangeOfCharacterFromSet(charSet, options: NSStringCompareOptions.BackwardsSearch)
        var num = text.length - (range.location + 1)
        return num
    }
    
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as UIButton
        var proxy = textDocumentProxy as UITextDocumentProxy
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "BP" :
                proxy.deleteBackward()
            case "RETURN" :
                proxy.insertText("\n")
            case "SPACE" :
                proxy.insertText(" ")
            case "CHG" :
                self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
            }
        }
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in enumerate(buttons) {
            
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -1)
                
            }else{
                
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -1)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 1)
                
            }else{
                
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1)
                
                let firstButton = buttons[0]
                var widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: -1)
            
            var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 1)
            
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0)
                
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                var heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .Height, relatedBy: .Equal, toItem: rowView, attribute: .Height, multiplier: 1.0, constant: 0)
                
                heightConstraint.priority = 800
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
        
    }
}
