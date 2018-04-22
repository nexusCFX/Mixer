//
//  MusicCollectionLayout.swift
//  Mixer
//
//  Created by Brandon Chester on 3/19/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class MusicCollectionLayout: UICollectionViewFlowLayout {
    
    var isInsertingFirstElement = false
    var isRemovingFirstElement = false
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if isInsertingFirstElement {
            attributes?.transform = CGAffineTransform(translationX: 1000, y: 0)
            isInsertingFirstElement = false
        }
        return attributes
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        if updateItems.first?.updateAction == .insert {
            isInsertingFirstElement = true
        } else if updateItems.first?.updateAction == .delete {
            isRemovingFirstElement = true
        }
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if isRemovingFirstElement {
            attributes?.transform = CGAffineTransform(translationX: 0, y: -1000)
            isRemovingFirstElement = false
        }
        return attributes
    }
}
