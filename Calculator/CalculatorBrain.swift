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
    
    private var accumulator = [Operand]()
    
    private enum Operand {
        /** The case where the operand is a number */
        case number(Double)
        /** The case where the operand is a variable */
        case variable(String)
        /** The case where the operand is an operation */
        case operation(String)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case rand
        case reset
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
    
    mutating func setOperand(_ operand: Double) {
        accumulator.append(Operand.number(operand))
    }
    
    mutating func setOperand(variable named: String) {
        accumulator.append(Operand.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        accumulator.append(Operand.operation(symbol))
    }
    
    mutating func undoLast() {
        if !accumulator.isEmpty {
            accumulator.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var descriptionAccumulator: String?
        var unaryAfterBinary = false
        var pendingBinaryOperation: PendingBinaryOperation?
        var constantSymbol: String?
        
        var result: Double?
        var isPending: Bool {
            get {
                return pendingBinaryOperation != nil
            }
        }
        var description: String = ""
        
        var resultString: String? {
            get {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 6
                formatter.usesSignificantDigits = true
                if result != nil {
                    return formatter.string(from: NSNumber(value: result!))
                } else {
                    return nil
                }
            }
        }
        
        struct PendingBinaryOperation {
            let function: (Double,Double) -> Double
            let firstOperand: Double
            
            func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && result != nil && descriptionAccumulator != nil {
                if !unaryAfterBinary {
                    descriptionAccumulator = descriptionAccumulator! + " " + (constantSymbol ?? resultString!)
                } else {
                    unaryAfterBinary = false
                }
                result = pendingBinaryOperation?.perform(with: result!)
                pendingBinaryOperation = nil
            }
        }
        
        for operand in accumulator {
            switch operand {
            case .number(let value):
                result = value
                constantSymbol = nil
            case .variable(let variableName):
                if let variableValue = variables?[variableName] {
                    result = variableValue
                } else {
                    result = 0.0
                }
                constantSymbol = variableName
            case .operation(let symbol):
                if let operation = operations[symbol]   {
                    switch operation {
                    case .constant(let value):
                        result = value
                        constantSymbol = symbol;
                    case .unaryOperation(let function):
                        if result != nil {
                            if descriptionAccumulator != nil {
                                if isPending {
                                    descriptionAccumulator = descriptionAccumulator! + " " + symbol + "(" + (constantSymbol ?? resultString!) + ")"
                                    unaryAfterBinary = true
                                } else {
                                    descriptionAccumulator = symbol + "(" + descriptionAccumulator! + ")"
                                }
                            } else {
                                descriptionAccumulator = symbol + "(" + (constantSymbol ?? resultString!) + ")"
                            }
                            result = function(result!)
                        }
                    case .binaryOperation(let function):
                        performPendingBinaryOperation()
                        if result != nil {
                            if descriptionAccumulator != nil {
                                descriptionAccumulator = descriptionAccumulator! + " " + symbol
                            } else {
                                descriptionAccumulator = (constantSymbol ?? resultString!) + " " + symbol
                            }
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: result!)
                            result = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    case .rand:
                        result = Double(arc4random()) / Double(UInt32.max)
                    case .reset:
                        result = 0.0
                        descriptionAccumulator = nil
                        pendingBinaryOperation = nil
                    }
                }
            }
        }
        if descriptionAccumulator != nil {
            if isPending {
                description = descriptionAccumulator! + " ..."
            } else {
                description = descriptionAccumulator! + " ="
            }
        } else {
            description = "start typing some operations..."
        }
        return (result, isPending, description)
    }
    
    /**
     Returns the result of operations asked to the CalculatorBrain.
     */
    var result: Double? {
        get {
            let (evaluationResult, _, _) = evaluate()
            return evaluationResult
        }
    }
    
    /**
     Returns if the CalculatorBrain is in the middle of computing a result.
     */
    var resultIsPending: Bool {
        get {
            let (_, isPending, _) = evaluate()
            return isPending
        }
    }
    
    /**
     Returns the description of operations taken into the CalculatorBrain so far.
     */
    var description: String {
        get {
            let (_, _, resultDescription) = evaluate()
            return resultDescription
        }
    }
}
