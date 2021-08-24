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
//  AssetCell.swift

import UIKit

class BaseAssetCell: BaseCollectionViewCell<AssetView> {
    weak var delegate: BaseAssetCellDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }

    func bind(_ viewModel: AssetViewModel) {
        contextView.bind(viewModel)
    }

    func bind(_ viewModel: AssetAdditionViewModel) {
        contextView.bind(viewModel)
    }

    func bind(_ viewModel: AssetRemovalViewModel) {
        contextView.bind(viewModel)
    }
}

extension BaseAssetCell: AssetViewDelegate {
    func assetViewDidTapActionButton(_ assetView: AssetView) {
        delegate?.assetCellDidTapActionButton(self)
    }
}

protocol BaseAssetCellDelegate: AnyObject {
    func assetCellDidTapActionButton(_ assetCell: BaseAssetCell)
}

extension BaseAssetCellDelegate {
    func assetCellDidTapActionButton(_ assetCell: BaseAssetCell) { }
}

class AssetCell: BaseAssetCell { }

class OnlyNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeUnitName()
    }
}

class OnlyUnitNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeName()
    }
}

class UnnamedAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
    }
}

class UnverifiedAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class UnverifiedOnlyNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}

class UnverifiedOnlyUnitNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeName()
        contextView.assetNameView.removeVerified()
    }
}

class UnverifiedUnnamedAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}
