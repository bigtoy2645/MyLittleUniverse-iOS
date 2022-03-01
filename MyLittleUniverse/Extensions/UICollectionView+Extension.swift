//
//  UICollectionView+Extension.swift
//  MyLittleUniverse
//
//  Created by yurim on 2022/03/01.
//

import UIKit

extension UICollectionView {
    /* 전체 선택 해제 */
    func deselectAll() {
        if let selectedItems = self.indexPathsForSelectedItems {
            for indexPath in selectedItems {
                self.deselectItem(at: indexPath, animated: false)
            }
        }
    }
}
