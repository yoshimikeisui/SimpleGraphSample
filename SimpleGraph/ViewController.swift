//
//  ViewController.swift
//  SimpleGraph
//
//  Created by Yoshimi Kondo on 2015/11/19.
//  Copyright © 2015年 yoshimikeisui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        drawLineGraph()
        drawBarGraph()
    }
    
    func drawLineGraph() {
        let stroke1 = LineStroke(graphPoints: [1, 3, 1, 4, 9, 12, 4])
        
        let stroke2 = LineStroke(graphPoints: [3, nil, 6, 4, 4])
        
        stroke1.color = UIColor.cyanColor()
        stroke2.color = UIColor.magentaColor()
        
        let graphFrame = LineStrokeGraphFrame(strokes: [stroke1, stroke2])
        
        let lineGraphView = UIView(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 200))
        lineGraphView.backgroundColor = UIColor.grayColor()
        lineGraphView.addSubview(graphFrame)
        
        view.addSubview(lineGraphView)
    }
    
    func drawBarGraph() {
        let bars = BarStroke(graphPoints: [nil, 1, 3, 1, 4, 9, 12, 4])
        bars.color = UIColor.greenColor()
        
        let barFrame = LineStrokeGraphFrame(strokes: [bars])
        
        let barGraphView = UIView(frame: CGRect(x: 0, y: 240, width: view.frame.width, height: 200))
        barGraphView.backgroundColor = UIColor.grayColor()
        barGraphView.addSubview(barFrame)
        
        view.addSubview(barGraphView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

protocol GraphObject {
    var view: UIView { get }
}

extension GraphObject {
    var view: UIView {
        return self as! UIView
    }
    
    func drawLine(from: CGPoint, to: CGPoint) {
        let linePath = UIBezierPath()
        
        linePath.moveToPoint(from)
        linePath.addLineToPoint(to)
        
        linePath.lineWidth = 0.5
        
        let color = UIColor.whiteColor()
        color.setStroke()
        linePath.stroke()
        linePath.closePath()
    }
}

protocol GraphFrame: GraphObject {
    var strokes: [GraphStroke] { get }
}

extension GraphFrame {
    // 保持しているstrokesの中で最大値
    var yAxisMax: CGFloat {
        return strokes.map{ $0.graphPoints }.flatMap{ $0 }.flatMap{ $0 }.maxElement()!
    }
    
    // 保持しているstrokesの中でいちばん長い配列の長さ
    var xAxisPointsCount: Int {
        return strokes.map{ $0.graphPoints.count }.maxElement()!
    }
    
    // X軸の点と点の幅
    var xAxisMargin: CGFloat {
        return view.frame.width/CGFloat(xAxisPointsCount)
    }
}

class LineStrokeGraphFrame: UIView, GraphFrame {
    var strokes = [GraphStroke]()
    
    convenience init(strokes: [GraphStroke]) {
        self.init()
        self.strokes = strokes
    }
    
    override func didMoveToSuperview() {
        if self.superview == nil { return }
        self.frame.size = self.superview!.frame.size
        self.view.backgroundColor = UIColor.clearColor()
        
        strokeLines()
    }
    
    func strokeLines() {
        for stroke in strokes {
            self.addSubview(stroke as! UIView)
        }
    }
    
    override func drawRect(rect: CGRect) {
        drawTopLine()
        drawBottomLine()
        drawVerticalLines()
    }
    
    func drawTopLine() {
        self.drawLine(
            CGPoint(x: 0, y: frame.height),
            to: CGPoint(x: frame.width, y: frame.height)
        )
    }
    
    func drawBottomLine() {
        self.drawLine(
            CGPoint(x: 0, y: 0),
            to: CGPoint(x: frame.width, y: 0)
        )
    }
    
    func drawVerticalLines() {
        for i in 1..<xAxisPointsCount {
            let x = xAxisMargin*CGFloat(i)
            self.drawLine(
                CGPoint(x: x, y: 0),
                to: CGPoint(x: x, y: frame.height)
            )
        }
    }
}


protocol GraphStroke: GraphObject {
    var graphPoints: [CGFloat?] { get }
}

extension GraphStroke {
    var graphFrame: GraphFrame? {
        return ((self as! UIView).superview as? GraphFrame)
    }
    
    var graphHeight: CGFloat {
        return view.frame.height
    }
    
    var xAxisMargin: CGFloat {
        return graphFrame!.xAxisMargin
    }
    
    var yAxisMax: CGFloat {
        return graphFrame!.yAxisMax
    }
    
    // indexからX座標を取る
    func getXPoint(index: Int) -> CGFloat {
        return CGFloat(index) * xAxisMargin
    }
    
    // 値からY座標を取る
    func getYPoint(yOrigin: CGFloat) -> CGFloat {
        let y: CGFloat = yOrigin/yAxisMax * graphHeight
        return graphHeight - y
    }
}


class LineStroke: UIView, GraphStroke {
    var graphPoints = [CGFloat?]()
    var color = UIColor.whiteColor()
    
    convenience init(graphPoints: [CGFloat?]) {
        self.init()
        self.graphPoints = graphPoints
    }
    
    override func didMoveToSuperview() {
        if self.graphFrame == nil { return }
        self.frame.size = self.graphFrame!.view.frame.size
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        let graphPath = UIBezierPath()
        
        graphPath.moveToPoint(
            CGPoint(x: getXPoint(0), y: getYPoint(graphPoints[0] ?? 0))
        )
        
        for graphPoint in graphPoints.enumerate() {
            if graphPoint.element == nil { continue }
            let nextPoint = CGPoint(x: getXPoint(graphPoint.index),
                y: getYPoint(graphPoint.element!))
            graphPath.addLineToPoint(nextPoint)
        }
        
        graphPath.lineWidth = 5.0
        color.setStroke()
        graphPath.stroke()
        graphPath.closePath()
    }
}

class BarStroke: UIView, GraphStroke {
    var graphPoints = [CGFloat?]()
    var color = UIColor.whiteColor()
    
    convenience init(graphPoints: [CGFloat?]) {
        self.init()
        self.graphPoints = graphPoints
    }
    
    override func didMoveToSuperview() {
        if self.graphFrame == nil { return }
        self.frame.size = self.graphFrame!.view.frame.size
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        for graphPoint in graphPoints.enumerate() {
            let graphPath = UIBezierPath()
            
            let xPoint = getXPoint(graphPoint.index)
            graphPath.moveToPoint(
                CGPoint(x: xPoint, y: getYPoint(0))
            )
            
            if graphPoint.element == nil { continue }
            let nextPoint = CGPoint(x: xPoint, y: getYPoint(graphPoint.element!))
            graphPath.addLineToPoint(nextPoint)
            
            graphPath.lineWidth = 30
            color.setStroke()
            graphPath.stroke()
            graphPath.closePath()
        }
    }
}
