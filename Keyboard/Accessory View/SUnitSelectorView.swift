//
//  SUnitSelectorView.swift
//  NumCodeConsole
//
//  Created by Chen Zerui on 12/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

public class SUnitSelectorView: UICollectionView {
    
    fileprivate var unitIds: [String] = ["m", "s", "kg"]
    fileprivate let unitToPrefixed: [[String]] = [["mm", "cm", "m", "km"],
                                                  ["s", "min", "hr", "day"],
                                                  ["mg", "g", "kg", "ton"]]
    
    fileprivate var isChoosingPrefix = false {
        didSet {
            performBatchUpdates({
                self.reloadSections([0])
            }) { _ in
                self.visibleCells.forEach {
                    $0.isUserInteractionEnabled = !self.isChoosingPrefix
                }
            }
        }
    }
    fileprivate var selectedUnitIndex: Int?
    fileprivate var selectedPrefixIndex: Int? {
        didSet {
            guard oldValue != selectedPrefixIndex else {
                return
            }
            
            if let index = oldValue {
                (cellForItem(at: IndexPath(item: index, section: 0)) as! SUnitSelectorCell).showNormal()
            }
            
            if let index = selectedPrefixIndex {
                (cellForItem(at: IndexPath(item: index, section: 0)) as! SUnitSelectorCell).showHighlighted()
            }
        }
    }
    
    fileprivate weak var keyboard: SKeyboardView!
    
    public init(keyboard: SKeyboardView) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let val = CGFloat(8).scaled
        layout.sectionInset = UIEdgeInsets(top: val, left: val, bottom: val, right: val)
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(46).scaled), collectionViewLayout: layout)
        self.keyboard = keyboard
        setup()
    }
    
    private func setup() {
        register(SUnitSelectorCell.self, forCellWithReuseIdentifier: "cell")
        
        isScrollEnabled = false
        dataSource = self
        delegate = self
        
        backgroundColor = .black
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:))))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func longPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            guard let index = indexPathForItem(at: sender.location(in: self)) else {
                if isChoosingPrefix {
                    selectedPrefixIndex = nil
                }
                return
            }
            
            if isChoosingPrefix {
                selectedPrefixIndex = index.item
            }
            else {
                (cellForItem(at: index) as! SUnitSelectorCell).showNormal()
                
                selectedUnitIndex = index.item
                isChoosingPrefix = true
                
                if let prefixIndex = indexPathForItem(at: sender.location(in: self)) {
                    selectedPrefixIndex = prefixIndex.item
                }
            }
            
        case .ended, .cancelled:
            guard isChoosingPrefix else {
                return
            }
            
            defer {
                isChoosingPrefix = false
            }
            
            guard let index = selectedPrefixIndex else {
                return
            }
            
            keyboard.didPress(SKeyDescription(symbol: unitToPrefixed[selectedUnitIndex!][index], style: .number))
            
            selectedPrefixIndex = nil
            
        default: break
        }
    }
    
}

extension SUnitSelectorView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isChoosingPrefix ? unitToPrefixed[selectedUnitIndex!].count:unitIds.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SUnitSelectorCell
        if isChoosingPrefix {
            cell.label.text = unitToPrefixed[selectedUnitIndex!][indexPath.item]
        }
        else {
            cell.label.text = unitIds[indexPath.item]
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        keyboard.didPress(SKeyDescription(symbol: unitIds[indexPath.item], style: .number))
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let n = CGFloat(numberOfItems(inSection: 0)+1)
        let width = (bounds.width - n*CGFloat(10).scaled) / (n-1)
        return CGSize(width: width, height: CGFloat(46-2*8).scaled)
    }
    
}

