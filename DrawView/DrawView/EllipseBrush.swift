//
//  Ellipse.swift
//  DrawView
//
//  Created by liuxiang on 2018/1/5.
//  Copyright © 2018年 liuxiang. All rights reserved.
//

import UIKit

class EllipseBrush: BaseBrush {
    
    override func drawInContext() {
        
        let context = initContext()
        context?.addEllipse(in: CGRect(origin: CGPoint(x: min(beginPoint!.x, currentPoint!.x), y: min(beginPoint!.y, currentPoint!.y)),
                                       size: CGSize(width: abs(currentPoint!.x - beginPoint!.x), height: abs(currentPoint!.y - beginPoint!.y))))
        context?.strokePath()
    }
}
