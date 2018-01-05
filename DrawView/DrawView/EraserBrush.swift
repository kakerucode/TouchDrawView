//
//  EraserBrush.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/26.
//  Copyright © 2017年 liuxiang. All rights reserved.
//

import UIKit

class EraserBrush: PenBrush {

    override func drawInContext() {
        
        guard points.count >= 2  else { return }
        let context = initContext()
        context?.setLineWidth(10)
        context?.setBlendMode(.clear)
        
        let mid1 = midPoint(p1: points[0], p2: points[0])
        let mid2 = midPoint(p1: points[1], p2: points[0])
        context?.move(to: mid1)
        context?.addQuadCurve(to: mid2, control: points[0])
        
        if points.count >= 3 {
            
            for i in 2..<points.count {
                let p2 = points[i - 2]
                let p1 = points[i - 1]
                let currentPoint = points[i]
                let mid1 = midPoint(p1: p1, p2: p2)
                let mid2 = midPoint(p1: currentPoint, p2: p1)
                context?.move(to: mid1)
                context?.addQuadCurve(to: mid2, control: p1)
            }
        }
        context?.strokePath()
    }
    
}
