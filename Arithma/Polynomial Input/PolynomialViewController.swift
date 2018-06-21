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
fileprivate let keyboard = AMKeyboardView(size:
    CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.6),
                                         useImaginary: false)

class PolynomialViewController: UIViewController, AMKeyboardViewDelegate {

    static let shared = PolynomialViewController()

    // MARK: Private Properties
    private let addDegreeButton = UIButton()
    private let removeDegreeButton = UIButton()
    private lazy var pgScrollView = ContainerScrollView(wrapping: pgCollectionView)
    private lazy var pgCollectionView = UIStackView(arrangedSubviews: cells)
    private lazy var cells: [PolynomialInputCell] = (0...2).map { index in
        let cell = PolynomialInputCell(frame: .zero)
        cell.degree = UInt(2-index)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupLayout()
    }

    // MARK: Public Function
    public override func becomeFirstResponder() -> Bool {
        if let cell = cells.first {
            cell.beginEditing(nil)
        }
        return true
    }

    // MARK: Private Setups

    private func setupProperties() {
        keyboard.delegate = self
        view.backgroundColor = .black
        
        addDegreeButton.setBackgroundImage(#imageLiteral(resourceName: "ic_add"), for: .normal)
        addDegreeButton.translatesAutoresizingMaskIntoConstraints = false
        addDegreeButton.addTarget(self, action: #selector(addDegree), for: .touchUpInside)
        
        removeDegreeButton.setBackgroundImage(#imageLiteral(resourceName: "ic_remove"), for: .normal)
        removeDegreeButton.translatesAutoresizingMaskIntoConstraints = false
        removeDegreeButton.addTarget(self, action: #selector(removeDegree), for: .touchUpInside)
        
        pgCollectionView.spacing = 8
        
        pgScrollView.translatesAutoresizingMaskIntoConstraints = false
        pgScrollView.showsHorizontalScrollIndicator = false
    }

    private func setupLayout() {
        view.addSubview(addDegreeButton)
        addDegreeButton.widthAnchor.constraint(equalToConstant: scaled(38)).isActive = true
        addDegreeButton.heightAnchor.constraint(equalToConstant: scaled(38)).isActive = true
        addDegreeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: scaled(74)).isActive = true
        addDegreeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: scaled(-38)).isActive = true
        
        view.addSubview(removeDegreeButton)
        removeDegreeButton.widthAnchor.constraint(equalToConstant: scaled(38)).isActive = true
        removeDegreeButton.heightAnchor.constraint(equalToConstant: scaled(38)).isActive = true
        removeDegreeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: scaled(74)).isActive = true
        removeDegreeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: scaled(38)).isActive = true
        
        view.addSubview(pgScrollView)
        pgScrollView.topAnchor
            .constraint(equalTo: addDegreeButton.bottomAnchor,
                        constant: scaled(20)).isActive = true
        pgScrollView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: scaled(16)).isActive = true
        pgScrollView.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
        pgScrollView.heightAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(50)).isActive = true
        
        pgCollectionView.leadingAnchor
            .constraint(equalTo: pgScrollView.leadingAnchor).isActive = true
        pgCollectionView.trailingAnchor
            .constraint(equalTo: pgScrollView.trailingAnchor).isActive = true
    }

    func presentInputView(_ inputView: AMInputTextView) {
        pgScrollView.scrollRectToVisible(
            PolynomialInputCell.currentActive!.frame,
            animated: true)

        // remove last containerView
        view.subviews.first(where: {$0.tag == -999})?.removeFromSuperview()

        let containerView = inputView.superview!
        view.addSubview(containerView)

        // right-extendable behaviour
        inputView.trailingAnchor
            .constraint(greaterThanOrEqualTo: view.trailingAnchor,
                        constant: scaled(-16)).isActive = true

        // positions inputView above keyboard
        containerView.bottomAnchor
            .constraint(equalTo: view.bottomAnchor,
                        constant: -keyboard.bounds.height).isActive = true
        containerView.leadingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        containerView.trailingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        containerView.heightAnchor
            .constraint(greaterThanOrEqualToConstant: scaled(54)).isActive = true
    }
    
    @objc fileprivate func addDegree() {
        if cells.count == 10 {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        // show 'disabled' if will reach limit
        else if cells.count == 9 {
            addDegreeButton.alpha = 0.7
        }
        
        removeDegreeButton.alpha = 1
        
        let newCell = PolynomialInputCell()
        newCell.degree = UInt(cells.count)
        cells.insert(newCell, at: 0)
        
        pgCollectionView.insertArrangedSubview(newCell, at: 0)
        newCell.beginEditing(nil)
    }
    
    @objc fileprivate func removeDegree() {
        if cells.count == 2 {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        // show 'disabled' if will reach limit
        else if cells.count == 3 {
            removeDegreeButton.alpha = 0.7
        }
        
        addDegreeButton.alpha = 1
        
        let cell = cells.removeFirst()
        pgCollectionView.removeArrangedSubview(cell)
        cell.removeFromSuperview()
        
        // activate first cell when the active cell is deleted
        if PolynomialInputCell.currentActive === cell {
            cells.first!.beginEditing(nil)
        }
    }
    
    private func solvePolynomial() {
        var coefficients = [HPAReal]()
        coefficients.reserveCapacity(cells.count)
        for cell in cells.reversed() {
            guard let value = cell.linkedInputView.currentResult?.value else {
                cell.beginEditing(nil)
                return
            }
            guard value.isReal else {
                cell.beginEditing(nil)
                BaseViewController.shared.displayMessage("Only Real Coefficients")
                return
            }
            coefficients.append(value.re)
        }
        let polynomial = HPAPolynomial(coefficients)
        let resultVC = PolynomialResultViewController(for: polynomial)
        present(resultVC, animated: true)
    }

    // MARK: AMKeyboardViewDelegate Conformance
    var textViewForInput: AMInputTextView? {
        return PolynomialInputCell.currentActive?.linkedInputView
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

extension PolynomialInputCell {

    static var keyboardView: AMKeyboardView {
        return keyboard
    }

}
