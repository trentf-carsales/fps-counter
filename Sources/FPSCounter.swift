//
//  FPSCounter.swift
//  fps-counter
//
//  Created by Markus Gasser on 03.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import UIKit
import QuartzCore


public class FPSCounter: NSObject {

    /// Helper class that relays display link updates to the FPSCounter
    ///
    /// This is necessary because CADisplayLink retains its target. Thus
    /// if the FPSCounter class would be the target of the display link
    /// it would create a retain cycle. The delegate has a weak reference
    /// to its parent FPSCounter, thus preventing this.
    ///
    internal class DisplayLinkDelegate: NSObject {

        weak var parentCounter: FPSCounter?

        func updateFromDisplayLink(displayLink: CADisplayLink) {
            self.parentCounter?.updateFromDisplayLink(displayLink)
        }
    }


    // MARK: - Initialization

    private let displayLink: CADisplayLink
    private let displayLinkDelegate: DisplayLinkDelegate

    public override init() {
        self.displayLinkDelegate = DisplayLinkDelegate()
        self.displayLink = CADisplayLink(target: self.displayLinkDelegate, selector: "updateFromDisplayLink:")

        super.init()

        self.displayLinkDelegate.parentCounter = self
    }

    deinit {
        self.displayLink.invalidate()
    }


    // MARK: - Configuration

    public weak var delegate: FPSCounterDelegate?
    public var notificationDelay: NSTimeInterval = 1.0


    // MARK: - Tracking

    private var runloop: NSRunLoop?
    private var mode: String?

    public func startTracking(inRunLoop runloop: NSRunLoop = NSRunLoop.mainRunLoop(), mode: String = NSRunLoopCommonModes) {
        self.stopTracking()

        self.runloop = runloop
        self.displayLink.addToRunLoop(runloop, forMode: mode)
    }

    public func stopTracking() {
        guard let runloop = self.runloop, mode = self.mode else { return }

        self.displayLink.removeFromRunLoop(runloop, forMode: mode)
    }


    // MARK: - Handling Frame Updates

    private var lastNotificationTime: CFAbsoluteTime = 0.0
    private var numberOfFrames: Int = 0

    private func updateFromDisplayLink(displayLink: CADisplayLink) {
        if self.lastNotificationTime == 0.0 {
            self.lastNotificationTime = CFAbsoluteTimeGetCurrent()
            return
        }

        self.numberOfFrames += 1

        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - self.lastNotificationTime

        if elapsedTime >= self.notificationDelay {
            self.notifyUpdateForElapsedTime(elapsedTime)
            self.lastNotificationTime = 0.0
            self.numberOfFrames = 0
        }
    }

    private func notifyUpdateForElapsedTime(elapsedTime: CFAbsoluteTime) {
        let fps = Int(round(Double(self.numberOfFrames) / elapsedTime))
        self.delegate?.fpsCounter(self, didUpdateFramesPerSecond: fps)
    }
}


public protocol FPSCounterDelegate: NSObjectProtocol {

    func fpsCounter(counter: FPSCounter, didUpdateFramesPerSecond fps: Int)
}
