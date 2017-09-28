//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Fabio Ferrero on 22/09/17.
//  Copyright © 2017 fabfer_dev. All rights reserved.
//

import Foundation

/**
 The model of Calculator ViewController
 */
struct CalculatorBrain {
    
    private var accumulator: Double?
    private var descriptionAccumulator: String?
    private var constantSymbol: String?
    private var unaryAfterBinary = false
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private var accumulatorString: String? {
        get {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6
            formatter.usesSignificantDigits = true
            if accumulator != nil {
                return formatter.string(from: NSNumber(value: accumulator!))
            } else {
                return nil
            }
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case rand
        case reset
    }
    
    private enum Operand {
        /** The case where the operand is a number */
        case number(Double)
        /** The case where the operand is a variable */
        case variable(String)
    }
    
    private var operations: Dictionary<String,Operation> = [
    "π" : Operation.constant(Double.pi),
    "e" : Operation.constant(M_E),
    "√" : Operation.unaryOperation(sqrt),
    "sin" : Operation.unaryOperation(sin),
    "cos" : Operation.unaryOperation(cos),
    "tan" : Operation.unaryOperation(tan),
    "±" : Operation.unaryOperation({-$0}),
    "x^2" : Operation.unaryOperation({$0 * $0}),
    "×" : Operation.binaryOperation({$0 * $1}),
    "÷" : Operation.binaryOperation({$0 / $1}),
    "−" : Operation.binaryOperation({$0 - $1}),
    "+" : Operation.binaryOperation({$0 + $1}),
    "=" : Operation.equals,
    "AC" : Operation.reset,
    "rand" : Operation.rand
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                constantSymbol = symbol;
            case .unaryOperation(let function):
                if accumulator != nil {
                    if descriptionAccumulator != nil {
                        if resultIsPending {
                            descriptionAccumulator = descriptionAccumulator! + " " + symbol + "(" + (constantSymbol ?? accumulatorString!) + ")"
                            unaryAfterBinary = true
                        } else {
                            descriptionAccumulator = symbol + "(" + descriptionAccumulator! + ")"
                        }
                    } else {
                        descriptionAccumulator = symbol + "(" + (constantSymbol ?? accumulatorString!) + ")"
                    }
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                performPendingBinaryOperation()
                if accumulator != nil {
                    if descriptionAccumulator != nil {
                        descriptionAccumulator = descriptionAccumulator! + " " + symbol
                    } else {
                        descriptionAccumulator = (constantSymbol ?? accumulatorString!) + " " + symbol
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            case .rand:
                accumulator = Double(arc4random()) / Double(UInt32.max)
            case .reset:
                accumulator = 0.0
                descriptionAccumulator = nil
                pendingBinaryOperation = nil
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil && descriptionAccumulator != nil {
            if !unaryAfterBinary {
                descriptionAccumulator = descriptionAccumulator! + " " + (constantSymbol ?? accumulatorString!)
            } else {
                unaryAfterBinary = false
            }
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        constantSymbol = nil
    }
    
    func setOperand(variable named: String) {
        
    }
    
    /**
     Returns the result of operations asked to the CalculatorBrain.
     */
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    /**
     Returns if the CalculatorBrain is in the middle of computing a result.
     */
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    /**
     Returns the description of operations taken into the CalculatorBrain so far.
     */
    var description: String {
        get {
            if descriptionAccumulator != nil {
                if resultIsPending {
                    return descriptionAccumulator! + " ..."
                } else {
                    return descriptionAccumulator! + " ="
                }
            } else {
                return "start typing some operations..."
            }
        }
    }
    
}
