//
//  ViewController.swift
//  DrawView
//
//  Created by liuxiang on 2017/12/18.
//  Copyright © 2017年 liuxiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DrawViewDelegate {
    
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        drawView.delegate = self
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        drawView.setImage(#imageLiteral(resourceName: "IMG_1251"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    // MARK: - Action
    
    @IBAction func brushAction(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            drawView.setBrushType(.pen)
        case 1:
            drawView.setBrushType(.line)
        case 2:
            drawView.setBrushType(.rect)
        case 3:
            drawView.setBrushType(.ellipse)
        case 4:
            drawView.setBrushType(.eraser)
        default:
            break
        }
    }
    
    @IBAction func redAction() {
        drawView.setLineColor(UIColor.red)
    }
    
    @IBAction func greenAction() {
        drawView.setLineColor(UIColor.green)
        
    }
    
    @IBAction func blueAction() {
        drawView.setLineColor(UIColor.blue)
    }
    
    @IBAction func alphaChanges(sender: UISlider) {
        drawView.lineAlpha = CGFloat(sender.value) 
    }
    
    @IBAction func clearAction() {
        drawView.clear()
    }
    
    @IBAction func undoAction() {
        drawView.undo()
    }
    
    @IBAction func redoAction() {
        drawView.redo()
    }
    
    // MARK: - DrawViewDelegate
    func undoEnable(_ isEnable: Bool) {
        undoButton.isEnabled = isEnable
    }
    
    func redoEnable(_ isEnable: Bool) {
        redoButton.isEnabled = isEnable
    }
    
    
}

