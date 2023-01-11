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
//   WCSessionShortListItemCell.swift

import UIKit

final class WCSessionShortListItemCell: BaseCollectionViewCell<WCSessionShortListItemView> {
    weak var delegate: WCSessionShortListItemCellDelegate?

    override func prepareLayout() {
        super.prepareLayout()
        contextView.customize(WCSessionShortListItemViewTheme())
    }

    override func linkInteractors() {
        super.linkInteractors()
        contextView.setListeners()
        contextView.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.prepareForReuse()
    }
}

extension WCSessionShortListItemCell {
    func bindData(_ viewModel: WCSessionShortListItemViewModel) {
        contextView.bindData(viewModel)
    }
}

extension WCSessionShortListItemCell: WCSessionShortListItemViewDelegate {
    func wcSessionShortListItemViewDidOpenDisconnectionMenu(_ wcSessionShortListView: WCSessionShortListItemView) {
        delegate?.wcSessionShortListItemCellDidOpenDisconnectionMenu(self)
    }
}

protocol WCSessionShortListItemCellDelegate: AnyObject {
    func wcSessionShortListItemCellDidOpenDisconnectionMenu(_ wcSessionItemCell: WCSessionShortListItemCell)
}
