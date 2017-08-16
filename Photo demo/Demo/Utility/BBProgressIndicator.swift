//
//  BBProgressIndicator.swift
//  BBIndicator
//
//  Created by My Mac on 15/11/16.
//  Copyright © 2016 Boudhayan. All rights reserved.
//

import UIKit


// =====================================================================================================================
// MARK: - Shared Constants & Configurations
// =====================================================================================================================

private let BACKGROUND_VIEW_SIDE_LENGTH: CGFloat = 80.0
private let CIRCLE_ROTATION_TO_VALUE = 2 * CGFloat(M_PI)
private let CIRCLE_ROTATION_REPEAT_COUNT = Float(UINT64_MAX)
private let CIRCLE_RADIUS_OUTER: CGFloat = 30.0
private let CIRCLE_RADIUS_MIDDLE: CGFloat = 20.0
private let CIRCLE_RADIUS_INNER: CGFloat = 10.0
private let CIRCLE_LINE_WIDTH: CGFloat = 2.0
private let CIRCLE_START_ANGLE: CGFloat = -CGFloat(M_PI_2)
private let CIRCLE_END_ANGLE: CGFloat = 0.0

private weak var currentStatusLoader: BBIndicatorLoader?
private var currentLoader: BBIndicatorLoader?
private var currentCompletionBlock: (() -> Void)?

typealias bb_config = BBIndicatorConfiguration

@objc private protocol BBIndicatorLoader{
    var emptyView: UIView { get set }
    var backgroundView: UIVisualEffectView { get set }
    @objc optional var outerCircle: CAShapeLayer { get set }
    @objc optional var middleCircle: CAShapeLayer { get set }
    @objc optional var innerCircle: CAShapeLayer { get set }
    @objc optional weak var targetView: UIView? { get set }
}


final public class BBIndicatorConfiguration: NSObject{
    public static var backgroundViewCornerRadius: CGFloat = 10.0
    public static var backgroundViewPresentAnimationDuration: CFTimeInterval = 0.3
    public static var backgroundViewDismissAnimationDuration: CFTimeInterval = 0.3
    
    public static var blurStyle: UIBlurEffectStyle = .dark
    public static var circleColorOuter: CGColor = UIColor.colorWithRGB(red: 100.0, green: 149.0, blue: 173.0, alpha: 1.0).cgColor
    public static var circleColorMiddle: CGColor = UIColor.colorWithRGB(red: 82.0, green: 124.0, blue: 194.0, alpha: 1.0).cgColor
    public static var circleColorInner: CGColor = UIColor.colorWithRGB(red: 60.0, green: 132.0, blue: 196.0, alpha: 1.0).cgColor
    
    public static var circleRotationDurationOuter: CFTimeInterval = 3.0
    public static var circleRotationDurationMiddle: CFTimeInterval = 1.5
    public static var circleRotationDurationInner: CFTimeInterval = 0.75
}

// =====================================================================================================================
// MARK: - Extensions & Helpers & Shared Methods
// =====================================================================================================================

