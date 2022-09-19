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
//   TransactionOptionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class TransactionOptionsView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buyAlgo: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .receive: TargetActionInteraction(),
        .scanQRCode: TargetActionInteraction(),
        .close: GestureInteraction()
    ]

    private lazy var backgroundView = MacaroonUIKit.BaseView()
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var contextView = VStackView()

    private var backgroundStartStyle: ViewStyle = []
    private var backgroundEndStyle: ViewStyle = []
    
    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []

    private let actions: [Action]

    init(actions: [Action] = Action.allCases) {
        self.actions = actions
        super.init(frame: .zero)
    }
        
    func customize(
        _ theme: TransactionOptionsViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension TransactionOptionsView {
    func updateBeforeAnimations(
        for position: Position
    ) {
        updateContentBeforeAnimations(for: position)
    }
    
    func updateAlongsideAnimations(
        for position: Position
    ) {
        updateBackground(for: position)
        updateContentAlongsideAnimations(for: position)
    }
}

extension TransactionOptionsView {
    private func addBackground(
        _ theme: TransactionOptionsViewTheme
    ) {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges == 0
        }

        backgroundStartStyle = theme.backgroundStart
        backgroundEndStyle = theme.backgroundEnd
        
        updateBackground(for: .start)
        
        startPublishing(
            event: .close,
            for: backgroundView
        )
    }
    
    private func updateBackground(
        for position: Position
    ) {
        let style: ViewStyle
        
        switch position {
        case .start: style = backgroundStartStyle
        case .end: style = backgroundEndStyle
        }
        
        backgroundView.customizeAppearance(style)
    }
    
    private func addContent(
        _ theme: TransactionOptionsViewTheme
    ) {
        contentView.customizeAppearance(theme.content)
        contentView.draw(corner: theme.contentCorner)
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
        }
        contentView.snp.prepareConstraints {
            contentStartLayout = [ $0.top == snp.bottom ]
            contentEndLayout = [ $0.bottom == 0 ]
        }
        
        updateContent(for: .start)
        
        addContext(theme)
    }
    
    private func updateContent(
        for position: Position
    ) {
        updateContentBeforeAnimations(for: position)
        updateContentAlongsideAnimations(for: position)
    }
    
    private func updateContentBeforeAnimations(
        for position: Position
    ) {
        let currentLayout: [Constraint]
        let nextLayout: [Constraint]
        
        switch position {
        case .start:
            currentLayout = contentEndLayout
            nextLayout = contentStartLayout
        case .end:
            currentLayout = contentStartLayout
            nextLayout = contentEndLayout
        }
        
        currentLayout.deactivate()
        nextLayout.activate()
    }
    
    private func updateContentAlongsideAnimations(
        for position: Position
    ) {
        contextView.alpha = position == .start ? 0 : 1
    }
    
    private func addContext(
        _ theme: TransactionOptionsViewTheme
    ) {
        contentView.addSubview(contextView)
        contextView.spacing = theme.spacingBetweenActions
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top + theme.contentSafeAreaInsets.top,
            leading: theme.contentPaddings.leading + theme.contentSafeAreaInsets.left,
            bottom: theme.contentPaddings.bottom + theme.contentSafeAreaInsets.bottom,
            trailing: theme.contentPaddings.trailing + theme.contentSafeAreaInsets.right
        )
        contextView.insetsLayoutMarginsFromSafeArea = false
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
        
        addButtons(theme)
    }

    private func addButtons(
        _ theme: TransactionOptionsViewTheme
    ) {
        actions.forEach {
            switch $0 {
            case .buyAlgo:
                addButton(
                    theme: theme.button,
                    viewModel: BuyAlgoTransactionOptionListItemButtonViewModel(),
                    event: .buyAlgo
                )
            case .send:
                addButton(
                    theme: theme.button,
                    viewModel: SendTransactionOptionListItemButtonViewModel(),
                    event: .send
                )
            case .receive:
                addButton(
                    theme: theme.button,
                    viewModel: ReceiveTransactionOptionListItemButtonViewModel(),
                    event: .receive
                )
            case .scanQRCode:
                addButton(
                    theme: theme.button,
                    viewModel: ScanQRCodeTransactionOptionListItemButtonViewModel(),
                    event: .scanQRCode
                )
            }
        }
    }

    private func addButton(
        theme: ListItemButtonTheme,
        viewModel: TransactionOptionListItemButtonViewModel,
        event: Event
    ) {
        let button = ListItemButton()
        
        button.customize(theme)
        button.bindData(viewModel)

        contextView.addArrangedSubview(button)

        startPublishing(
            event: event,
            for: button
        )
    }
}

extension TransactionOptionsView {
    enum Action: CaseIterable {
        case buyAlgo
        case send
        case receive
        case scanQRCode
    }

    enum Position {
        case start
        case end
    }
    
    enum Event {
        case buyAlgo
        case send
        case receive
        case scanQRCode
        case close
    }
}
