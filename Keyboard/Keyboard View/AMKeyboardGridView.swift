//
//  AMKeyboardGridView.swift
//  ArithmaKeyboard
//
//  Created by Chen Zerui on 10/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import Engine

class AMKeyboardGridView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var keyboard: AMKeyboardView?
    
    let rows: Int
    let columns: Int
    let keys: [AMKeyDescription]
    
    init(keys: [AMKeyDescription], columns: Int, size: CGSize) {
        
        // compute rows & columns
        
        let (q, r) = keys.count.quotientAndRemainder(dividingBy: columns)
        let rows = q + min(r, 1)
        self.rows = rows
        self.columns = columns
        self.keys = keys

        let layout = UICollectionViewFlowLayout()
        
        // compute initial height & width for each cell
        let width = size.width / CGFloat(columns)
        let height = size.height / CGFloat(rows)
        let minDim = min(width, height)
        
        // compute minimum spacing as empty / (n+1)
        layout.minimumLineSpacing = (size.height - CGFloat(rows)*minDim) / CGFloat(rows+1)
        layout.minimumInteritemSpacing = (size.width - CGFloat(columns)*minDim) / CGFloat(columns+1)
        
        // for symmetry, set edge insets to the corresponding minimum spacing (-0.25 as buffer space)
        layout.sectionInset = UIEdgeInsets(top: layout.minimumLineSpacing-0.25, left: layout.minimumInteritemSpacing-0.25, bottom: layout.minimumLineSpacing-0.25, right: layout.minimumInteritemSpacing-0.25)
        
        // set finalised item size
        layout.itemSize = CGSize(width: minDim, height: minDim)
        
        super.init(frame: CGRect(x: 0, y: 0, width: size.width,
                                 height: size.height), collectionViewLayout: layout)
        
        self.dataSource = self
        self.delegate = self
        self.isScrollEnabled = false
        backgroundColor = nil
        
        register(AMKeyViewNormal.self, forCellWithReuseIdentifier: "normalKey")
        register(AMKeyViewDelete.self, forCellWithReuseIdentifier: "imageKey")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let description = keys[indexPath.item]
        if description.style == .delete {
            let cell = dequeueReusableCell(withReuseIdentifier: "imageKey", for: indexPath) as! AMKeyViewDelete
            cell.keyDescription = description
            return cell
        }
        let cell = dequeueReusableCell(withReuseIdentifier: "normalKey", for: indexPath) as! AMKeyViewNormal
        cell.keyDescription = description
        return cell
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let indexPath = indexPathForItem(at: touches.first!.location(in: self)) else {return}
        
        let key = keys[indexPath.item]
        
        keyboard?.didPress(key)
    }

}
