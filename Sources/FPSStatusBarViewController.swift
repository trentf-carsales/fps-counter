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
    fileprivate let label = UILabel() // TODO: Make it private in swift 4

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(FPSStatusBarViewController.updateStatusBarFrame(_:)),
            name: .UIApplicationDidChangeStatusBarOrientation,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Lifecycle and Events

    override func loadView() {
        view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

        label.frame = view.bounds.insetBy(dx: 10.0, dy: 0.0)
        label.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        label.font = .boldSystemFont(ofSize: 10.0)
        view.addSubview(label)

        fpsCounter.delegate = self
    }

    func updateStatusBarFrame(_ notification: Notification) {
        let application = notification.object as? UIApplication
        let frame = CGRect(x: 0.0, y: 0.0, width: application?.keyWindow?.bounds.width ?? 0.0, height: 20.0)

        FPSStatusBarViewController.statusBarWindow.frame = frame
    }

    // MARK: - Getting the shared status bar window

    static var statusBarWindow: UIWindow = {
        let window = UIWindow()
        window.windowLevel = UIWindowLevelStatusBar
        window.rootViewController = FPSStatusBarViewController()
        return window
    }()
}

// MARK: - FPSCounterDelegate

extension FPSStatusBarViewController: FPSCounterDelegate {
    
    func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        let ms = 1000 / max(fps, 1)
        label.text = "\(fps) FPS (\(ms) milliseconds per frame)"
        
        if fps >= 45 {
            view.backgroundColor = .green
            label.textColor = .black
        } else if fps >= 30 {
            view.backgroundColor = .orange
            label.textColor = .white
        } else {
            view.backgroundColor = .red
            label.textColor = .white
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
    ///   - runloop:     The `NSRunLoop` to use when tracking FPS or `nil` (then it uses the main run loop)
    ///   - mode:        The run loop mode to use when tracking. If `nil` it uses `NSRunLoopCommonModes`
    ///
    public class func showInStatusBar(_ application: UIApplication, runloop: RunLoop? = nil, mode: RunLoopMode? = nil) {
        let window = FPSStatusBarViewController.statusBarWindow
        window.frame = application.statusBarFrame
        window.isHidden = false

        if let controller = window.rootViewController as? FPSStatusBarViewController {
            controller.fpsCounter.startTracking(
                inRunLoop: runloop ?? .main,
                mode: mode ?? .commonModes
            )
        }
    }
}
