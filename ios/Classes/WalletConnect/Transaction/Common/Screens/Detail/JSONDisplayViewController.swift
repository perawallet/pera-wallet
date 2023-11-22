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
//   JSONDisplayViewController.swift

import UIKit

final class JSONDisplayViewController: BaseScrollViewController {
    private let layout = Layout<LayoutConstants>()

    private lazy var separatorView = LineSeparatorView()

    private lazy var jsonDisplayView = JSONDisplayView()

    private let jsonData: Data
    private let screenTitle: String
    private let copyToClipboardController: CopyToClipboardController

    private lazy var viewModel = JSONDisplayViewModel(json: jsonData)

    init(
        jsonData: Data,
        title: String,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.jsonData = jsonData
        self.screenTitle = title
        self.copyToClipboardController = copyToClipboardController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addCopyBarButtonItem()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = Colors.Defaults.background.uiColor
        title = screenTitle
    }

    override func prepareLayout() {
        super.prepareLayout()

        setupseparatorViewLayout()
        setupJSONDisplayViewLayout()
    }

    override func bindData() {
        jsonDisplayView.bind(viewModel)
    }
}

extension JSONDisplayViewController {
    private func addCopyBarButtonItem() {
        let copyBarButtonItem = ALGBarButtonItem(kind: .copy) { [unowned self] in
            self.copyJSON()
        }

        rightBarButtonItems = [copyBarButtonItem]
    }

    private func copyJSON() {
        let jsonText = viewModel.jsonText
        if let jsonText {
            copyToClipboardController.copyText(jsonText)
        }
    }
}

extension JSONDisplayViewController {
    private func setupseparatorViewLayout() {
        view.addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }

    private func setupJSONDisplayViewLayout() {
        contentView.addSubview(jsonDisplayView)
        jsonDisplayView.pinToSuperview()
    }
}

extension JSONDisplayViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
    }
}
