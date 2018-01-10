//
//  BaseBrush.swift
//
//  Created by liuxiang on 2017/12/25.
//  Copyright © 2018年 liuxiang. All rights reserved.
//

import Foundation
import UIKit

enum BrushType {
    case pen
    case eraser
    case rect
    case line
    case ellipse
    case none
}

class BaseBrush: NSObject {
 
    var points = [CGPoint]()
    var beginPoint: CGPoint?
    var currentPoint: CGPoint?
    var previousPoint1: CGPoint?
    var previousPoint2: CGPoint?
    var lineWidth: CGFloat!
    var lineColor: UIColor!
    var lineAlpha: CGFloat!
    var path = CGMutablePath()

    func drawInContext() {
        assert(false, "implements in subclass.")
    }
    
    internal func initContext() -> CGContext? {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setLineWidth(lineWidth)
        context?.setAlpha(lineAlpha)
        context?.setStrokeColor(lineColor.cgColor)
        context?.setBlendMode(.normal)
        return context
    }
}


