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
//   HomeNoContentView.swift

import Foundation
import MacaroonUIKit
import UIKit

/// <todo>
/// Refactor
final class HomeNoContentView:
    View,
    UIInteractionObservable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAction: UIBlockInteraction()
    ]
    
    private lazy var contentView = NoContentWithActionView()
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        addContent()
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension HomeNoContentView {
    func addContent() {
        contentView.customize(NoContentWithActionViewCommonTheme())
        contentView.bindData(HomeNoContentViewModel())
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
        
        contentView.handlers.didTapActionView = {
            [weak self] in
            guard let self = self else { return }
            
            let interaction = self.uiInteractions[.performAction] as? UIBlockInteraction
            interaction?.notify()
        }
    }
}

extension HomeNoContentView {
    enum Event {
        case performAction
    }
}

final class UIBlockInteraction: MacaroonUIKit.UIInteraction {
    private var handler: Handler?
    
    func activate(
        _ handler: @escaping Handler
    ) {
        self.handler = handler
    }

    func deactivate() {
        self.handler = nil
    }
    
    func notify() {
        handler?()
    }
}
