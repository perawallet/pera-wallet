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

//   AlertScreen.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonStorySheet

 /// <todo>:
 /// Refactor when `UISheetActionScreen` is refactored.
 final class AlertScreen:
    ScrollScreen,
    AlertUIScrollContentConfigurable {
     var modalHeight: ModalHeight {
         return .compressed
     }

     private lazy var contextView = MacaroonUIKit.BaseView()
     private lazy var imageView = ImageView()
     private lazy var newBadgeView = Label()
     private lazy var titleView = Label()
     private lazy var bodyView = Label()
     private lazy var actionsContextView = MacaroonUIKit.VStackView()

     private lazy var theme: AlertScreenTheme = alert.theme

     private var uiInteractions: [TargetActionInteraction] = []

     private let alert: Alert

     init(
        alert: Alert,
        api: ALGAPI?
     ) {
         self.alert = alert
         
         super.init(api: api)
     }

     override func prepareLayout() {
         super.prepareLayout()

         addContext()

         if alert.actions.isEmpty {
             return
         }

         addActionsContext()
     }
 }

 extension AlertScreen {
     private func addContext() {
         contentView.addSubview(contextView)

         contextView.snp.makeConstraints {
             $0.top == theme.contextEdgeInsets.top
             $0.leading == theme.contextEdgeInsets.leading
             $0.trailing == theme.contextEdgeInsets.trailing
             $0.bottom == theme.contextEdgeInsets.bottom
         }

         addImage()

         if alert.isNewBadgeVisible {
             addNewBadge()
         }

         addTitle()
         addBody()
     }

     private func addImage() {
         imageView.customizeAppearance(theme.image)

         contextView.addSubview(imageView)
         imageView.fitToIntrinsicSize()
         imageView.snp.makeConstraints {
             $0.top == theme.imageEdgeInsets.top
             $0.leading == theme.imageEdgeInsets.leading
             $0.trailing == theme.imageEdgeInsets.trailing
         }

         imageView.image = alert.image?.uiImage
     }

     private func addNewBadge() {
         contextView.addSubview(newBadgeView)
         newBadgeView.customizeAppearance(theme.newBadge)
         newBadgeView.draw(corner: theme.newBadgeCorner)
         newBadgeView.contentEdgeInsets = theme.newBadgeContentEdgeInsets

         newBadgeView.fitToIntrinsicSize()
         newBadgeView.snp.makeConstraints {
             $0.centerX == 0
             $0.top == imageView.snp.bottom + theme.newBadgeEdgeInsets.top
             $0.leading >= theme.newBadgeEdgeInsets.leading
             $0.trailing <= theme.newBadgeEdgeInsets.trailing
         }
     }

     private func addTitle() {
         contextView.addSubview(titleView)
         titleView.customizeAppearance(theme.title)

         titleView.fitToIntrinsicSize()
         titleView.snp.makeConstraints {
             $0.top == resolveTitleTopConstraint()
             $0.leading == theme.titleEdgeInsets.leading
             $0.trailing == theme.titleEdgeInsets.trailing
         }

         alert.title?.load(in: titleView)

         func resolveTitleTopConstraint() -> LayoutConstraint {
             if alert.isNewBadgeVisible {
                 return newBadgeView.snp.bottom + theme.newBadgeEdgeInsets.bottom
             }

             return imageView.snp.bottom + theme.titleEdgeInsets.top
         }
     }

     private func addBody() {
         contextView.addSubview(bodyView)
         bodyView.customizeAppearance(theme.body)

         bodyView.contentEdgeInsets.top = theme.bodyEdgeInsets.top
         bodyView.fitToIntrinsicSize()
         bodyView.snp.makeConstraints {
             $0.top == titleView.snp.bottom
             $0.leading == theme.bodyEdgeInsets.leading
             $0.trailing == theme.bodyEdgeInsets.trailing
             $0.bottom == theme.bodyEdgeInsets.bottom
         }

         alert.body?.load(in: bodyView)
     }

     private func addActionsContext() {
         footerView.addSubview(actionsContextView)
         actionsContextView.spacing = theme.actionSpacing

         actionsContextView.snp.makeConstraints {
             $0.top == theme.actionsEdgeInsets.top
             $0.leading == theme.actionsEdgeInsets.leading
             $0.trailing == theme.actionsEdgeInsets.trailing
             $0.bottom == theme.actionsEdgeInsets.bottom
         }

         addActions()
     }

     private func addActions() {
         alert.actions.forEach(addAction)
     }
 }

 extension AlertScreen {
     private func addAction(
         _ action: AlertAction
     ) {
         let actionView = createActionView(action)

         let interaction = TargetActionInteraction(
             actionView,
             handler: action.handler
         )

         uiInteractions.append(interaction)

         actionsContextView.addArrangedSubview(actionView)
     }

     private func createActionView(
         _ action: AlertAction
     ) -> UIButton {
         let actionView = MacaroonUIKit.Button()
         actionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

         actionView.customizeAppearance(
             theme.getActionStyle(
                 action.style,
                 title: action.title
             )
         )

         return actionView
     }
 }

 fileprivate extension TargetActionInteraction {
     convenience init(
         _ control: UIControl,
         handler: @escaping (() -> Void)
     ) {
         self.init()

         attach(to: control)
         setSelector(handler)
     }
 }
