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

//   ErrorScreen.swift

import MacaroonUIKit
import UIKit

final class ErrorScreen: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var iconBackgroundView = UIView()
    private lazy var iconView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var detailView = UILabel()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var secondaryActionView = MacaroonUIKit.Button()

    private let viewModel: ErrorScreenViewModel
    private let theme: ErrorScreenTheme

    init(
        viewModel: ErrorScreenViewModel,
        theme: ErrorScreenTheme,
        configuration: ViewControllerConfiguration
    ) {
        self.viewModel = viewModel
        self.theme = theme
        super.init(configuration: configuration)

        isModalInPresentation = true
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        hidesCloseBarButtonItem = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setPopGestureEnabled(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addTitle()
        addIconBackground()
        addIcon()
        addDetail()
        addSecondaryAction()
        addPrimaryAction()
    }

    override func bindData() {
        super.bindData()
        viewModel.title?.load(in: titleView)
        viewModel.detail?.load(in: detailView)
        viewModel.primaryAction?.load(in: primaryActionView)
        viewModel.secondaryAction?.load(in: secondaryActionView)
    }

    override func didTapBackBarButton() -> Bool {
        return false
    }
}

extension ErrorScreen {
    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.centerX == 0
            $0.centerY.equalToSuperview().offset(theme.titleCenterOffset)
            $0.leading == theme.titleHorizontalInset
            $0.trailing == theme.titleHorizontalInset
        }
    }

    private func addIconBackground() {
        iconBackgroundView.customizeAppearance(theme.iconBackground)
        iconBackgroundView.layer.draw(corner: theme.iconBackgroundCorner)

        contentView.addSubview(iconBackgroundView)
        iconBackgroundView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerX == 0
            $0.bottom == titleView.snp.top - theme.spacingBetweenIconAndTitle
        }
    }

    private func addIcon() {
        iconView.customizeAppearance(theme.icon)

        iconBackgroundView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.center == 0
        }
    }

    private func addDetail() {
        detailView.customizeAppearance(theme.detail)

        contentView.addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDetail
            $0.leading == theme.detailHorizontalInset
            $0.trailing == theme.detailHorizontalInset
        }
    }

    private func addSecondaryAction() {
        secondaryActionView.customizeAppearance(theme.secondaryAction)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        contentView.addSubview(secondaryActionView)
        secondaryActionView.snp.makeConstraints {
            $0.leading == theme.actionEdgeInsets.leading
            $0.trailing == theme.actionEdgeInsets.trailing

            let bottomInset =
                view.compactSafeAreaInsets.bottom +
                (navigationController ?? self).additionalSafeAreaInsets.bottom
                + theme.actionEdgeInsets.bottom
            $0.bottom == bottomInset
        }

        secondaryActionView.addTouch(
            target: self,
            action: #selector(didTapSecondaryAction)
        )
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        contentView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top >= detailView.snp.bottom + theme.actionEdgeInsets.top
            $0.leading == theme.actionEdgeInsets.leading
            $0.bottom == secondaryActionView.snp.top - theme.spacingBetweenActions
            $0.trailing == theme.actionEdgeInsets.trailing
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(didTapPrimaryAction)
        )
    }
}

extension ErrorScreen {
    @objc
    private func didTapPrimaryAction() {
        eventHandler?(.didTapPrimaryAction)
    }

    @objc
    private func didTapSecondaryAction() {
        eventHandler?(.didTapSecondaryAction)
    }
}

extension ErrorScreen {
    private func setPopGestureEnabled(_ isEnabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}

extension ErrorScreen {
    enum Event {
        case didTapPrimaryAction
        case didTapSecondaryAction
    }
}
