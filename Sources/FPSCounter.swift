//
//  FPSCounter.swift
//  fps-counter
//
//  Created by Markus Gasser on 03.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import Foundation
import QuartzCore


public class FPSCounter: NSObject {

    /// Helper class that relays display link updates to the FPSCounter
    ///
    /// This is necessary because CADisplayLink retains its target. Thus
    /// if the FPSCounter class would be the target of the display link
    /// it would create a retain cycle. The delegate has a weak reference
    /// to its parent FPSCounter, thus preventing this.
    ///
    internal class DisplayLinkDelegate {

        weak var parentCounter: FPSCounter?

        func updateFromDisplayLink(displayLink: CADisplayLink) {
            self.parentCounter?.updateFromDisplayLink(displayLink)
        }
    }


    // MARK: - Initialization

    private let displayLink: CADisplayLink
    private let displayLinkDelegate: DisplayLinkDelegate

    public init(runloop: NSRunLoop = NSRunLoop.mainRunLoop()) {
        self.displayLinkDelegate = DisplayLinkDelegate()
        self.displayLink = CADisplayLink(target: self.displayLinkDelegate, selector: "updateFromDisplayLink:")

        super.init()

        self.displayLinkDelegate.parentCounter = self
    }


    // MARK: - Configuration

    var notificationDelay: NSTimeInterval = 1.0


    // MARK: - Handling Frame Updates

    private var lastFrameUpdate: CFAbsoluteTime = 0.0

    private func updateFromDisplayLink(displayLink: CADisplayLink) {
        if lastFrameUpdate == 0.0 {
            lastFrameUpdate = CFAbsoluteTimeGetCurrent()
            return
        }

        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - self.lastFrameUpdate

        print("Elapsed time: \(elapsedTime)")

        self.lastFrameUpdate = currentTime
    }
}
