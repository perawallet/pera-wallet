// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetListItemLoadingView.swift

import MacaroonUIKit
import UIKit

final class ManageAssetListItemLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var imageView = ShimmerView()
    private lazy var textContainerView = UIView()
    private lazy var titleView = ShimmerView()
    private lazy var subtitleView = ShimmerView()
    private lazy var actionView = ShimmerView()
    
    func customize(_ theme: ManageAssetListItemLoadingViewTheme) {
        addImage(theme)
        addTextContainer(theme)
        addAction(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension ManageAssetListItemLoadingView {
    private func addImage(_ theme: ManageAssetListItemLoadingViewTheme) {
        imageView.draw(corner: Corner(radius: theme.imageCorner))
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.imageSize.w,
                       height: theme.imageSize.h)
            )
        }
    }
    
    private func addTextContainer(_ theme: ManageAssetListItemLoadingViewTheme) {
        addSubview(textContainerView)
        textContainerView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.textContainerLeadingMargin)
            $0.centerY.equalToSuperview()
            $0.fitToWidth(theme.textContainerWidth)
        }
        
        addTitle(theme)
        addSubtitle(theme)
    }
    
    private func addTitle(_ theme: ManageAssetListItemLoadingViewTheme) {
        titleView.draw(corner: Corner(radius: theme.titleCorner))

        textContainerView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.size.equalTo(
                CGSize(
                    width: theme.titleSize.w,
                    height: theme.titleSize.h
                )
            )
        }
    }
    
    private func addSubtitle(_ theme: ManageAssetListItemLoadingViewTheme) {
        subtitleView.draw(corner: Corner(radius: theme.subtitleCorner))

        textContainerView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.subtitleTopPadding)
            $0.leading.bottom.equalToSuperview()
            $0.size.equalTo(
                CGSize(
                    width: theme.subtitleSize.w,
                    height: theme.subtitleSize.h
                )
            )
        }
    }
    
    private func addAction(_ theme: ManageAssetListItemLoadingViewTheme) {
        actionView.draw(corner: Corner(radius: theme.actionCorner))

        addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.actionSize.w,
                       height: theme.actionSize.h)
            )
        }
    }
}
