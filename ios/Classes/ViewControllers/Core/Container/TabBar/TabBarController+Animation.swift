// Copyright 2019 Algorand, Inc.

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
//  TabBarController+Animation.swift

import UIKit

extension TabBarController {
    func presentTransactionFlow() {
        addTransactionButtons()
        animateCenterButtonAsSelected(true)
        animateSendButton()
        animateReceiveButton()
    }
    
    func hideTransactionFlow() {
        animateCenterButtonAsSelected(false)
        hideSendButton()
        hideReceiveButton()
    }
    
    private func animateCenterButtonAsSelected(_ isSelected: Bool) {
        let centerBarButton = tabBar.barButtons[2].contentView
        let icon = isSelected ? items[2].barButtonItem.selectedIcon : items[2].barButtonItem.icon
        
        UIView.transition(
            with: centerBarButton,
            duration: 0.15,
            options: .transitionCrossDissolve,
            animations: {
                centerBarButton.setImage(icon, for: .normal)
                centerBarButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 0.2,
                    options: [.allowUserInteraction, .curveEaseOut],
                    animations: {
                        centerBarButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    },
                    completion: nil
                )
            }
        )
    }
    
    private func addTransactionButtons() {
        view.addSubview(sendButton)
        sendButton.frame = CGRect(x: view.frame.width / 2.0, y: tabBar.frame.minY + 5.0, width: 0.0, height: 0.0)
        
        view.addSubview(receiveButton)
        receiveButton.frame = CGRect(x: view.frame.width / 2.0, y: tabBar.frame.minY + 5.0, width: 0.0, height: 0.0)
        
        view.layoutIfNeeded()
    }
    
    private func animateSendButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.allowUserInteraction, .curveEaseIn],
            animations: {
                self.sendButton.frame.origin.x -= 129.0
                self.sendButton.frame.origin.y -= 48.0
                self.sendButton.frame.size = CGSize(width: 116.0, height: 48.0)
            },
            completion: nil
        )
    }
    
    private func hideSendButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                self.sendButton.frame.origin.x += 129.0
                self.sendButton.frame.origin.y += 48.0
                self.sendButton.frame.size = CGSize(width: 10.0, height: 10.0)
            },
            completion: { _ in
                self.sendButton.removeFromSuperview()
            }
        )
    }
    
    private func animateReceiveButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.08,
            options: [.allowUserInteraction, .curveEaseInOut],
            animations: {
                self.receiveButton.frame.origin.x += 12.0
                self.receiveButton.frame.origin.y -= 48.0
                self.receiveButton.frame.size = CGSize(width: 116.0, height: 48.0)
            },
            completion: nil
        )
    }
    
    private func hideReceiveButton() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.08,
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                self.receiveButton.frame.origin.x -= 12.0
                self.receiveButton.frame.origin.y += 48.0
                self.receiveButton.frame.size = CGSize(width: 10.0, height: 10.0)
            },
            completion: { _ in
                self.receiveButton.removeFromSuperview()
            }
        )
    }
}
