//
//  ViewController.swift
//  ViewAnimator2
//
//  Created by Gulshan on 27/07/20.
//  Copyright © 2020 Gulshan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func setupActivityIndicator() {
        activityIndicator.center = CGPoint(x: view.center.x, y: 100.0)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
}



