//
//  ViewAnimator.swift
//  ViewAnimator
//
//  Created by Gulshan on 26/07/20.
//  Copyright © 2020 Gulshan. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    private var items = [Any?]()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
    }

    private func setupActivityIndicator() {
        activityIndicator.center = CGPoint(x: view.center.x, y: 100.0)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = "Cell: \(indexPath.row + 1)"
        return cell
    }

    @IBAction func animateTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        activityIndicator.stopAnimating()
        items = Array(repeating: nil, count: 20)
        tableView.reloadData()
        UIView.animate(views: tableView.visibleCells, animations: animations, completion: {
            sender.isEnabled = true
        })
    }

    @IBAction func resetTapped(_ sender: UIBarButtonItem) {
        items.removeAll()
        UIView.animate(views: tableView.visibleCells, animations: animations, reversed: true,
                       initialAlpha: 1.0, finalAlpha: 0.0, completion: {
            self.tableView.reloadData()
            self.activityIndicator.startAnimating()
        })
    }
}


// MARK: - UIView extension with animations.
public extension UIView {

    /// Performs the animation.
    ///
    /// - Parameters:
    ///   - animations: Array of Animations to perform on the animation block.
    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
    ///   - initialAlpha: Initial alpha of the view prior to the animation.
    ///   - finalAlpha: View's alpha after the animation.
    ///   - delay: Time Delay before the animation.
    ///   - duration: TimeInterval the animation takes to complete.
    ///   - completion: CompletionBlock after the animation finishes.
    public func animate(animations: [Animation],
                        reversed: Bool = false,
                        initialAlpha: CGFloat = 0.0,
                        finalAlpha: CGFloat = 1.0,
                        delay: Double = 0,
                        duration: TimeInterval = ViewAnimatorConfig.duration,
                        options: UIViewAnimationOptions = [],
                        completion: (() -> Void)? = nil) {
        
        let transformFrom = transform
        var transformTo = transform
        animations.forEach { transformTo = transformTo.concatenating($0.initialTransform) }
        if !reversed {
            transform = transformTo
        }

        alpha = initialAlpha
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: { [weak self] in
            self?.transform = reversed ? transformTo : transformFrom
            self?.alpha = finalAlpha
        }) { _ in
            completion?()
        }
    }
    
    /// Performs the animation.
    ///
    /// - Parameters:
    ///   - animations: Array of Animations to perform on the animation block.
    ///   - reversed: Initial state of the animation. Reversed will start from its original position.
    ///   - initialAlpha: Initial alpha of the view prior to the animation.
    ///   - finalAlpha: View's alpha after the animation.
    ///   - delay: Time Delay before the animation.
    ///   - animationInterval: Interval between the animations of each view.
    ///   - duration: TimeInterval the animation takes to complete.
    ///   - completion: CompletionBlock after the animation finishes.
    public static func animate(views: [UIView],
                               animations: [Animation],
                               reversed: Bool = false,
                               initialAlpha: CGFloat = 0.0,
                               finalAlpha: CGFloat = 1.0,
                               delay: Double = 0,
                               animationInterval: TimeInterval = 0.05,
                               duration: TimeInterval = ViewAnimatorConfig.duration,
                               options: UIViewAnimationOptions = [],
                               completion: (() -> Void)? = nil) {

        guard views.count > 0 else {
            completion?()
            return
        }
        
        views.forEach { $0.alpha = initialAlpha }
        let dispatchGroup = DispatchGroup()
        for _ in 1...views.count { dispatchGroup.enter() }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            for (index, view) in views.enumerated() {
                view.alpha = initialAlpha
                view.animate(animations: animations,
                             reversed: reversed,
                             initialAlpha: initialAlpha,
                             finalAlpha: finalAlpha,
                             delay: Double(index) * animationInterval,
                             duration: duration,
                             options: options,
                             completion: { dispatchGroup.leave() })
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
}



/// Animation protocol defines the initial transform for a view for it to
/// animate to its identity position.
public protocol Animation {

    /// Defines the starting point for the animations.
    var initialTransform: CGAffineTransform { get }
}


/// AnimationType available to perform/
///
/// - from: Animation with direction and distance.
/// - zoom: Zoom animation.
/// - rotate: Rotation animation.
public enum AnimationType: Animation {

    case from(direction: Direction, offset: CGFloat)
    case zoom(scale: CGFloat)
    case rotate(angle: CGFloat)
    
    /// Creates the corresponding CGAffineTransform for AnimationType.from.
    public var initialTransform: CGAffineTransform {
        switch self {
        case .from(let direction, let offset):
            let sign = direction.sign
            if direction.isVertical { return CGAffineTransform(translationX: 0, y: offset * sign) }
            return CGAffineTransform(translationX: offset * sign, y: 0)
        case .zoom(let scale):
             return CGAffineTransform(scaleX: scale, y: scale)
        case .rotate(let angle):
            return CGAffineTransform(rotationAngle: angle)
        }
    }
    
    /// Generates a random Animation.
    ///
    /// - Returns: Newly generated random Animation.
    public static func random() -> Animation {
        let index = Int(arc4random_uniform(3))
        if index == 1 {
            return AnimationType.from(direction: Direction.random(),
                                      offset: ViewAnimatorConfig.offset)
        } else if index == 2 {
            let scale = Double.random(min: 0, max: ViewAnimatorConfig.maxZoomScale)
            return AnimationType.zoom(scale: CGFloat(scale))
        }
        let angle = CGFloat.random(min: -ViewAnimatorConfig.maxRotationAngle,
                                   max: ViewAnimatorConfig.maxRotationAngle)
        return AnimationType.rotate(angle: angle)
    }
}


// Direction of the animation used in AnimationType.from.
public enum Direction: Int {

    case top
    case left
    case right
    case bottom
    
    /// Checks if the animation should go on the X or Y axis.
    var isVertical: Bool {
        switch self {
        case .top, .bottom:
            return true
        default:
            return false
        }
    }

    /// Positive or negative value to determine the direction.
    var sign: CGFloat {
        switch self {
        case .top, .left:
            return -1
        case .right, .bottom:
            return 1
        }
    }

    /// Random direction.
    static func random() -> Direction {
        let rawValue = Int(arc4random_uniform(4))
        return Direction(rawValue: rawValue)!
    }
}

/// Configuration class for the default values used in animations.
/// All it's values are used when creating 'random' animations as well.
public class ViewAnimatorConfig {
    
    /// Amount of movement in points.
    /// Depends on the Direction given to the AnimationType.
    public static var offset: CGFloat = 30.0
    
    /// Duration of the animation.
    public static var duration: Double = 0.3
    
    /// Interval for animations handling multiple views that need
    /// to be animated one after the other and not at the same time.
    public static var interval: Double = 0.075
    
    /// Maximum zoom to be applied in animations using random AnimationType.zoom.
    public static var maxZoomScale: Double = 2.0
    
    /// Maximum rotation (left or right) to be applied in animations using random AnimationType.rotate
    public static var maxRotationAngle: CGFloat = CGFloat.pi/4
}



// MARK: - Bool
extension Bool {

    /// Generates a random bool.
    ///
    /// - Returns: Bool.
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}

// MARK: Double
public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }

    /// Generates a random double.
    ///
    /// - Parameters:
    ///   - min: Minimum value of the random value.
    ///   - max: Maximum value of the random value.
    /// - Returns: Generated value.
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

// MARK: Float Extension

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
}

extension CGFloat {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }

    /// Generates a random CGFloat.
    ///
    /// - Parameters:
    ///   - min: Minimum value of the random value.
    ///   - max: Maximum value of the random value.
    /// - Returns: Generated value.
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}


