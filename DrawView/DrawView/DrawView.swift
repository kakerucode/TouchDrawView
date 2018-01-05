//
//  DrawView.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/25.
//  Copyright © 2018年 liuxiang. All rights reserved.
//

import UIKit

protocol DrawViewDelegate {
    
    func undoEnable(_ isEnable: Bool)
    func redoEnable(_ isEnable: Bool)
}

extension DrawViewDelegate {
    
    func undoEnable(_ isEnable: Bool) { }
    func redoEnable(_ isEnable: Bool) { }
}

class DrawView: UIView {
    
    var delegate: DrawViewDelegate?
    
    var lineWidth: CGFloat = 5
    var lineColor = UIColor.red
    var lineAlpha: CGFloat = 1  
    var brushType: BrushType = .pen
    
    fileprivate var brush: BaseBrush?
    fileprivate var brushStack = [BaseBrush]()
    fileprivate var drawUndoManager = UndoManager()
    fileprivate var imageView = UIImageView()
    fileprivate var drawImageView = UIImageView()
    fileprivate var prevImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(imageView)
        self.addSubview(drawImageView)
    }
  
    // Sets the frames of the subviews
    override open func draw(_ rect: CGRect) {
        imageView.frame = rect
        drawImageView.frame = rect
    }
    
    // MARK: - Public
    open func setBrushType(_ type: BrushType) {
        brushType = type
    }
    
    open func setDrawLineColor(_ color: UIColor) {
        lineColor = color
    }
    
    open func setDrawLineWidth(_ width: CGFloat) {
        lineWidth = width
    }
    
    open func setDrawLineAlpha(_ alpha: CGFloat) {
        lineAlpha = alpha
    }
    
    open func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    open func undo() {
        
        if drawUndoManager.canUndo {
            
            drawUndoManager.undo()
            delegate?.redoEnable(drawUndoManager.canRedo)
            delegate?.undoEnable(drawUndoManager.canUndo)
        }
    }
    
    open func redo() {
        if drawUndoManager.canRedo {
            
            drawUndoManager.redo()
            delegate?.undoEnable(drawUndoManager.canUndo)
            delegate?.redoEnable(drawUndoManager.canRedo)
        }
    }
    
    open func clear() {
        clearDraw()
    }
    
    open func exportImage() -> UIImage? {
        beginImageContext()
        imageView.image?.draw(in: imageView.bounds)
        drawImageView.image?.draw(in: drawImageView.bounds)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    // MARK: - Private
    fileprivate func initBrush() -> BaseBrush {
        
        switch brushType {
        case .pen:
            return PenBrush()
        case .eraser:
            return EraserBrush()
        case .rect:
            return RectBrush()
        case .line:
            return LineBrush()
        case .ellipse:
            return EllipseBrush()
        }
    }

}

extension DrawView {
    
    // MARK: - UITouches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let allTouches = event?.allTouches else { return }
        if allTouches.count > 1 { return }
        brush = initBrush()
        brush?.beginPoint = touches.first?.location(in: self)
        brush?.currentPoint = touches.first?.location(in: self)
        brush?.previousPoint1 = touches.first?.previousLocation(in: self)
        brush?.lineColor = lineColor
        brush?.lineAlpha = lineAlpha
        brush?.lineWidth = lineWidth
        brush?.points.append(touches.first!.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let allTouches = event?.allTouches else { return }
        if allTouches.count > 1 { return }
        
        if let brush = self.brush {
            brush.previousPoint2 = brush.previousPoint1
            brush.previousPoint1 = touches.first?.previousLocation(in: self)
            brush.currentPoint = touches.first?.location(in: self)
            brush.points.append(touches.first!.location(in: self))
            drawInContext(brush: brush)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush, brush.points.count >= 2 {
            brushStack.append(brush)
            drawUndoManager.registerUndo(withTarget: self, selector: #selector(popBrushStack), object: nil)
            delegate?.undoEnable(drawUndoManager.canUndo)
            delegate?.redoEnable(drawUndoManager.canRedo)
        }

        touchesMoved(touches, with: event)        
        prevImage = drawImageView.image
        brush = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    @objc fileprivate func popBrushStack() {
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(pushBrushStack(_:)), object: brushStack.popLast())
        redrawInContext()
    }
    
    @objc fileprivate func pushBrushStack(_ brush: BaseBrush) {
        
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(popBrushStack), object: nil)
        brushStack.append(brush)
        redrawWithBrush(brush)
    }
}

extension DrawView {
    
    // MARK: - Draw
    fileprivate func drawInContext(brush: BaseBrush) {
        beginImageContext()
        prevImage?.draw(in: drawImageView.bounds)
        brush.drawInContext()
        endImageContext()
    }
    
    /// Begins the image context
    fileprivate func beginImageContext() {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
    }
    
    /// Ends image context and sets UIImage to what was on the context
    fileprivate func endImageContext() {
        
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /// Draws the current image for context
    fileprivate func drawCurrentImage() {
        drawImageView.image?.draw(in: imageView.bounds)
    }

    
    // Redraw image for undo action
    fileprivate func redrawInContext() {
        beginImageContext()
        for brush in brushStack {
            brush.drawInContext()
        }
        endImageContext()
        prevImage = drawImageView.image
    }
    
    // Redraw last line for redo action
    fileprivate func redrawWithBrush(_ brush: BaseBrush) {
        beginImageContext()
        prevImage?.draw(in: drawImageView.bounds)
        brush.drawInContext()
        endImageContext()
        prevImage = drawImageView.image
    }
    
    fileprivate func clearDraw() {
        brushStack.removeAll()
        beginImageContext()
        endImageContext()
        prevImage = nil
        drawUndoManager.removeAllActions()
        delegate?.undoEnable(false)
        delegate?.redoEnable(false)
    }
}


