//
//  FPSStatusBarViewController.swift
//  fps-counter
//
//  Created by Markus Gasser on 04.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import UIKit


internal class FPSStatusBarViewController: UIViewController, FPSCounterDelegate {

    private let fpsCounter = FPSCounter()

    private let label: UILabel = UILabel()

    override func loadView() {
        self.view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

        self.label.frame = CGRectInset(self.view.bounds, 10.0, 0.0)
        self.label.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
        self.label.font = UIFont.boldSystemFontOfSize(10.0)
        self.view.addSubview(self.label)
        
        self.fpsCounter.delegate = self
    }

    func fpsCounter(counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        let ms = 1000 / fps
        self.label.text = "\(fps) FPS (\(ms) milliseconds per frame)"

        if fps >= 45 {
            self.view.backgroundColor = .greenColor()
            self.label.textColor = .blackColor()
        } else if fps >= 30 {
            self.view.backgroundColor = .orangeColor()
            self.label.textColor = .whiteColor()
        } else {
            self.view.backgroundColor = .redColor()
            self.label.textColor = .whiteColor()
        }
    }


    static var statusBarWindow: UIWindow = {
        let window = UIWindow()
        window.windowLevel = UIWindowLevelStatusBar
        window.rootViewController = FPSStatusBarViewController()
        return window
    }()
}


public extension FPSCounter {

    public class func showInStatusBar(application: UIApplication, runloop: NSRunLoop = NSRunLoop.mainRunLoop(), mode: String = UITrackingRunLoopMode) {
        let window = FPSStatusBarViewController.statusBarWindow
        window.frame = application.statusBarFrame
        window.hidden = false

        (window.rootViewController as! FPSStatusBarViewController).fpsCounter.startTracking(inRunLoop: runloop, mode: mode)
    }
}