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

//   RekeyInstructionsScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyInstructionsScreen: ScrollScreen {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var illustrationView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var bodyView = ALGActiveLabel()
    private lazy var instructionsTitleView = UILabel()
    private lazy var instructionsView = VStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private let draft: RekeyInstructionsDraft
    private let theme: RekeyInstructionsScreenTheme

    init(
        draft: RekeyInstructionsDraft,
        theme: RekeyInstructionsScreenTheme = .init(),
        api: ALGAPI?
    ) {
        self.draft = draft
        self.theme = theme
        super.init(api: api)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        hidesCloseBarButtonItem = true

        navigationItem.largeTitleDisplayMode = .never

        addNavigationBarButtonItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switchToTransparentNavigationBarAppearanceIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        switchToDefaultNavigationBarAppearanceIfNeeded()
    }

    override func addScroll() {
        super.addScroll()

        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? .zero
        scrollView.contentInset.top = theme.illustrationMaxHeight - navigationBarHeight
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

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        updateUIWhenViewDidScroll()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateUIWhenViewDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateUIWhenViewDidScroll()
    }
}

extension RekeyInstructionsScreen {
    private func updateUIWhenViewDidScroll() {
        updateIllustrationWhenViewDidScroll()
    }

    private func updateIllustrationWhenViewDidScroll() {
        let contentY = scrollView.contentOffset.y
        let preferredHeight = -contentY

        illustrationView.snp.updateConstraints {
            $0.fitToHeight(max(preferredHeight, theme.illustrationMinHeight))
        }
    }
}

extension RekeyInstructionsScreen {
    private func switchToTransparentNavigationBarAppearanceIfNeeded() {
        guard let navigationController else { return }

        if !navigationController.isBeingPresented || isViewFirstAppeared {
            switchToTransparentNavigationBarAppearance()
        }
    }

    private func switchToDefaultNavigationBarAppearanceIfNeeded() {
        guard let navigationController else { return }

        if !navigationController.isBeingDismissed {
            switchToDefaultNavigationBarAppearance()
        }
    }
}

extension RekeyInstructionsScreen {
    private func addNavigationBarButtonItems() {
        leftBarButtonItems = [ makeCloseBarButtonItem() ]
    }

    private func makeCloseBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .close(UIColor.white)) {
            [unowned self] in
            self.eventHandler?(.performCloseAction)
        }
    }
}

extension RekeyInstructionsScreen {
    private func addUI() {
        addBackground()
        addIllustration()
        addTitle()
        addBody()
        addInstructionsTitle()
        addInstructions()
        addPrimaryAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addIllustration() {
        illustrationView.customizeAppearance(theme.illustration)
        illustrationView.clipsToBounds = true
        illustrationView.isUserInteractionEnabled = false

        view.addSubview(illustrationView)
        illustrationView.snp.makeConstraints {
            $0.fitToHeight(theme.illustrationMaxHeight)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindIllustration()

        addIllustrationBackground()
    }

    private func addIllustrationBackground() {
        let backgroundView = GradientView()
        backgroundView.colors = [
            Colors.Defaults.background.uiColor,
            Colors.Defaults.background.uiColor.withAlphaComponent(0)
        ]
        backgroundView.isUserInteractionEnabled = false

        view.insertSubview(
            backgroundView,
            belowSubview: illustrationView
        )
        backgroundView.snp.makeConstraints {
            let height = theme.titleTopInset
            $0.fitToHeight(height)

            $0.top == illustrationView.snp.bottom
            $0.leading == illustrationView
            $0.trailing == illustrationView
        }
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopInset
            $0.leading == theme.titleHorizontalEdgeInsets.leading
            $0.trailing == theme.titleHorizontalEdgeInsets.trailing
        }

        bindTitle()
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == theme.bodyHorizontalEdgeInsets.leading
            $0.trailing == theme.bodyHorizontalEdgeInsets.trailing
        }

        bindBody()
    }

    private func addInstructionsTitle() {
        instructionsTitleView.customizeAppearance(theme.instructionsTitle)

        contentView.addSubview(instructionsTitleView)
        instructionsTitleView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndInstructionsTitle
            $0.leading == theme.instructionsHorizontalEdgeInsets.leading
            $0.trailing == theme.instructionsHorizontalEdgeInsets.trailing
        }

        bindInstructionsTitle()
    }

    private func addInstructions() {
        contentView.addSubview(instructionsView)
        instructionsView.spacing = theme.instructionsSpacing
        instructionsView.snp.makeConstraints {
            $0.top == instructionsTitleView.snp.bottom + theme.spacingBetweenInstructionTitleAndInstructions
            $0.leading == theme.instructionsHorizontalEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.instructionsHorizontalEdgeInsets.trailing
        }

        bindInstructions()
    }

    private func addInstruction(_ viewModel: InstructionItemViewModel) {
        let view = InstructionItemView()
        view.customize(theme.instruction)
        view.bindData(viewModel)
        instructionsView.addArrangedSubview(view)
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets

        footerView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top == theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.trailing == theme.primaryActionEdgeInsets.trailing
            $0.bottom == theme.primaryActionEdgeInsets.bottom
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        bindPrimaryAction()
    }
}

extension RekeyInstructionsScreen {
    private func bindIllustration() {
        illustrationView.image = draft.image.uiImage
    }

    private func bindTitle() {
        draft.title.load(in: titleView)
    }

    private func bindBody() {
        let body = draft.body
        if let highlightedText = body.highlightedText {
            let hyperlink: ALGActiveType = .word(highlightedText.text)
            bodyView.attachHyperlink(
                hyperlink,
                to: body.text,
                attributes: highlightedText.attributes
            ) {
                [unowned self] in
                self.open(AlgorandWeb.rekey.link)
            }
            return
        }

        body.text.load(in: bodyView)
    }

    private func bindInstructionsTitle() {
        instructionsTitleView.attributedText =
        "rekey-instruction-header"
            .localized
            .footnoteHeadingMedium(lineBreakMode: .byTruncatingTail)
    }

    private func bindInstructions() {
        let instructions = draft.instructions
        instructions.forEach(addInstruction)
    }

    private func bindPrimaryAction() {
        primaryActionView.editTitle = .string("rekey-instruction-start".localized)
    }
}

extension RekeyInstructionsScreen {
    @objc
    private func performPrimaryAction() {
        eventHandler?(.performPrimaryAction)
    }
}

extension RekeyInstructionsScreen {
    enum Event {
        case performCloseAction
        case performPrimaryAction
    }
}
