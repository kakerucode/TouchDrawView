//
//  PenBrush.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/25.
//  Copyright © 2017年 liuxiang. All rights reserved.
//

import UIKit

class PenBrush: BaseBrush {

//    override func drawInContext() {
//        let context = initContext()
//        let mid1 = midPoint(p1: previousPoint1!, p2: previousPoint2!)
//        let mid2 = midPoint(p1: currentPoint!, p2: previousPoint1!)
//        context?.move(to: mid1)
//        context?.addQuadCurve(to: mid2, control: previousPoint1!)
//        context?.strokePath()
//    }
    
    
    func drawPathInBound() -> CGRect {
        
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

    
//    override func drawInContext() {
//        
//        guard points.count >= 2  else { return }
//        
//        let context = initContext()
//        let mid1 = midPoint(p1: points[0], p2: points[0])
//        let mid2 = midPoint(p1: points[1], p2: points[0])
//        context?.move(to: mid1)
//        context?.addQuadCurve(to: mid2, control: points[0])
//        
//        if points.count >= 3 {
//            
//            for i in 2..<points.count {
//                
//                let p2 = points[i - 2]
//                let p1 = points[i - 1]
//                let currentPoint = points[i]
//                let mid1 = midPoint(p1: p1, p2: p2)
//                let mid2 = midPoint(p1: currentPoint, p2: p1)
//                context?.move(to: mid1)
//                context?.addQuadCurve(to: mid2, control: p1)
//            }
//        }
//        context?.strokePath()
//    }

    internal func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
}


