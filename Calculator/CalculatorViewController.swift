//
//  ViewController.swift
//  Calculator
//
//  Created by Fabio Ferrero on 22/09/17.
//  Copyright © 2017 fabfer_dev. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    var userIsTyping = false
    var userIsTypingAFloatNumber = false
    var variables = [String:Double]()
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var variableDisplay: UILabel!
    
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
            display.text = numberFormatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain = CalculatorBrain()
    
    private func displayUpdate(with values: (result: Double?, isPending: Bool, description: String)) {
        if let result = values.result {
            displayValue = result
        }
        descriptionLabel.text = values.description
    }
    
    @IBAction func performOperation(_ button: UIButton) {
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
            userIsTypingAFloatNumber = false
        }
        if let mathematicalSymbol = button.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        let result = brain.evaluate(using: variables)
        displayUpdate(with: result)
    }
    
    @IBAction func putVariable(_ button: UIButton) {
        if !userIsTyping {
            brain.setOperand(variable: "M")
            let result = brain.evaluate(using: variables)
            displayUpdate(with: result)
        }
    }
    
    @IBAction func setVariable(_ button: UIButton) {
        variables = ["M" : displayValue]
        variableDisplay.text = "M: \(displayValue)"
        let result = brain.evaluate(using: variables)
        displayUpdate(with: result)
    }
    
    @IBAction func reset(_ sender: UIButton) {
        variables.removeAll()
        variableDisplay.text = " "
    }
    
    @IBAction func undo(_ sender: UIButton) {
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
        } else {
            brain.undoLast()
            let result = brain.evaluate(using: variables)
            displayUpdate(with: result)
        }
    }
    
}

