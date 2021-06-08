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
//  PendingAssetCell.swift

import UIKit

class BasePendingAssetCell: BaseCollectionViewCell<PendingAssetView> {

    func bind(_ viewModel: PendingAssetViewModel) {
        contextView.bind(viewModel)
    }
}

class PendingAssetCell: BasePendingAssetCell { }

class PendingOnlyNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingOnlyUnitNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnnamedAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedOnlyNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedOnlyUnitNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedUnnamedAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}
