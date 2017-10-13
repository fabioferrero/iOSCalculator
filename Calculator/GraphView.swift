//
//  GraphView.swift
//  Calculator
//
//  Created by Fabio Ferrero on 05/10/17.
//  Copyright © 2017 fabfer_dev. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    let axisDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        let graphCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        axisDrawer.drawAxes(in: bounds, origin: graphCenter, pointsPerUnit: 50)
    }

}
