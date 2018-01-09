//
//  PenBrush.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/25.
//  Copyright © 2017年 liuxiang. All rights reserved.
//

import UIKit

class PenBrush: BaseBrush {

    
    func addPathInBound() -> CGRect {
        
        let mid1 = midPoint(p1: previousPoint1!, p2: previousPoint2!)
        let mid2 = midPoint(p1: currentPoint!, p2: previousPoint1!)
        let subPath = CGMutablePath()
        subPath.move(to: mid1)
        subPath.addQuadCurve(to: mid2, control: previousPoint1!)
        path.addPath(subPath)
        return subPath.boundingBoxOfPath
    }
    
    override func drawInContext() {
        let context = initContext()
        context?.addPath(path)
        context?.strokePath()
    }

    internal func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
}


