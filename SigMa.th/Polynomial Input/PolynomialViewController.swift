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
fileprivate let keyboard = SKeyboardView(size:
    CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.6),
                                         useImaginary: false)

class PolynomialViewController: UIViewController, SKeyboardViewDelegate {

    static let shared = PolynomialViewController()

    // MARK: Private Properties
    lazy var pgScrollView = ContainerScrollView(wrapping: pgCollectionView)
    lazy var pgCollectionView = UIStackView(arrangedSubviews: cells)
    private lazy var cells: [PolynomialInputCell] = (0...2).map { index in
        let cell = PolynomialInputCell(frame: .zero)
        cell.degree = UInt(2-index)
        cell.linkedInputView.onEmptyBackspace = self.onEmptyBackspace
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
        
        pgCollectionView.spacing = 8
        
        pgScrollView.translatesAutoresizingMaskIntoConstraints = false
        pgScrollView.showsHorizontalScrollIndicator = false
        pgScrollView.delegate = self
    }

    private func setupLayout() {
        view.addSubview(pgScrollView)
        pgScrollView.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: scaled(56)).isActive = true
        pgScrollView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: scaled(16)).isActive = true
        pgScrollView.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
        pgScrollView.heightAnchor
            .constraint(equalToConstant: scaled(50)).isActive = true
        
        pgCollectionView.leadingAnchor
            .constraint(equalTo: pgScrollView.leadingAnchor).isActive = true
        pgCollectionView.trailingAnchor
            .constraint(equalTo: pgScrollView.trailingAnchor).isActive = true
    }

    func presentInputView(_ inputView: SInputTextView) {
        pgScrollView.scrollRectToVisible(
            pgScrollView.convert(PolynomialInputCell.currentActive!.frame, from: PolynomialInputCell.currentActive!),
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
    
    fileprivate func addDegree() {
        let newCell = PolynomialInputCell()
        newCell.degree = UInt(cells.count)
        cells.insert(newCell, at: 0)
        
        pgCollectionView.insertArrangedSubview(newCell, at: 0)
        newCell.beginEditing(nil)
    }
    
    private func solvePolynomial() {
        var coefficients = [HPAReal]()
        coefficients.reserveCapacity(cells.count)
        for cell in cells.reversed() {
            guard let value = cell.linkedInputView.currentResult?.value else {
                BaseViewController.shared.displayMessage("Incomplete")
                return
            }
            guard value.isReal else {
                BaseViewController.shared.displayMessage("Error")
                return
            }
            coefficients.append(value.re)
        }
        let polynomial = HPAPolynomial(coefficients)
        let resultVC = PolynomialResultViewController(for: polynomial)
        present(resultVC, animated: true)
    }
    
    private func onEmptyBackspace() {
        let currentIndex = cells.count - Int(PolynomialInputCell.currentActive!.degree) - 1
        if currentIndex > 0 {
            // move to next degree
            cells[currentIndex-1].beginEditing(nil)
        }
        else {
            // delete current cell
            if cells.count == 2 { return }
            let cell = cells.remove(at: currentIndex)
            pgCollectionView.removeArrangedSubview(cell)
            cell.removeFromSuperview()
            cells.first!.beginEditing(nil)
        }
    }

    // MARK: SKeyboardViewDelegate Conformance
    var textViewForInput: SInputTextView? {
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

fileprivate let maxOffset = -scaled(50)

extension PolynomialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= maxOffset || scrollView.panGestureRecognizer.velocity(in: nil).x > 0 {
            return
        }
        if cells.count == 7 {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        scrollView.setContentOffset(.zero, animated: true)
        addDegree()
    }
}

extension PolynomialInputCell {

    static var keyboardView: SKeyboardView {
        return keyboard
    }

}
