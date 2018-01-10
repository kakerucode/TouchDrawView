//
//  RectBrush.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/26.
//  Copyright © 2017年 liuxiang. All rights reserved.
//

import UIKit

class RectBrush: BaseBrush {
    
    internal override func drawInContext() {
        let context = initContext()
        context?.addRect(CGRect(origin: CGPoint(x: min(beginPoint!.x, currentPoint!.x), y: min(beginPoint!.y, currentPoint!.y)),
                                size: CGSize(width: abs(currentPoint!.x - beginPoint!.x), height: abs(currentPoint!.y - beginPoint!.y))))
        context?.strokePath()
    }
    
}
