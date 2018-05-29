//
//  BaseViewController.swift
//  SigMa.th
//
//  Created by Chen Zerui on 29/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let containerScrollView = UIScrollView(frame: .zero)
    private let viewControllers = [PolynomialViewController(), CalculatorViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainer()
        setupChildren()
    }
    
    private func setupContainer() {
        containerScrollView.backgroundColor = nil
        containerScrollView.frame = view.bounds
        containerScrollView.isPagingEnabled = true
        containerScrollView.bounces = false
        containerScrollView.contentSize = CGSize(width: 2*containerScrollView.bounds.width, height: containerScrollView.bounds.height)
        containerScrollView.contentOffset = CGPoint(x: containerScrollView.bounds.width, y: 0)
        view.addSubview(containerScrollView)
    }
    
    private func setupChildren() {
        viewControllers.forEach(self.addChildViewController)
        containerScrollView.addSubview(viewControllers[0].view)
        viewControllers[1].view.frame.origin = containerScrollView.contentOffset
        containerScrollView.addSubview(viewControllers[1].view)
    }

}
