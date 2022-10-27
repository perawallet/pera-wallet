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
//   PortfolioCalculationInfoViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import UIKit

final class PortfolioCalculationInfoViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var contextView = VStackView()

    private lazy var closeActionViewContainer = UIView()
    private lazy var closeActionView =
        ViewFactory.Button.makeSecondaryButton("title-close".localized)
    
    private let result: PortfolioValue?

    private let theme: PortfolioCalculationInfoViewControllerTheme
    
    init(
        result: PortfolioValue?,
        configuration: ViewControllerConfiguration,
        theme: PortfolioCalculationInfoViewControllerTheme = .init()
    ) {
        self.result = result
        self.theme = theme

        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private var isLayoutFinalized = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLayoutFinalized {
            isLayoutFinalized = true

            addLinearGradient()
        }
    }
    
    private func build() {
        addBackground()
        addContext()
        
        switch result {
        case .available:
            addInfo(topPadding: 0)
        case .none,
             .failure:
            addError()
            addInfo(topPadding: theme.spacingBetweenErrorAndInfo)
        case .partialFailure:
            addPartialAccountError()
            addInfo(topPadding: theme.spacingBetweenErrorAndInfo)
        }
        
        addCloseAction()
    }
}

extension PortfolioCalculationInfoViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentTopPadding,
            leading: theme.contentHorizontalPaddings.leading,
            bottom: 0,
            trailing: theme.contentHorizontalPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom <= 0
        }
    }
    
    private func addError() {
        let errorView = ErrorView()

        errorView.customize(theme.error)
        errorView.bindData(PortfolioCalculationErrorViewModel())
        
        contextView.addArrangedSubview(errorView)
    }

    private func addPartialAccountError() {
        let errorView = ErrorView()

        errorView.customize(theme.error)
        errorView.bindData(PortfolioCalculationPartialErrorViewModel())

        contextView.addArrangedSubview(errorView)
    }
    
    private func addInfo(
        topPadding: LayoutMetric
    ) {
        let infoCanvasView = UIView()
        let infoView = PortfolioCalculationInfoView()
        
        infoView.customize(theme.info)
        
        infoCanvasView.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.top == topPadding
            $0.leading == 0
            $0.bottom == theme.linearGradientHeight + view.safeAreaBottom
            $0.trailing == 0
        }

        contextView.addArrangedSubview(infoCanvasView)
    }
    
    private func addCloseAction() {
        view.addSubview(closeActionViewContainer)
        closeActionViewContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.fitToHeight(
                view.safeAreaBottom +
                theme.linearGradientHeight
            )
        }

        closeActionViewContainer.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.leading == theme.contentHorizontalPaddings.leading
            $0.bottom == theme.footerVerticalPaddings.bottom + view.safeAreaBottom
            $0.trailing == theme.contentHorizontalPaddings.trailing
        }
        
        closeActionView.addTouch(
            target: self,
            action: #selector(close)
        )
    }

    private func addLinearGradient() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: view.bounds.width,
                height: view.safeAreaBottom + theme.linearGradientHeight
            )
        )

        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = Colors.Defaults.background.uiColor.cgColor

        layer.colors = [color0, color1]
        closeActionViewContainer.layer.insertSublayer(layer, at: 0)
    }
}

extension PortfolioCalculationInfoViewController {
    @objc
    private func close() {
        eventHandler?(.close)
    }
}

extension PortfolioCalculationInfoViewController {
    enum Event {
        case close
    }
}
