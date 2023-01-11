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

//   WCConnectionView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCConnectionView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .openUrl: TargetActionInteraction()
    ]
    
    private lazy var dappImageView = URLImageView()
    private lazy var titleView = Label()
    private lazy var urlActionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 6))
    private lazy var subtitleContainerView = UIView()
    private lazy var subtitleView = Label()
    private(set) lazy var accountListView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset.top = 8
        collectionView.backgroundColor = .clear
        return collectionView
    }()
        
    func customize(_ theme: WCConnectionViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addDappImage(theme)
        addTitle(theme)
        addUrlAction(theme)
        addSubtitle(theme)
        addAccountList(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension WCConnectionView {
    private func addDappImage(_ theme: WCConnectionViewTheme) {
        dappImageView.build(URLImageViewNoStyleLayoutSheet())
        dappImageView.draw(corner: theme.dappImageCorner)
        
        addSubview(dappImageView)
        dappImageView.snp.makeConstraints {
            $0.top == theme.dappImageTopPadding
            $0.centerX == 0
            $0.fitToSize(theme.dappImageSize)
        }
    }
    
    private func addTitle(_ theme: WCConnectionViewTheme) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == dappImageView.snp.bottom + theme.titleTopPadding
            $0.leading.trailing == theme.horizontalPadding
        }
    }
    
    private func addUrlAction(_ theme: WCConnectionViewTheme) {
        urlActionView.customizeAppearance(theme.urlAction)
        
        addSubview(urlActionView)
        urlActionView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.urlActionTopPadding
            $0.centerX == 0
            $0.leading.trailing <= theme.horizontalPadding
            $0.fitToHeight(theme.urlActionHeight)
        }
        
        startPublishing(
            event: .openUrl,
            for: urlActionView
        )
    }
    
    private func addSubtitle(_ theme: WCConnectionViewTheme) {
        subtitleContainerView.customizeAppearance(theme.subtitleContainer)
        
        addSubview(subtitleContainerView)
        subtitleContainerView.snp.makeConstraints {
            $0.top == urlActionView.snp.bottom + theme.subtitleContainerTopPadding
            $0.leading.trailing == theme.horizontalPadding
        }
        
        addSubtitleLabel(theme)
        addSubtitleSeparator(theme)
        
        subtitleContainerView.bringSubviewToFront(subtitleView)
    }
    
    private func addSubtitleLabel(_ theme: WCConnectionViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)
        subtitleView.contentEdgeInsets = theme.subtitleContentEdgeInsets
        
        subtitleContainerView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top.bottom == 0
            $0.centerX == 0
        }
    }
    
    private func addSubtitleSeparator(_ theme: WCConnectionViewTheme) {
        subtitleContainerView.attachSeparator(
            theme.subtitleSeparator,
            to: subtitleView
        )
    }
    
    private func addAccountList(_ theme: WCConnectionViewTheme) {
        addSubview(accountListView)
        accountListView.snp.makeConstraints {
            $0.top == subtitleContainerView.snp.bottom
            $0.leading.trailing.bottom == 0
        }
    }
}

extension WCConnectionView: ViewModelBindable {
    func bindData(_ viewModel: WCConnectionViewModel?) {
        guard let viewModel = viewModel else { return }
        
        dappImageView.load(from: viewModel.image)
        
        if let title = viewModel.title {
            title.load(in: titleView)
        }

        urlActionView.setImage(
            viewModel.actionIcon?.uiImage,
            for: .normal
        )
        
        urlActionView.setTitle(
            viewModel.urlString,
            for: .normal
        )
        
        if let subtitle = viewModel.subtitle {
            subtitle.load(in: subtitleView)
        }
    }
    
    func calculateTopViewHeight(
        _ viewModel: WCConnectionViewModel,
        for theme: WCConnectionViewTheme
    ) -> LayoutMetric {
        let dappImageSize = theme.dappImageSize
        
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((self.bounds.width, .greatestFiniteMagnitude))
        ) ?? .zero
        
        let actionHeight = theme.urlActionHeight
        
        let subtitleSize = viewModel.subtitle?.boundingSize(
            multiline: false,
            fittingSize: CGSize((self.bounds.width, .greatestFiniteMagnitude))
        ) ?? .zero
        
        let totalItemHeight = dappImageSize.h
            + titleSize.height
            + actionHeight
            + subtitleSize.height
        
        let totalVerticalSpacing = theme.dappImageTopPadding
            + theme.titleTopPadding
            + theme.urlActionTopPadding
            + theme.subtitleContainerTopPadding

        return totalItemHeight + totalVerticalSpacing
    }
}

extension WCConnectionView {
    enum Event {
        case openUrl
    }
}