private func dispatchAfter(time: Double, block: @escaping () -> ()){
    let dispatchTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: block)
}
private func dispatchOnMainQueue(_ block: @escaping () -> ()){
    DispatchQueue.main.async(execute: block)
}
private func bb_stopCircleAnimations(_ loader: BBIndicatorLoader, completionBlock: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.25)
    CATransaction.setCompletionBlock(completionBlock)
    loader.outerCircle?.opacity = 0.0
    loader.middleCircle?.opacity = 0.0
    loader.innerCircle?.opacity = 0.0
    CATransaction.commit()
}
private func presentIndicatorOnView(_ loader: BBIndicatorLoader, onView view: UIView?, completionBlock: (() -> Void)?) {
    currentLoader = loader
    
    let emptyView = loader.emptyView
    emptyView.backgroundColor = UIColor.clear
    emptyView.frame = loader.backgroundView.bounds
    emptyView.addSubview(loader.backgroundView)
    
        dispatchOnMainQueue {
        if let targetView = view {
            targetView.addSubview(emptyView)
        } else {
            current_window()!.addSubview(emptyView)
        }
        
        emptyView.alpha = 0.1
        UIView.animate(withDuration: bb_config.backgroundViewPresentAnimationDuration, delay: 0.0, options: .curveEaseOut, animations: {
            emptyView.alpha = 1.0
            }, completion: { _ in completionBlock?() })
    }
}
private func hideLoaderFromView(_ loader: BBIndicatorLoader?, withCompletionBlock block: (() -> Void)?) {
    guard let loader = loader else { return }
    current_window()!.isUserInteractionEnabled = true
    dispatchOnMainQueue {
        UIView.animate(withDuration: bb_config.backgroundViewDismissAnimationDuration, delay: 0.0, options: .curveEaseOut, animations: {
            loader.emptyView.alpha = 0.0
            loader.backgroundView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in block?() })
    }
    
    dispatchAfter(time: bb_config.backgroundViewDismissAnimationDuration) {
        cleanupBBIndicatorLoader(loader)
    }
}
private func current_window() -> UIWindow? {
    var targetWindow: UIWindow?
    let windows = UIApplication.shared.windows
    for window in windows {
        if window.screen != UIScreen.main { continue }
        if !window.isHidden && window.alpha == 0 { continue }
        if window.windowLevel != UIWindowLevelNormal { continue }
        targetWindow = window
        targetWindow?.isUserInteractionEnabled = false

        break
    }
    
    return targetWindow
}
private func cleanupBBIndicatorLoader(_ loader: BBIndicatorLoader) {
    loader.emptyView.removeFromSuperview()
    currentLoader = nil
    currentCompletionBlock = nil
}
private func createdFrameForBackgroundView(_ backgroundView: UIView, onView view: UIView?) -> Bool {
    let center: CGPoint
    
    if view == nil {
        guard let window = current_window() else { return false }
        center = CGPoint(x: window.screen.bounds.midX, y: window.screen.bounds.midY)
    } else {
        let viewBounds = view!.bounds
        center = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
    }
    
    let sideLengths = BACKGROUND_VIEW_SIDE_LENGTH
    backgroundView.frame = CGRect(x: center.x - sideLengths / 2, y: center.y - sideLengths / 2, width: sideLengths, height: sideLengths)
    backgroundView.layer.cornerRadius = bb_config.backgroundViewCornerRadius
    
    return true
}
private func createCirclesForAnimation(outerCircle: CAShapeLayer, middleCircle: CAShapeLayer, innerCircle: CAShapeLayer, onView view: UIView) {
    let circleRadiusOuter = CIRCLE_RADIUS_OUTER
    let circleRadiusMiddle = CIRCLE_RADIUS_MIDDLE
    let circleRadiusInner = CIRCLE_RADIUS_INNER
    let viewBounds = view.bounds
    let arcCenter = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
    var path: UIBezierPath
    path = UIBezierPath(arcCenter: arcCenter,
                        radius: circleRadiusOuter,
                        startAngle: CIRCLE_START_ANGLE,
                        endAngle: CIRCLE_END_ANGLE,
                        clockwise: true)
    configureLayerForAnimation(outerCircle, forView: view, withPath: path.cgPath, withBounds: viewBounds, withColor: bb_config.circleColorOuter)
    
    path = UIBezierPath(arcCenter: arcCenter,
                        radius: circleRadiusMiddle,
                        startAngle: CIRCLE_START_ANGLE,
                        endAngle: CIRCLE_END_ANGLE,
                        clockwise: true)
    
    configureLayerForAnimation(middleCircle, forView: view, withPath: path.cgPath, withBounds: viewBounds, withColor: bb_config.circleColorMiddle)
    
    path = UIBezierPath(arcCenter: arcCenter,
                        radius: circleRadiusInner,
                        startAngle: CIRCLE_START_ANGLE,
                        endAngle: CIRCLE_END_ANGLE,
                        clockwise: true)
    configureLayerForAnimation(innerCircle, forView: view, withPath: path.cgPath, withBounds: viewBounds, withColor: bb_config.circleColorInner)
}
private func configureLayerForAnimation(_ layer: CAShapeLayer, forView view: UIView, withPath path: CGPath, withBounds bounds: CGRect, withColor color: CGColor) {
    layer.path = path
    layer.frame = bounds
    layer.lineWidth = CIRCLE_LINE_WIDTH
    layer.strokeColor = color
    layer.fillColor = UIColor.clear.cgColor
    layer.isOpaque = true
    view.layer.addSublayer(layer)
}
private func startAnimatingCircles(outerCircle: CAShapeLayer, middleCircle: CAShapeLayer, innerCircle: CAShapeLayer) {
    dispatchOnMainQueue {
        let outerAnimation = CABasicAnimation(keyPath: "transform.rotation")
        outerAnimation.toValue = CIRCLE_ROTATION_TO_VALUE
        outerAnimation.duration = bb_config.circleRotationDurationOuter
        outerAnimation.repeatCount = CIRCLE_ROTATION_REPEAT_COUNT
        outerCircle.add(outerAnimation, forKey: "outerCircleRotation")
        
        let middleAnimation = outerAnimation.copy() as! CABasicAnimation
        middleAnimation.duration = bb_config.circleRotationDurationMiddle
        middleCircle.add(middleAnimation, forKey: "middleCircleRotation")
        
        let innerAnimation = middleAnimation.copy() as! CABasicAnimation
        innerAnimation.duration = bb_config.circleRotationDurationInner
        innerCircle.add(innerAnimation, forKey: "middleCircleRotation")
    }
}

