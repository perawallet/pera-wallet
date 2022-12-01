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

//   EditSwapSlippageScreen.swift

import Foundation
import MacaroonBottomSheet
import MacaroonForm
import MacaroonUIKit
import UIKit

final class EditSwapSlippageScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable,
    MacaroonForm.KeyboardControllerDataSource {
    /// <todo>
    /// EventHandler???
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    var modalBottomPadding: LayoutMetric {
        return bottomInsetUnderKeyboardWhenKeyboardDidShow(keyboardController)
    }

    let modalHeight: MacaroonUIKit.ModalHeight = .compressed

    private lazy var slippageTolerancePercentageInputView =
        AdjustableSingleSelectionInputView(theme.slippageTolerancePercentageInput)

    private lazy var slippageTolerancePercentageInputViewModel =
        SwapSlippageTolerancePercentageInputViewModel(percentage: dataStore.slippageTolerancePercentage)

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private var isValid = true

    private let dataStore: SwapSlippageTolerancePercentageStore
    private let dataProvider: EditSwapSlippageDataProvider

    private let theme: EditSwapSlippageScreenTheme = .init()

    init(
        dataStore: SwapSlippageTolerancePercentageStore,
        dataProvider: EditSwapSlippageDataProvider,
        configuration: ViewControllerConfiguration
    ) {
        self.dataStore = dataStore
        self.dataProvider = dataProvider
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        navigationItem.title = "swap-slippage-title".localized

        let doneItem = ALGBarButtonItem(kind: .done(Colors.Helpers.positive.uiColor)) {
            [unowned self] in
            if self.isValid {
                self.commitPreferredSlippageTolerancePercentage()
            }
        }
        rightBarButtonItems = [ doneItem ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardController()
        addUI()
    }
}

/// <mark>
/// MacaroonForm.KeyboardControllerDataSource
extension EditSwapSlippageScreen {
    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return keyboardController.keyboard?.height ?? 0
    }
}

extension EditSwapSlippageScreen {
    private func configureKeyboardController() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            self.performLayoutUpdates(animated: false)
        }
    }
}

extension EditSwapSlippageScreen {
    private func addUI() {
        addSlippageTolerancePercentageInput()
    }

    private func updateUIForSlippageTolerancePercentage(customText: String?) {
        if isValid != slippageTolerancePercentageInputView.isValid {
            performLayoutUpdates(animated: isViewAppeared)
        }
    }

    private func addSlippageTolerancePercentageInput() {
        contentView.addSubview(slippageTolerancePercentageInputView)
        slippageTolerancePercentageInputView.snp.makeConstraints {
            $0.top == theme.slippageTolerancePercentageInputEdgeInsets.top
            $0.leading == theme.slippageTolerancePercentageInputEdgeInsets.leading
            $0.bottom <= theme.slippageTolerancePercentageInputEdgeInsets.bottom
            $0.trailing == theme.slippageTolerancePercentageInputEdgeInsets.trailing
        }

        slippageTolerancePercentageInputView.textInputFormatter = PercentageInputFormatter()
        slippageTolerancePercentageInputView.textInputValidator = SwapSlippageTolerancePercentageValidator()
        slippageTolerancePercentageInputView.bind(slippageTolerancePercentageInputViewModel)

        slippageTolerancePercentageInputView.addTarget(
            self,
            action: #selector(determineActionForPreferredSlippageTolerancePercentage),
            for: .valueChanged
        )
    }
}

extension EditSwapSlippageScreen {
    @objc
    private func determineActionForPreferredSlippageTolerancePercentage() {
        switch slippageTolerancePercentageInputView.value {
        case .none: applyUpdatesForSlippageTolerancePercentage(customText: nil)
        case .custom(let text): applyUpdatesForSlippageTolerancePercentage(customText: text)
        case .option(let index): commitSlippageTolerancePercentage(optionAt: index)
        }
    }

    private func commitPreferredSlippageTolerancePercentage() {
        switch slippageTolerancePercentageInputView.value {
        case .none: dataProvider.saveSlippageTolerancePercentage(nil)
        case .custom(let text): saveSlippageTolerancePercentage(customText: text)
        case .option(let index): saveSlippageTolerancePercentage(optionAt: index)
        }

        eventHandler?(.didComplete)
    }

    private func applyUpdatesForSlippageTolerancePercentage(customText: String?) {
        updateUIForSlippageTolerancePercentage(customText: customText)
        isValid = slippageTolerancePercentageInputView.isValid
    }

    private func saveSlippageTolerancePercentage(customText: String) {
        let percentage = Decimal(string: customText, locale: Locale.current)
            .unwrap { CustomSwapSlippageTolerancePercentage(value: $0, title: customText) }
        dataProvider.saveSlippageTolerancePercentage(percentage)
    }

    private func commitSlippageTolerancePercentage(optionAt index: Int) {
        isValid = true
        saveSlippageTolerancePercentage(optionAt: index)

        eventHandler?(.didComplete)
    }

    private func saveSlippageTolerancePercentage(optionAt index: Int) {
        let percentage = slippageTolerancePercentageInputViewModel.percentagesPreset[safe: index]
        dataProvider.saveSlippageTolerancePercentage(percentage)
    }
}

extension EditSwapSlippageScreen {
    enum Event {
        case didComplete
    }
}
