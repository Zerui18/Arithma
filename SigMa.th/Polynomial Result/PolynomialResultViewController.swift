//
//  PolynomialResultViewController.swift
//  SigMa.th
//
//  Created by Chen Zerui on 17/6/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit

class PolynomialResultViewController: UIViewController {
    
    private let polynomial: HPAPolynomial
    fileprivate var roots: [HPAComplex]!
    
    private let equationContainerView = UIView()
    private let equationView = UITextView()
    private let rootsContainerView = UIScrollView()
    private let rootsTable = UITableView()
    
    
    init(for polynomial: HPAPolynomial) {
        self.polynomial = polynomial
        self.roots = polynomial.roots()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
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
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        )
        view.backgroundColor = nil
        
        equationContainerView.backgroundColor = .black
        equationContainerView.layer.cornerRadius = scaled(24)
        
        equationView.translatesAutoresizingMaskIntoConstraints = false
        equationView.backgroundColor = .black
        equationView.layer.cornerRadius = scaled(24)
        equationView.isScrollEnabled = false
        equationView.attributedText = polynomial.formatted(fontSize: scaled(28))
        
        rootsContainerView.backgroundColor = .black
        rootsContainerView.layer.cornerRadius = scaled(24)
        
        rootsTable.translatesAutoresizingMaskIntoConstraints = false
        rootsTable.backgroundColor = nil
        rootsTable.tableFooterView = UIView()
        rootsTable.separatorColor = .clear
        rootsTable.allowsSelection = false
        rootsTable.isScrollEnabled = false
        
        rootsTable.register(PolynomialResultCell.self, forCellReuseIdentifier: "cell")
        rootsTable.register(SeperatorCell.self, forCellReuseIdentifier: "seperator")
        rootsTable.dataSource = self
    }
    
    private func setupLayout() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        let margin = scaled(30)
        let containerView = blurView.contentView
        
        equationContainerView.frame = CGRect(x: margin, y: scaled(80),
                                             width: view.bounds.width-margin*2, height: scaled(60))
        rootsContainerView.frame = CGRect(x: margin, y: scaled(220),
                                          width: view.bounds.width-margin*2, height: (view.bounds.height - scaled(220)) * 0.85)
        
        containerView.addSubview(equationContainerView)
        containerView.addSubview(rootsContainerView)
        
        equationContainerView.addSubview(equationView)
        equationView.leadingAnchor.constraint(greaterThanOrEqualTo: equationContainerView.leadingAnchor, constant: scaled(30)).isActive = true
        equationView.centerXAnchor.constraint(equalTo: equationContainerView.centerXAnchor).isActive = true
        equationView.centerYAnchor.constraint(equalTo: equationContainerView.centerYAnchor).isActive = true
        
        rootsContainerView.addSubview(rootsTable)
        rootsTable.leadingAnchor.constraint(equalTo: rootsContainerView.leadingAnchor, constant: scaled(12)).isActive = true
        rootsTable.topAnchor.constraint(equalTo: rootsContainerView.topAnchor, constant: scaled(12)).isActive = true
        rootsTable.centerXAnchor.constraint(equalTo: rootsContainerView.centerXAnchor).isActive = true
        rootsTable.centerYAnchor.constraint(equalTo: rootsContainerView.centerYAnchor).isActive = true
    }
    
    @objc private func viewTapped() {
        dismiss(animated: true)
    }

}

// MARK: UITableViewDataSource
extension PolynomialResultViewController: UITableViewDataSource {
    
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
    
}