private extension UIColor {
    static func colorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}


// =====================================================================================================================
// MARK: - Background Rect
// =====================================================================================================================

private struct BlurredBackgroundRect {
    
    var view: UIVisualEffectView
    
    init() {
        let blur = UIBlurEffect(style: bb_config.blurStyle)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.clipsToBounds = true
        
        view = effectView
    }
    
}

// =====================================================================================================================
// MARK: - Extensions & Helpers & Shared Methods
// =====================================================================================================================
private final class BBProgressLoader: BBIndicatorLoader {
    
    @objc var emptyView = UIView()
    @objc var backgroundView: UIVisualEffectView
    @objc var outerCircle = CAShapeLayer()
    @objc var middleCircle = CAShapeLayer()
    @objc var innerCircle = CAShapeLayer()
    var multiplier: CGFloat = 1.0
    var lastMultiplierValue: CGFloat = 0.0
    var progressValue: CGFloat = 0.0
    var progress: Progress?
    var failed = false
    static weak var weakSelf: BBProgressLoader?
    @objc weak var targetView: UIView?
    
    init() {
        backgroundView = BlurredBackgroundRect().view
        BBProgressLoader.weakSelf = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(BBProgressLoader.orientationChanged(_:)),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIDeviceOrientationDidChange,
                                                  object: nil)
    }
    
    @objc func orientationChanged(_ notification: Notification) {
        if let loader = currentLoader {
            if let targetView = loader.targetView {
                _ =  createdFrameForBackgroundView(loader.backgroundView, onView: targetView)
            } else {
                _ =  createdFrameForBackgroundView(loader.backgroundView, onView: nil)
            }
        }
    }
    
}


private extension BBProgressLoader {
    
    func showOnView(_ view: UIView?, completionBlock: (() -> Void)?) {
        if createdFrameForBackgroundView(backgroundView, onView: view) == false { return }
        
        targetView = view
        
        createCirclesForAnimation(outerCircle: outerCircle,
                          middleCircle: middleCircle,
                          innerCircle: innerCircle,
                          onView: backgroundView.contentView)
        startAnimatingCircles(outerCircle: outerCircle, middleCircle: middleCircle, innerCircle: innerCircle)
        presentIndicatorOnView(self, onView: view, completionBlock: completionBlock)
    }
    
}

class BBProgressIndicator: NSObject {
    public static var isLoaderOnScreen: Bool { return currentLoader != nil ? true : false }
    
    // MARK: Show Infinite Loader
    
    
    public static func show() {
        if !isLoaderOnScreen { BBProgressLoader().showOnView(nil, completionBlock: nil) }
    }
    
    public static func showWithPresentCompetionBlock(_ block: @escaping () -> Void) {
        if !isLoaderOnScreen { BBProgressLoader().showOnView(nil, completionBlock: block) }
    }
    
    public static func showOnView(_ view: UIView) {
        if !isLoaderOnScreen { BBProgressLoader().showOnView(view, completionBlock: nil) }
    }
    
    public static func showOnView(_ view: UIView, completionBlock: @escaping () -> Void) {
        if !isLoaderOnScreen { BBProgressLoader().showOnView(view, completionBlock: completionBlock) }
    }
 
    // MARK: Hide Loader
    
    public static func hide() {
        hideLoaderFromView(currentLoader, withCompletionBlock: nil)
    }
    
    /// <code>completionBlock</code> is going to be called on the main queue
    public static func hideWithCompletionBlock(_ block: @escaping () -> Void) {
        hideLoaderFromView(currentLoader, withCompletionBlock: block)
    }
}


