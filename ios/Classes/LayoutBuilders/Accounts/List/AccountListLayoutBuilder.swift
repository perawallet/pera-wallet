// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountListLayoutBuilder.swift

import UIKit

class AccountListLayoutBuilder: NSObject, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: AccountListLayoutBuilderDelegate?
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) is AccountViewCell {
            delegate?.accountListLayoutBuilder(self, didSelectAt: indexPath)
        }
    }
}

protocol AccountListLayoutBuilderDelegate: AnyObject {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath)
}
