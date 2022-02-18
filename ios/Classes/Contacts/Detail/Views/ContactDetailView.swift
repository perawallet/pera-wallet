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
//  ContactInfoView.swift

import UIKit
import MacaroonUIKit

final class ContactDetailView: View {
    weak var delegate: ContactDetailViewDelegate?

    private lazy var theme = ContactDetailViewTheme()
    private(set) lazy var contactInformationView = ContactInformationView()
    private lazy var assetsTitleLabel = UILabel()

    private(set) lazy var assetsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.register(AssetPreviewActionCell.self)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        setListeners()
    }

    func customize(_ theme: ContactDetailViewTheme) {
        addContactInformationView(theme)
        addAssetsTitleLabel(theme)
        addAssetsCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: ContactDetailViewTheme) {}

    func prepareLayout(_ layoutSheet: ContactDetailViewTheme) {}

    func setListeners() {
        contactInformationView.delegate = self
    }
}

extension ContactDetailView {
    private func addContactInformationView(_ theme: ContactDetailViewTheme) {
        contactInformationView.customize(theme.contactInformationViewTheme)

        addSubview(contactInformationView)
        contactInformationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.userInformationViewTopPadding)
        }
    }
    
    private func addAssetsTitleLabel(_ theme: ContactDetailViewTheme) {
        assetsTitleLabel.customizeAppearance(theme.assetsTitle)

        addSubview(assetsTitleLabel)
        assetsTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(contactInformationView.snp.bottom).offset(theme.assetsLabelTopPadding)
        }
    }
    
    private func addAssetsCollectionView(_ theme: ContactDetailViewTheme) {
        addSubview(assetsCollectionView)
        assetsCollectionView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(assetsTitleLabel.snp.bottom).offset(theme.collectionViewTopPadding)
        }
    }
}

extension ContactDetailView: ContactInformationViewDelegate {
    func contactInformationViewDidTapQRButton(_ view: ContactInformationView) {
        delegate?.contactDetailViewDidTapQRButton(self)
    }
}

protocol ContactDetailViewDelegate: AnyObject {
    func contactDetailViewDidTapQRButton(_ view: ContactDetailView)
}
