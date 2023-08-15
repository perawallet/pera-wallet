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

//   WebImportInstructionScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WebImportInstructionScreen: ScrollScreen, NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event, WebImportInstructionScreen) -> Void

    var eventHandler: EventHandler?

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private lazy var theme = WebImportInstructionScreenTheme()
    private lazy var titleView = Label()
    private lazy var firstInstructionView = InstructionItemView()
    private lazy var secondInstructionView = InstructionItemView()
    private lazy var thirdInstructionView = InstructionItemView()
    private lazy var fourthInstructionView = InstructionItemView()
    private lazy var startActionView = MacaroonUIKit.Button()

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private var isViewLayoutLoaded = false

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.customizeAppearance(theme.background)

        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isViewLayoutLoaded {
            return
        }

        updateUIWhenViewDidLayoutSubviews()

        isViewLayoutLoaded = true
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationBarLargeTitleController.title = "account-type-selection-import-web".localized
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }
}

extension WebImportInstructionScreen {
    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
        navigationBarLargeTitleController.activate()
    }
    
    private func addUI() {
        addNavigationBarLargeTitle()
        addTitle()
        addInstructions()
        addStartAction()
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(theme.titleEdgeInset.top)
            make.leading.equalToSuperview().inset(theme.titleEdgeInset.left)
            make.trailing.equalToSuperview().inset(theme.titleEdgeInset.right)
        }
    }

    private func addInstructions() {
        addFirstInstruction()
        addSecondInstruction()
        addThirdInstruction()
        addFourthInstruction()
    }

    private func addFirstInstruction() {
        firstInstructionView.customize(theme.instruction)
        contentView.addSubview(firstInstructionView)
        firstInstructionView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(theme.instructionEdgeInset.top)
            make.leading.equalToSuperview().inset(theme.instructionEdgeInset.left)
            make.trailing.equalToSuperview().inset(theme.instructionEdgeInset.right)
        }
        firstInstructionView.bindData(
            WebImportGoToPeraWebWalletInstructionItemViewModel(
                order: 1
            )
        )
    }

    private func addSecondInstruction() {
        secondInstructionView.customize(theme.instruction)
        contentView.addSubview(secondInstructionView)
        secondInstructionView.snp.makeConstraints { make in
            make.top.equalTo(firstInstructionView.snp.bottom).offset(theme.instructionEdgeInset.top)
            make.leading.equalToSuperview().inset(theme.instructionEdgeInset.left)
            make.trailing.equalToSuperview().inset(theme.instructionEdgeInset.right)
        }
        secondInstructionView.bindData(
            WebImportGoToTransferAccountsInstructionViewModel(
                order: 2
            )
        )
    }

    private func addThirdInstruction() {
        thirdInstructionView.customize(theme.instruction)
        contentView.addSubview(thirdInstructionView)
        thirdInstructionView.snp.makeConstraints { make in
            make.top.equalTo(secondInstructionView.snp.bottom).offset(theme.instructionEdgeInset.top)
            make.leading.equalToSuperview().inset(theme.instructionEdgeInset.left)
            make.trailing.equalToSuperview().inset(theme.instructionEdgeInset.right)
        }
        thirdInstructionView.bindData(
            WebImportSelectAccountsAndGenerateQRInstructionItemViewModel(
                order: 3
            )
        )
    }

    private func addFourthInstruction() {
        fourthInstructionView.customize(theme.instruction)
        contentView.addSubview(fourthInstructionView)
        fourthInstructionView.snp.makeConstraints { make in
            make.top.equalTo(thirdInstructionView.snp.bottom).offset(theme.instructionEdgeInset.top)
            make.leading.equalToSuperview().inset(theme.instructionEdgeInset.left)
            make.trailing.equalToSuperview().inset(theme.instructionEdgeInset.right)
            make.bottom.equalToSuperview().inset(theme.instructionEdgeInset.bottom).priority(.high)
            make.bottom.greaterThanOrEqualToSuperview().inset(theme.instructionEdgeInset.bottom).priority(.required)
        }
        fourthInstructionView.bindData(
            WebImportTapStartToScanQRInstructionItemViewModel(
                order: 4
            )
        )
    }

    private func addStartAction() {
        startActionView.customizeAppearance(theme.startAction)

        footerView.addSubview(startActionView)
        startActionView.contentEdgeInsets = theme.startActionContentEdgeInsets
        startActionView.snp.makeConstraints {
            $0.top == theme.startActionEdgeInsets.top
            $0.leading == theme.startActionEdgeInsets.leading
            $0.bottom == theme.startActionEdgeInsets.bottom
            $0.trailing == theme.startActionEdgeInsets.trailing
        }

        startActionView.addTouch(
            target: self,
            action: #selector(performStartAction)
        )
    }

    @objc
    private func performStartAction() {
        eventHandler?(.didStart, self)
    }
}

extension WebImportInstructionScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews() {
        scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height
    }
}

extension WebImportInstructionScreen {
    enum Event {
        case didStart
    }
}
