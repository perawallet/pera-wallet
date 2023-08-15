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
//  LedgerDeviceListView.swift

import MacaroonUIKit
import UIKit

final class LedgerDeviceListView: View {
    private lazy var theme = LedgerDeviceListViewTheme()

    private(set) lazy var devicesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.collectionViewMinimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.listContentInset)
        collectionView.register(LedgerDeviceCell.self)
        return collectionView
    }()
    private lazy var verticalStackView = UIStackView()
    private lazy var imageView = LottieImageView()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var indicatorView = ViewLoadingIndicator()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        updateImageWhenUserInterfaceStyleDidChange()
    }

    func customize(_ theme: LedgerDeviceListViewTheme) {
        addVerticalStackView(theme)
        addDevicesCollectionView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension LedgerDeviceListView {
    private func addVerticalStackView(_ theme: LedgerDeviceListViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.spacing = theme.verticalStackViewSpacing
        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
    }

    private func addImageView(_ theme: LedgerDeviceListViewTheme) {
        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.setCustomSpacing(theme.titleLabelTopPadding, after: imageView)

        bindImage()
    }

    private func addTitleLabel(_ theme: LedgerDeviceListViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        verticalStackView.addArrangedSubview(titleLabel)
    }

    private func addDescriptionLabel(_ theme: LedgerDeviceListViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        verticalStackView.addArrangedSubview(descriptionLabel)
    }

    private func addDevicesCollectionView(_ theme: LedgerDeviceListViewTheme) {
       addSubview(devicesCollectionView)
        devicesCollectionView.snp.makeConstraints {
            $0.top.equalTo(verticalStackView.snp.bottom).offset(theme.devicesListTopPadding)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        addIndicatorView(theme)
    }

    private func addIndicatorView(_ theme: LedgerDeviceListViewTheme) {
        indicatorView.applyStyle(theme.indicator)

        devicesCollectionView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(theme.indicatorViewTopPadding)
        }
    }
}

extension LedgerDeviceListView {
    private func updateImageWhenUserInterfaceStyleDidChange() {
        bindImage()
        startAnimatingImageView()
    }
}

extension LedgerDeviceListView {
    private func bindImage() {
        let animation =
            traitCollection.userInterfaceStyle == .dark
            ? theme.imageDark
            : theme.imageLight
        imageView.setAnimation(animation)
    }
}

extension LedgerDeviceListView {
    func startAnimatingImageView() {
        imageView.play(with: LottieImageView.Configuration())
    }

    func stopAnimatingImageView() {
        imageView.stop()
    }

    func startAnimatingIndicatorView() {
        if indicatorView.isAnimating { return }

        indicatorView.startAnimating()
        indicatorView.isHidden = false
    }
    
    func stopAnimatingIndicatorView() {
        if !indicatorView.isAnimating { return }

        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }
}
