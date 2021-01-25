//
//  AMUnitSelectorView.swift
//  ArithmaConsole
//
//  Created by Chen Zerui on 12/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

public class AMUnitSelectorView: UICollectionView {
    
    // MARK: Displayed Units
    fileprivate var unitIds: [String] = ["m", "s", "kg", "A", "K", "mol"]
    fileprivate let unitToPrefixed: [[[String]]] = [[["mm", "cm", "m", "km"],
                                                     ["s", "min", "hr", "day"],
                                                     ["mg", "g", "kg", "ton"]],
                                                    [["µA", "mA", "A", "kA"],
                                                     ["µK", "mK", "K", "kK"],
                                                     ["mmol", "mol", "kmol"]]]
    
    /// If user has long pressed - triggering prefix selection for the unit. Chanegs to this will update the tableView.
    fileprivate var isChoosingPrefix = false {
        didSet {
            performBatchUpdates({
                if isChoosingPrefix {
                    deleteSections([1])
                    reloadSections([0])
                }
                else {
                    reloadSections([0])
                    insertSections([1])
                }
            }) { _ in
                self.visibleCells.forEach {
                    $0.isUserInteractionEnabled = !self.isChoosingPrefix
                }
            }
        }
    }
    
    /// The index of the selected unit.
    fileprivate var selectedUnitIndex: IndexPath?
    /// The index of the selected prefix.
    fileprivate var selectedPrefixIndex: IndexPath? {
        didSet {
            guard oldValue != selectedPrefixIndex else {
                return
            }
            
            if let index = oldValue {
                // De-highlight previously selected.
                (cellForItem(at: index) as! AMUnitSelectorCell).showNormal()
            }
            
            if let index = selectedPrefixIndex {
                // Highlight new cell.
                (cellForItem(at: index) as! AMUnitSelectorCell).showHighlighted()
            }
        }
    }
    
    /// Keyboard associated with this instance.
    fileprivate weak var keyboard: AMKeyboardView!
    
    // MARK: Setup Methods
    public init(keyboard: AMKeyboardView) {
        
        // custom layout init
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        // pre computed properties
        let totalWidth = UIScreen.main.bounds.width
        let totalHeight = scaled(50)
        
        // margins all around
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing,
                                           bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = spacing
        
        super.init(frame: CGRect(x: 0, y: 0,
                                 width: totalWidth, height: totalHeight),
                   collectionViewLayout: layout)
        
        self.keyboard = keyboard
        self.setup()
    }
    
    private func setup() {
        register(AMUnitSelectorCell.self, forCellWithReuseIdentifier: "cell")
        
        bounces = false
        dataSource = self
        delegate = self
        isPagingEnabled = true
        
        backgroundColor = .black
        
        addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// During prefix selection, user interaction is handed over to the gesture recognizer.
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
                selectedPrefixIndex = index
            }
            else {
                (cellForItem(at: index) as! AMUnitSelectorCell).showNormal()
                
                selectedUnitIndex = index
                isChoosingPrefix = true
                
                selectedPrefixIndex = indexPathForItem(at: sender.location(in: self))
            }
            
        case .ended, .cancelled:
            guard isChoosingPrefix else {
                return
            }
            
            defer {
                isChoosingPrefix = false
            }
            
            let unitIndex = selectedUnitIndex!
            guard let prefixIndex = selectedPrefixIndex else {
                return
            }
            
            keyboard.didPress(AMKeyDescription(symbol: unitToPrefixed[unitIndex.section][unitIndex.item][prefixIndex.item], style: .number))
            
            selectedPrefixIndex = nil
            
        default: break
        }
    }
    
}

extension AMUnitSelectorView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isChoosingPrefix ? 1:2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isChoosingPrefix ? unitToPrefixed[selectedUnitIndex!.section][selectedUnitIndex!.item].count:unitIds.count/2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AMUnitSelectorCell
        if isChoosingPrefix {
            cell.label.text = unitToPrefixed[selectedUnitIndex!.section][selectedUnitIndex!.item][indexPath.item]
        }
        else {
            cell.label.text = unitIds[indexPath.item + indexPath.section*3]
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        keyboard.didPress(AMKeyDescription(symbol: unitIds[indexPath.item+indexPath.section*3], style: .number))
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsCount: Int
        
        if isChoosingPrefix {
            itemsCount = numberOfItems(inSection: 0)
        }
        else {
            itemsCount = 3
        }
        let itemDim = (collectionView.bounds.width - CGFloat(2+itemsCount) * spacing) / CGFloat(itemsCount)
        return CGSize(width: itemDim, height: collectionView.bounds.height - 2*spacing)
    }
}

fileprivate let spacing = scaled(10)
