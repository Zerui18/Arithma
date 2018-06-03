//
//  PolynomialViewController.swift
//  SigMa.th
//
//  Created by Chen Zerui on 29/5/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import HPAKit
import Keyboard

// MARK: Private Input-components
fileprivate let keyboard = SKeyboardView(size: CGSize(width: UIScreen.main.bounds.width,
                                                      height: UIScreen.main.bounds.height*0.6),
                                         useImaginary: false)

class PolynomialViewController: UIViewController, SKeyboardViewDelegate {
    
    // MARK: Private Properties
    private var pgCollectionView: UICollectionView!
    private var instantiatedCells = [PolynomialCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupLayout()
    }
    
    // MARK: Private Setups
    
    private func setupProperties() {
        keyboard.delegate = self
        view.backgroundColor = .black
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 36)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        pgCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pgCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pgCollectionView.showsHorizontalScrollIndicator = false
        pgCollectionView.showsVerticalScrollIndicator = false
        
        pgCollectionView.dataSource = self
        pgCollectionView.register(PolynomialCell.self, forCellWithReuseIdentifier: "cell")
    }

    private func setupLayout() {
        view.addSubview(pgCollectionView)
        pgCollectionView.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: scaled(56)).isActive = true
        pgCollectionView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: scaled(16)).isActive = true
        pgCollectionView.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
        pgCollectionView.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
    }
    
    private func solvePolynomial() {
        var coefficients = [HPAReal]()
        coefficients.reserveCapacity(instantiatedCells.count)
        for cell in instantiatedCells.reversed() {
            guard let value = cell.linkedInputView.currentResult?.value,
                value.isReal else {
                    print("Error: coefficient cannot be nil or imaginary")
                    return
            }
            coefficients.append(value.re)
        }
        
        let polynomial = HPAPolynomial(coefficients)
        print(polynomial.roots())
    }
    
    // MARK: SKeyboardViewDelegate Conformance
    var textViewForInput: SInputTextView? {
        return PolynomialCell.currentActive?.linkedInputView
    }
    
    var bottomInset: CGFloat {
        return view.safeAreaInsets.bottom
    }
    
    func didReceive(customKey symbol: String) {
        if symbol == "=" {
            solvePolynomial()
        }
    }

}

extension PolynomialViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item >= instantiatedCells.count {
            instantiatedCells.append(collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PolynomialCell)
        }
        let cell = instantiatedCells[indexPath.item]
        cell.degree = UInt(2-indexPath.item)
        return cell
    }
}

extension PolynomialCell {
    
    var keyboardView: SKeyboardView {
        return keyboard
    }
    
}
