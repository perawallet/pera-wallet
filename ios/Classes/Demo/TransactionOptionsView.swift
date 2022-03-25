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

/// <todo>:
/// Move this to Macaroon
public final class UIViewTapInteraction: MacaroonUIKit.UIInteraction {
    private var view: UIView?
    private var handler: Handler?
}

extension UIViewTapInteraction {
    public func link(
        _ view: UIView
    ) {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(deliverAction)
            )
        )

        self.view = view
    }

    public func unlink() {
        view?.removeGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(deliverAction)
            )
        )

        self.view = nil
    }

    public func activate(
        _ handler: @escaping Handler
    ) {
        self.handler = handler
    }

    public func deactivate() {
        self.handler = nil
    }
}

extension UIViewTapInteraction {
    @objc
    private func deliverAction() {
        handler?()
    }
}

// <note>: Can it be better to renamte it as InteractionPublisher?
extension UIControlInteractionPublisher {
    public func startPublishing(
        event: Event,
        for view: UIView
    ) {
        let interaction = uiInteractions[event] as? UIViewTapInteraction
        interaction?.link(view)
    }
}

final class TransactionOptionsView:
    View,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .send: UIControlInteraction(),
        .receive: UIControlInteraction(),
        .buyAlgo: UIControlInteraction(),
        .close: UIViewTapInteraction()
    ]
    
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var actionsView = HStackView()
    private lazy var sendActionView =
        MacaroonUIKit.Button(.imageAtTop(spacing: spacingBetweenActionIconAndTitle))
    private lazy var receiveActionView =
        MacaroonUIKit.Button(.imageAtTop(spacing: spacingBetweenActionIconAndTitle))
    private lazy var buyAlgoActionView =
        MacaroonUIKit.Button(.imageAtTop(spacing: spacingBetweenActionIconAndTitle))
    
    private var backgroundStartStyle: ViewStyle = []
    private var backgroundEndStyle: ViewStyle = []
    
    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []
    
    private let spacingBetweenActionIconAndTitle: CGFloat = 15
    
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
        backgroundStartStyle = theme.backgroundStart
        backgroundEndStyle = theme.backgroundEnd
        
        updateBackground(for: .start)

        startPublishing(
            event: .close,
            for: self
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
        
        customizeAppearance(style)
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
        
        addActions(theme)
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
        actionsView.alpha = position == .start ? 0 : 1
    }
    
    private func addActions(
        _ theme: TransactionOptionsViewTheme
    ) {
        contentView.addSubview(actionsView)
        actionsView.alignment = .top
        actionsView.spacing = theme.spacingBetweenActions
        actionsView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == theme.actionsVerticalPaddings.top + theme.contentSafeAreaInsets.top
            $0.leading >= theme.actionsMinHorizontalPaddings.leading + theme.contentSafeAreaInsets.left
            $0.bottom == theme.actionsVerticalPaddings.bottom + theme.contentSafeAreaInsets.bottom
            $0.trailing <= theme.actionsMinHorizontalPaddings.trailing + theme.contentSafeAreaInsets.right
        }
        
        addSendAction(theme)
        addReceiveAction(theme)
        addBuyAction(theme)
    }
    
    private func addSendAction(
        _ theme: TransactionOptionsViewTheme
    ) {
        sendActionView.customizeAppearance(theme.sendAction)
        actionsView.addArrangedSubview(sendActionView)
        
        startPublishing(
            event: .send,
            for: sendActionView
        )
    }
    
    private func addReceiveAction(
        _ theme: TransactionOptionsViewTheme
    ) {
        receiveActionView.customizeAppearance(theme.receiveAction)
        actionsView.addArrangedSubview(receiveActionView)
        
        startPublishing(
            event: .receive,
            for: receiveActionView
        )
    }

    private func addBuyAction(
        _ theme: TransactionOptionsViewTheme
    ) {
        buyAlgoActionView.customizeAppearance(theme.buyAlgoAction)
        actionsView.addArrangedSubview(buyAlgoActionView)

        startPublishing(
            event: .buyAlgo,
            for: buyAlgoActionView
        )
    }
}

extension TransactionOptionsView {
    enum Position {
        case start
        case end
    }
    
    enum Event {
        case send
        case receive
        case close
        case buyAlgo
    }
}
