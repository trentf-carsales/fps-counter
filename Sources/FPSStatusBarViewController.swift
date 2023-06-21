//
//  FPSStatusBarViewController.swift
//  fps-counter
//
//  Created by Markus Gasser on 04.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import UIKit


/// A view controller to show a FPS label in the status bar.
///
class FPSStatusBarViewController: UIViewController {

    fileprivate let fpsCounter = FPSCounter()
    private let label = UILabel()
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateStatusBarFrame()
        }, completion: nil)
    }

    // MARK: - View Lifecycle and Events

    override func loadView() {
        self.view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

        let font = UIFont.italicSystemFont(ofSize: 12)
        let rect = self.view.bounds.insetBy(dx: 10.0, dy: 0.0)
        let statusBarFrame = getStatusBarFrame()
        let labelOriginX = statusBarFrame.height > 24 ? rect.origin.x : (statusBarFrame.width/2.0) + 30
        self.label.frame = CGRect(x: labelOriginX, y: rect.maxY - font.lineHeight - 2.0, width: rect.width, height: font.lineHeight)
        self.label.autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ]
        self.label.font = font
        self.label.textColor = .black
        self.view.addSubview(self.label)

        self.fpsCounter.delegate = self
    }
    
    private func updateStatusBarFrame() {
        FPSStatusBarViewController.statusBarWindow.frame = getStatusBarFrame()
    }


    // MARK: - Getting the shared status bar window

    @objc static var statusBarWindow: UIWindow = {
        let window = FPStatusBarWindow()
        window.windowLevel = .statusBar
        window.rootViewController = FPSStatusBarViewController()
        return window
    }()
    
    private func getStatusBarFrame() -> CGRect {
        var statusBarFrame: CGRect
        if let statusBarFrameRect = view.window?.windowScene?.statusBarManager?.statusBarFrame {
            statusBarFrame = statusBarFrameRect
        } else {
            statusBarFrame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        }
        
        return statusBarFrame
    }
}


// MARK: - FPSCounterDelegate

extension FPSStatusBarViewController: FPSCounterDelegate {

    @objc func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        self.resignKeyWindowIfNeeded()

        guard fps < 58 else {
            FPSStatusBarViewController.statusBarWindow.isHidden = true
            return
        }
        
        FPSStatusBarViewController.statusBarWindow.isHidden = false
        
        let milliseconds = 1000 / max(fps, 1)
        self.label.text = "\(fps) FPS (\(milliseconds)ms)"
        self.label.textAlignment = .left

        switch fps {
        case 45...:
            self.view.backgroundColor = .green
        case 35...:
            self.view.backgroundColor = .orange
        default:
            self.view.backgroundColor = .red
        }
        updateStatusBarFrame()
    }

    private func resignKeyWindowIfNeeded() {
        // prevent the status bar window from becoming the key window and steal events
        // from the main application window
        if FPSStatusBarViewController.statusBarWindow.isKeyWindow {
            UIApplication.shared.delegate?.window??.makeKey()
        }
    }
}


public extension FPSCounter {

    // MARK: - Show FPS in the status bar

    /// Add a label in the status bar that shows the applications current FPS.
    ///
    /// - Note:
    ///   Only do this in debug builds. Apple may reject your app if it covers the status bar.
    ///
    /// - Parameters:
    ///   - application: The `UIApplication` to show the FPS for
    ///   - runloop:     The `NSRunLoop` to use when tracking FPS. Default is the main run loop
    ///   - mode:        The run loop mode to use when tracking. Default uses `RunLoop.Mode.common`
    ///
    @objc class func showInStatusBar(
        application: UIApplication = .shared,
        runloop: RunLoop = .main,
        mode: RunLoop.Mode = .common
    ) {
        let window = FPSStatusBarViewController.statusBarWindow
        window.frame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        window.isHidden = false

        if let controller = window.rootViewController as? FPSStatusBarViewController {
            controller.fpsCounter.startTracking(
                inRunLoop: runloop,
                mode: mode
            )
        }
    }

    /// Removes the label that shows the current FPS from the status bar.
    ///
    @objc class func hide() {
        let window = FPSStatusBarViewController.statusBarWindow

        if let controller = window.rootViewController as? FPSStatusBarViewController {
            controller.fpsCounter.stopTracking()
            window.isHidden = true
        }
    }

    /// Returns wether the FPS counter is currently visible or not.
    ///
    @objc class var isVisible: Bool {
        return !FPSStatusBarViewController.statusBarWindow.isHidden
    }
}
