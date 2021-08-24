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
//   WCContainedTransactionWarningView.swift

import UIKit

class WCContainedTransactionWarningView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var warningView = WCTransactionWarningView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func prepareLayout() {
        setupWarningViewLayout()
    }
}

extension WCContainedTransactionWarningView {
    private func setupWarningViewLayout() {
        addSubview(warningView)

        warningView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension WCContainedTransactionWarningView {
    func bind(_ viewModel: WCTransactionWarningViewModel) {
        warningView.bind(viewModel)
    }
}

extension WCContainedTransactionWarningView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
    }
}
