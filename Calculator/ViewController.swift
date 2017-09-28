//
//  ViewController.swift
//  Calculator
//
//  Created by Fabio Ferrero on 22/09/17.
//  Copyright © 2017 fabfer_dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var userIsTyping = false
    var userIsTypingAFloatNumber = false
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBAction func tapDigit(_ button: UIButton) {
        let digit = button.currentTitle!
        if userIsTyping {
            let currentDisplay = display.text!
            if !userIsTypingAFloatNumber {
                display.text = currentDisplay + digit
                if digit == "." {
                    userIsTypingAFloatNumber = true
                }
            } else if digit != "." {
                display.text = currentDisplay + digit
            }
        } else if digit != "." {
            display.text = digit
            userIsTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 6
            numberFormatter.usesSignificantDigits = true
            display.text = numberFormatter.string(from: NSNumber(value: newValue)) //String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ button: UIButton) {
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
            userIsTypingAFloatNumber = false
        }
        if let mathematicalSymbol = button.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
            descriptionLabel.text = brain.description
        } else if brain.resultIsPending {
            descriptionLabel.text = brain.description
        }
    }
    
    @IBAction func eraseDigit(_ sender: UIButton) {
        if userIsTyping {
            if display.text!.count > 1 {
                let lastChar = String(display.text!.removeLast())
                if lastChar == "." {
                    userIsTypingAFloatNumber = false
                }
            } else {
                displayValue = 0.0
                userIsTypingAFloatNumber = false
                userIsTyping = false
            }
        }
    }
    
}

