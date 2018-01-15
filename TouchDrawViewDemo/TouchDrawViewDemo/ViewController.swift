//
//  ViewController.swift
//  TouchDrawViewDemo
//
//  Created by liuxiang on 2018/1/15.
//  Copyright © 2018年 liuxiang. All rights reserved.
//

import UIKit
import TouchDrawView


class ViewController: UIViewController, TouchDrawViewDelegate {

    
    @IBOutlet weak var drawView: TouchDrawView!
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
            drawView.setDrawLineWidth(5)
        case 1:
            drawView.setBrushType(.line)
            drawView.setDrawLineWidth(5)
        case 2:
            drawView.setBrushType(.rect)
            drawView.setDrawLineWidth(5)
        case 3:
            drawView.setBrushType(.ellipse)
            drawView.setDrawLineWidth(5)
        case 4:
            drawView.setBrushType(.eraser)
            drawView.setDrawLineWidth(20)
        default:
            drawView.setBrushType(.none)
            break
        }
    }
    
    @IBAction func redAction() {
        drawView.setDrawLineColor(UIColor.red)
    }
    
    @IBAction func greenAction() {
        drawView.setDrawLineColor(UIColor.green)
    }
    
    @IBAction func blueAction() {
        drawView.setDrawLineColor(UIColor.blue)
    }
    
    @IBAction func alphaChanges(sender: UISlider) {
        drawView.setDrawLineAlpha(CGFloat(sender.value))
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

