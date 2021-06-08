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
//   LedgerAccountVerificationView.swift

import UIKit

class LedgerAccountVerificationView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var headerView = LedgerAccountVerificationHeaderView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 12.0
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        return stackView
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.primary
    }

    override func prepareLayout() {
        setupHeaderViewLayout()
        setupStackViewLayout()
    }
}

extension LedgerAccountVerificationView {
    private func setupHeaderViewLayout() {
        addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }

    private func setupStackViewLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(layout.current.stackTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.stackHorizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension LedgerAccountVerificationView {
    func addArrangedSubview(_ statusView: LedgerAccountVerificationStatusView) {
        stackView.addArrangedSubview(statusView)
    }

    var isStackViewEmpty: Bool {
        return stackView.arrangedSubviews.isEmpty
    }
    
    var statusViews: [UIView] {
        return stackView.arrangedSubviews
    }

    func startConnectionAnimation() {
        headerView.startConnectionAnimation()
    }

    func stopConnectionAnimation() {
        headerView.stopConnectionAnimation()
    }
}

extension LedgerAccountVerificationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackHorizontalInset: CGFloat = 20.0
        let stackTopInset: CGFloat = 48.0
        let bottomInset: CGFloat = 16.0
    }
}
