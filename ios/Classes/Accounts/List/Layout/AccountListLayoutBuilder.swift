// Copyright 2022 Pera Wallet, LDA

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
import MacaroonUIKit

final class AccountListLayoutBuilder: NSObject, UICollectionViewDelegateFlowLayout {
    weak var delegate: AccountListLayoutBuilderDelegate?

    private let theme: AccountListViewController.Theme

    init(theme: AccountListViewController.Theme) {
        self.theme = theme
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.accountListLayoutBuilder(self, didSelectAt: indexPath)
    }
}

protocol AccountListLayoutBuilderDelegate: AnyObject {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath)
}
