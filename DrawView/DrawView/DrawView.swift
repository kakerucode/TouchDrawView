//
//  DrawView.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/25.
//  Copyright © 2017年 liuxiang. All rights reserved.
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
    var isForceTouch = false
    
    private var brush: BaseBrush?
    private var brushStack = [BaseBrush]()
    private var drawUndoManager = UndoManager()
    private var imageView = UIImageView()
    private var drawImageView = UIImageView()
    private var image: UIImage?
    private var prevImage: UIImage?
    
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
    
    open func setLineColor(_ color: UIColor) {
        lineColor = color
    }
    
    open func setLineWidth(_ width: CGFloat) {
        lineWidth = width
    }
    
    open func setLineAlpha(_ alpha: CGFloat) {
        lineAlpha = alpha
    }
    
    open func setImage(_ image: UIImage) {
        imageView.image = image
        self.image = image
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
    private func initBrush() -> BaseBrush {
        
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
        print("began")
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
            print("moved")
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
    
    @objc private func popBrushStack() {
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(pushBrushStack(_:)), object: brushStack.popLast())
        redrawInContext()
    }
    
    @objc private func pushBrushStack(_ brush: BaseBrush) {
        
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(popBrushStack), object: nil)
        brushStack.append(brush)
        redrawWithBrush(brush)
    }
}

extension DrawView {
    
    // MARK: - Draw
    private func drawInContext(brush: BaseBrush) {
        beginImageContext()
        prevImage?.draw(in: drawImageView.bounds)
        brush.drawInContext()
        endImageContext()
    }
    
    /// Begins the image context
    private func beginImageContext() {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
    }
    
    /// Ends image context and sets UIImage to what was on the context
    private func endImageContext() {
        
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /// Draws the current image for context
    private func drawCurrentImage() {
        drawImageView.image?.draw(in: imageView.bounds)
    }

    
    // Redraw image for undo action
    private func redrawInContext() {
        beginImageContext()
        for brush in brushStack {
            brush.drawInContext()
        }
        endImageContext()
        prevImage = drawImageView.image
    }
    
    // Redraw last line for redo action
    private func redrawWithBrush(_ brush: BaseBrush) {
        beginImageContext()
        prevImage?.draw(in: drawImageView.bounds)
        brush.drawInContext()
        endImageContext()
        prevImage = drawImageView.image
    }
    
    private func clearDraw() {
        brushStack.removeAll()
        beginImageContext()
        endImageContext()
        prevImage = nil
        drawUndoManager.removeAllActions()
        delegate?.undoEnable(false)
        delegate?.redoEnable(false)
    }
}


