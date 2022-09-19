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

//   BuyAlgoHomeView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class BuyAlgoHomeView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .close: TargetActionInteraction(),
        .buyAlgo: TargetActionInteraction()
    ]
    
    private var theme: BuyAlgoHomeViewTheme?
    
    private lazy var headerView = UIView()
    private lazy var logoView = ImageView()
    private lazy var headerBackgroundView = ImageView()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var closeButton = UIButton()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var descriptionLabel = Label()
    private lazy var securityLabel = Label()
    private lazy var securityImageView = ImageView()
    private lazy var paymentOptionsView = HStackView()
    private lazy var buyAlgoButtonContainer = UIView()
    private lazy var buyAlgoButton = MacaroonUIKit.Button()
    
    private var isLayoutFinalized = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        linkInteractors()
    }
    
    func customize(_ theme: BuyAlgoHomeViewTheme) {
        self.theme = theme
        
        addScrollView(theme)
        addContentView()
        addSubtitleLabel(theme)
        addDescriptionLabel(theme)
        addSecurityImageView(theme)
        addSecurityLabel(theme)
        addPaymentOptionsView(theme)
        addBuyAlgoButton(theme)
        addHeaderView(theme)
        addHeaderBackgroundView(theme)
        addLogoView(theme)
        addCloseButton(theme)
        addTitleLabel(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func bindData(_ viewModel: BuyAlgoHomeViewModel?) {
        logoView.image = viewModel?.logoImage?.uiImage
        headerBackgroundView.image = viewModel?.headerBackgroundImage?.uiImage
        titleLabel.editText = viewModel?.title
        subtitleLabel.editText = viewModel?.subtitle
        descriptionLabel.editText = viewModel?.description
        securityImageView.image = viewModel?.securityImage?.uiImage
        securityLabel.editText = viewModel?.security

        if let paymentMethodImages = viewModel?.paymentMethodImages {
            for paymentMethodImage in paymentMethodImages {
                let paymentMethodImageView = ImageView()
                paymentMethodImageView.image = paymentMethodImage.uiImage
                paymentOptionsView.addArrangedSubview(paymentMethodImageView)
            }
        }
    }
    
    func linkInteractors() {
        scrollView.delegate = self
        
        startPublishing(event: .close, for: closeButton)
        startPublishing(event: .buyAlgo, for: buyAlgoButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        if !isLayoutFinalized {
            isLayoutFinalized = true

            addLinearGradient()
        }
    }
}

extension BuyAlgoHomeView {
    private func addScrollView(_ theme: BuyAlgoHomeViewTheme){
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset.top = theme.headerMaxHeight
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func addContentView(){
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.edges.equalToSuperview()
        }
    }
    private func addSubtitleLabel(_ theme: BuyAlgoHomeViewTheme){
        subtitleLabel.customizeAppearance(theme.subtitleLabel)
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.subtitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addDescriptionLabel(_ theme: BuyAlgoHomeViewTheme){
        descriptionLabel.customizeAppearance(theme.descriptionLabel)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.descriptionLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(
                theme.descriptionLabelBottomPadding +
                theme.linearGradientHeight +
                safeAreaBottom
            )
        }
    }
    private func addSecurityImageView(_ theme: BuyAlgoHomeViewTheme) {
        contentView.addSubview(securityImageView)
        securityImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.securityImageTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addSecurityLabel(_ theme: BuyAlgoHomeViewTheme){
        securityLabel.customizeAppearance(theme.securityLabel)
        
        contentView.addSubview(securityLabel)
        securityLabel.snp.makeConstraints {
            $0.centerY.equalTo(securityImageView)
            $0.leading.equalTo(securityImageView.snp.trailing).offset(theme.securityLabelLeadingPadding)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addPaymentOptionsView(_ theme: BuyAlgoHomeViewTheme){
        paymentOptionsView.distribution = .fillProportionally
        paymentOptionsView.alignment = .top
        paymentOptionsView.spacing = theme.paymentViewSpacing
        contentView.addSubview(paymentOptionsView)
        paymentOptionsView.snp.makeConstraints {
            $0.top.equalTo(securityLabel.snp.bottom).offset(theme.paymentViewTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.paymentViewBottomPadding)
        }
    }
    private func addBuyAlgoButton(_ theme: BuyAlgoHomeViewTheme){
        addSubview(buyAlgoButtonContainer)
        buyAlgoButtonContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.fitToHeight(theme.linearGradientHeight + safeAreaBottom)
        }

        buyAlgoButton.contentEdgeInsets = UIEdgeInsets(theme.buttonContentEdgeInsets)
        buyAlgoButton.draw(corner: theme.buttonCorner)
        buyAlgoButton.customizeAppearance(theme.buyAlgoButton)

        buyAlgoButtonContainer.addSubview(buyAlgoButton)
        buyAlgoButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }
    }
    private func addHeaderView(_ theme: BuyAlgoHomeViewTheme){
        headerView.customizeAppearance(theme.header)
        
        addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.headerMaxHeight)
        }
    }
    private func addHeaderBackgroundView(_ theme: BuyAlgoHomeViewTheme) {
        headerBackgroundView.customizeAppearance(theme.headerBackgroundView)
        headerView.addSubview(headerBackgroundView)
        headerBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    private func addLogoView(_ theme: BuyAlgoHomeViewTheme){
        logoView.customizeAppearance(theme.logoView)
        
        headerView.addSubview(logoView)
        logoView.snp.makeConstraints {
            $0.fitToSize(theme.logoMaxSize)
            $0.center.equalToSuperview()
        }
    }
    private func addCloseButton(_ theme: BuyAlgoHomeViewTheme){
        closeButton.customizeAppearance(theme.closeButton)
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.closeButtonTopPadding)
            $0.leading.equalToSuperview().inset(theme.closeButtonLeadingPadding)
            $0.fitToSize(theme.closeButtonSize)
        }
    }
    private func addTitleLabel(_ theme: BuyAlgoHomeViewTheme){
        titleLabel.customizeAppearance(theme.titleLabel)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func addLinearGradient() {
        guard let theme = theme else {
            return
        }
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(
            origin: .zero,
            size: CGSize(width: bounds.width, height: theme.linearGradientHeight + safeAreaBottom)
        )

        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = Colors.Defaults.background.uiColor.cgColor

        layer.colors = [color0, color1]
        buyAlgoButtonContainer.layer.insertSublayer(layer, at: 0)
    }
}


/// <note>: Parallax effect
extension BuyAlgoHomeView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        guard let theme = self.theme else {
            return
        }

        let height = theme.headerMaxHeight - contentY

        if height < theme.headerMinHeight {
            return
        }

        headerView.snp.updateConstraints {
            $0.fitToHeight(height)
        }

        let calculatedWidth = max(
            theme.logoMinSize.w,
            theme.logoMaxSize.w * height / theme.headerMaxHeight
        )

        let calculatedHeight = max(
            theme.logoMinSize.h,
            theme.logoMaxSize.h * height / theme.headerMaxHeight
        )

        logoView.snp.updateConstraints {
            $0.fitToSize((calculatedWidth, calculatedHeight))
        }
    }
}

extension BuyAlgoHomeView {
    enum Event {
        case close
        case buyAlgo
    }
}
