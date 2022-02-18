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
//   SingleLineTitleActionView.swift

import UIKit
import MacaroonUIKit

final class SingleLineTitleActionView: View {
    lazy var handlers = Handlers()

    private lazy var titleLabel = UILabel()
    private lazy var actionButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(SingleLineTitleActionViewTheme())
        setListeners()
    }

    func customize(_ theme: SingleLineTitleActionViewTheme) {
        addActionButton(theme)
        addTitleLabel(theme)
    }

    func setListeners() {
        actionButton.addTarget(self, action: #selector(didHandleAction), for: .touchUpInside)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension SingleLineTitleActionView {
    private func addActionButton(_ theme: SingleLineTitleActionViewTheme) {
        actionButton.customizeAppearance(theme.action)

        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.actionTrailingPadding)
            $0.size.equalTo(CGSize(theme.actionSize))
        }
    }
    
    private func addTitleLabel(_ theme: SingleLineTitleActionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.titleLeadingPadding)
            $0.trailing.equalTo(actionButton.snp.leading).offset(-theme.titleTrailingPadding)
        }
    }
}

extension SingleLineTitleActionView {
    @objc
    private func didHandleAction() {
        handlers.didHandleAction?()
    }
}

extension SingleLineTitleActionView: ViewModelBindable {
    func bindData(_ viewModel: SingleLineTitleActionViewModel?) {
        titleLabel.editText = viewModel?.title
        actionButton.setImage(viewModel?.actionImage?.uiImage, for: .normal)
    }
}

extension SingleLineTitleActionView {
    struct Handlers {
        var didHandleAction: EmptyHandler?
    }
}

class SingleLineTitleActionHeaderView: BaseSupplementaryView<SingleLineTitleActionView> {

    lazy var handlers = Handlers()

    override func setListeners() {
        contextView.handlers.didHandleAction = { [weak self] in
            guard let self = self else {
                return
            }

            self.handlers.didHandleAction?()
        }
    }

    func bindData(_ viewModel: SingleLineTitleActionViewModel) {
        contextView.bindData(viewModel)
    }
}

extension SingleLineTitleActionHeaderView {
    struct Handlers {
        var didHandleAction: EmptyHandler?
    }
}
