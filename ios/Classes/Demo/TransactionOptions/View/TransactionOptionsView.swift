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
        .performClose: GestureInteraction()
    ]

    private lazy var backgroundView = MacaroonUIKit.BaseView()
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var contextView = TransactionOptionsContextView(actions: actions)

    private var backgroundStartStyle: ViewStyle = []
    private var backgroundEndStyle: ViewStyle = []
    
    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []

    private var actions: [TransactionOptionListAction]

    init(actions: [TransactionOptionListAction]) {
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
            event: .performClose,
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
        contextView.customize(theme)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension TransactionOptionsView {
    enum Position {
        case start
        case end
    }

    enum Event {
        case performClose
    }
}
