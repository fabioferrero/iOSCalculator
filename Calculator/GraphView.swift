//
//  GraphView.swift
//  Calculator
//
//  Created by Fabio Ferrero on 05/10/17.
//  Copyright © 2017 fabfer_dev. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getYCoordinate(forX x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    // Public API
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() }}
    
    var graphViewDataSource: GraphViewDataSource!
    
    var origin: CGPoint! { didSet { setNeedsDisplay() }}
    
    // Provate stuff
    private let pointsPerUnit: CGFloat = 50
    
    private let axisDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        // Draw the axis
        let pointsForScale = scale * pointsPerUnit
        axisDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: pointsForScale)
        
        // Draw the curve
    }

}
