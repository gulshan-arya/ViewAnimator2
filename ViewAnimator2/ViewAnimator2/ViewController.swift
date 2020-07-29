//
//  ViewController.swift
//  ViewAnimator2
//
//  Created by Gulshan on 27/07/20.
//  Copyright © 2020 Gulshan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    private lazy var settingsVC = SettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.present(self.settingsVC, animated: true)
        })
    }
    
    private func setupActivityIndicator() {
        activityIndicator.center = CGPoint(x: view.center.x, y: 100.0)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}



