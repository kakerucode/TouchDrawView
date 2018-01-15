//
//  DrawView.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/25.
//  Copyright © 2018年 liuxiang. All rights reserved.
//

import UIKit

public protocol TouchDrawViewDelegate {
    
    func undoEnable(_ isEnable: Bool)
    func redoEnable(_ isEnable: Bool)
}

public extension TouchDrawViewDelegate {
    
    func undoEnable(_ isEnable: Bool) { }
    func redoEnable(_ isEnable: Bool) { }
}

open class TouchDrawView: UIView {
    
    var delegate: TouchDrawViewDelegate?
    
    var lineWidth: CGFloat = 5
    var lineColor = UIColor.red
    var lineAlpha: CGFloat = 1  
    var brushType: BrushType = .pen
    
    fileprivate var brush: BaseBrush?
    fileprivate var brushStack = [BaseBrush]()
    fileprivate var drawUndoManager = UndoManager()
    fileprivate var drawImageView = DrawImageView()
    
    fileprivate var prevImage: UIImage?
    fileprivate var image: UIImage?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(drawImageView)
        drawImageView.backgroundColor = UIColor.clear
    }
  
    // Sets the frames of the subviews
    override open func draw(_ rect: CGRect) {
        image?.draw(in: bounds)
        drawImageView.frame = self.bounds
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
        self.image = image
        self.setNeedsDisplay()
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
        self.image?.draw(in: self.bounds)
        drawImageView.image?.draw(in: self.bounds)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    // MARK: - Private
    fileprivate func initBrush() -> BaseBrush? {
        
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
        case .none:
            return nil
        }
    }

}

extension TouchDrawView {
    
    // MARK: - UITouches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let allTouches = event?.allTouches else { return }
        if allTouches.count > 1 { return }
        brush = initBrush()
        drawImageView.brush = brush
   
        brush?.beginPoint = touches.first?.location(in: self)
        brush?.currentPoint = touches.first?.location(in: self)
        brush?.previousPoint1 =  touches.first?.previousLocation(in: self)
        brush?.lineColor = lineColor
        brush?.lineAlpha = lineAlpha
        brush?.lineWidth = lineWidth
        brush?.points.append(touches.first!.location(in: self))
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let allTouches = event?.allTouches else { return }
        if allTouches.count > 1 { return }
        
        if let brush = self.brush {
            brush.previousPoint2 = brush.previousPoint1
            brush.previousPoint1 = touches.first?.previousLocation(in: self)
            brush.currentPoint = touches.first?.location(in: self)
            brush.points.append(touches.first!.location(in: self))
            
            if let penBrush = brush as? PenBrush {
                var drawBox = penBrush.addPathInBound()
                drawBox.origin.x -= lineWidth * 1
                drawBox.origin.y -= lineWidth * 1
                drawBox.size.width += lineWidth * 2
                drawBox.size.height += lineWidth * 2
                self.drawImageView.setNeedsDisplay(drawBox)
                
            } else {
                self.drawImageView.setNeedsDisplay()
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush, brush.points.count >= 2 {
            brushStack.append(brush)
            drawUndoManager.registerUndo(withTarget: self, selector: #selector(popBrushStack), object: nil)
            delegate?.undoEnable(drawUndoManager.canUndo)
            delegate?.redoEnable(drawUndoManager.canRedo)
        }

        touchesMoved(touches, with: event)
        finishDrawing()
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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

extension TouchDrawView {
    
    // MARK: - Draw
    
    fileprivate func finishDrawing() {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        prevImage?.draw(in: self.bounds)
        brush?.drawInContext()
        prevImage = UIGraphicsGetImageFromCurrentImageContext()
        drawImageView.image = prevImage
        UIGraphicsEndImageContext()
        brush = nil
        drawImageView.brush = nil
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

    // Redraw image for undo action
    fileprivate func redrawInContext() {
        beginImageContext()
        for brush in brushStack {
            brush.drawInContext()
        }
        endImageContext()
        drawImageView.setNeedsDisplay()
        prevImage = drawImageView.image
    }
    
    // Redraw last line for redo action
    fileprivate func redrawWithBrush(_ brush: BaseBrush) {
        beginImageContext()
        drawImageView.image?.draw(in: bounds)
        brush.drawInContext()
        endImageContext()
        drawImageView.setNeedsDisplay()
        prevImage = drawImageView.image
    }
    
    fileprivate func clearDraw() {
        brushStack.removeAll()
        beginImageContext()
        endImageContext()
        prevImage = nil
        drawImageView.setNeedsDisplay()
        drawUndoManager.removeAllActions()
        delegate?.undoEnable(false)
        delegate?.redoEnable(false)
    }
}

class DrawImageView: UIView {
    
    var image: UIImage?
    var brush: BaseBrush?
    
    override func draw(_ rect: CGRect) {
        image?.draw(in: bounds)
        brush?.drawInContext()
    }
    
    
}


