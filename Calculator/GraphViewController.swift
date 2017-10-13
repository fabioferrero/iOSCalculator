//
//  GraphViewController.swift
//  Calculator
//
//  Created by Fabio Ferrero on 13/10/17.
//  Copyright © 2017 fabfer_dev. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    // The model
    var function: ((Double) -> Double)? = nil
    
    // The view
    @IBOutlet weak var graphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.graphViewDataSource = self
        graphView.origin = CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
    }
    
    func getYCoordinate(forX x: CGFloat) -> CGFloat? {
        if let f = function {
            return CGFloat(f(Double(x)))
        }
        return nil
    }

}
