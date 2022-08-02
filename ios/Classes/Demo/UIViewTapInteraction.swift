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

//   UIViewTapInteraction.swift

import UIKit
import MacaroonUIKit

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

extension UIControlInteractionPublisher {
    public func startPublishing(
        event: Event,
        for view: UIView
    ) {
        let interaction = uiInteractions[event] as? UIViewTapInteraction
        interaction?.link(view)
    }
}
