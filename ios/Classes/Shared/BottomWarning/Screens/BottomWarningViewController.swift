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
//  BottomWarningViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class BottomWarningViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    private let viewConfigurator: BottomWarningViewConfigurator

    init(
        _ viewConfigurator: BottomWarningViewConfigurator,
        configuration: ViewControllerConfiguration
    ) {
        self.viewConfigurator = viewConfigurator
        super.init(configuration: configuration)
    }

    private lazy var theme = Theme()
    private lazy var bottomWarningView = BottomWarningView()

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func setListeners() {
        bottomWarningView.handlers.didTapPrimaryActionButton = {
            [weak self] in
            self?.closeScreen(by: .dismiss, animated: true) {
                self?.viewConfigurator.primaryAction?()
            }
        }

        bottomWarningView.handlers.didTapSecondaryActionButton = {
            [weak self] in
            self?.closeScreen(by: .dismiss, animated: true) {
                self?.viewConfigurator.secondaryAction?()
            }
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        bottomWarningView.customize(theme.bottomWarningViewTheme)

        contentView.addSubview(bottomWarningView)
        bottomWarningView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        bottomWarningView.bindData(viewConfigurator)
    }
}

extension BottomWarningViewController {
    var modalHeight: ModalHeight {
        return .compressed
    }
}
