//
//  PolynomialResultViewController.swift
//  SigMa.th
//
//  Created by Chen Zerui on 17/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine
import HPAKit

class PolynomialResultViewController: UIViewController {
    
    private let polynomial: HPAPolynomial
    fileprivate var roots: [HPAComplex]!
    
    private let equationContainerView = UIView()
    private let equationView = UITextView()
    private let rootsContainerView = UIView()
    private let rootsTable = UITableView()
    
    
    init(for polynomial: HPAPolynomial) {
        self.polynomial = polynomial
        self.roots = polynomial.roots()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupLayout()
    }
    
    private func setupProperties() {
        let tapGetsure = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGetsure.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGetsure)
        view.backgroundColor = nil
        
        equationContainerView.backgroundColor = .black
        equationContainerView.layer.cornerRadius = scaled(24)
        
        equationView.backgroundColor = .black
        equationView.layer.cornerRadius = scaled(24)
        equationView.attributedText = polynomial.formatted(fontSize: scaled(32))
        equationView.isEditable = false
        
        rootsContainerView.backgroundColor = .black
        rootsContainerView.layer.cornerRadius = scaled(24)
        
        rootsTable.backgroundColor = nil
        rootsTable.tableFooterView = UIView()
        rootsTable.separatorColor = .clear
        rootsTable.bounces = false
        
        rootsTable.register(PolynomialResultCell.self, forCellReuseIdentifier: "cell")
        rootsTable.register(SeperatorCell.self, forCellReuseIdentifier: "seperator")
        rootsTable.dataSource = self
        rootsTable.delegate = self
    }
    
    private func setupLayout() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        let margin = scaled(30)
        let width = view.bounds.width-margin*2
        let containerView = blurView.contentView
        
        let verticalSpace = view.bounds.height
        let outerSpace = verticalSpace * 0.06
        let innerSpace = verticalSpace * 0.03
        let equationHeight = verticalSpace * 0.28
        let rootsHeight = verticalSpace * 0.57
        
        
        equationContainerView.frame = CGRect(x: margin, y: outerSpace,
                                             width: width, height: equationHeight)
        rootsContainerView.frame = CGRect(x: margin, y: equationContainerView.frame.maxY + innerSpace,
                                          width: width, height: rootsHeight)
        
        containerView.addSubview(equationContainerView)
        containerView.addSubview(rootsContainerView)
        
        let innerMargin = scaled(8)
        let innerWidth = width - 2 * innerMargin
        
        equationView.frame = CGRect(x: innerMargin, y: innerMargin, width: innerWidth, height: equationHeight - 2*innerMargin)
        equationContainerView.addSubview(equationView)
        
        rootsTable.frame = CGRect(x: innerMargin, y: innerMargin, width: innerWidth, height: rootsHeight - 2*innerMargin)
        rootsContainerView.addSubview(rootsTable)
    }
    
    @objc private func viewTapped() {
        dismiss(animated: true)
    }

}

// MARK: UITableViewDataSource
extension PolynomialResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roots.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            // even index, setup seperator
            let seperator = tableView.dequeueReusableCell(withIdentifier: "seperator") as! SeperatorCell
            seperator.index = indexPath.row / 2
            return seperator
        }
        else {
            // odd index, setup cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PolynomialResultCell
            let actualIndex = (indexPath.row - 1) / 2
            cell.result = roots[actualIndex]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // disable selection of 'seperator's
        return indexPath.row % 2 == 1 ? indexPath:nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = (indexPath.row - 1) / 2
        AMValue(value: roots![index]).copyAttributedDescription()
        dismiss(animated: true)
    }
    
}
