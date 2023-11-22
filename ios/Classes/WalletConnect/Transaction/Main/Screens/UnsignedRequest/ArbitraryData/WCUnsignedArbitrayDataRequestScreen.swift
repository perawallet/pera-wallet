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

//   WCUnsignedArbitrayDataRequestScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCUnsignedArbitrayDataRequestScreen: BaseViewController {
    weak var delegate: WCUnsignedArbitraryDataRequestScreenDelegate?

    private lazy var theme = Theme()

    private lazy var scrollView = UIScrollView()
    private lazy var unsignedRequestView = WCUnsignedRequestView()

    private lazy var layoutBuilder = WCMainArbitraryDataLayout(
        dataSource: dataSource,
        sharedDataController: sharedDataController,
        currencyFormatter: .init()
    )
    private let dataSource: WCMainArbitraryDataDataSource

    init(
        dataSource: WCMainArbitraryDataDataSource,
        configuration: ViewControllerConfiguration
    ) {
        self.dataSource = dataSource

        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor.uiColor
        scrollView.backgroundColor = theme.backgroundColor.uiColor
        unsignedRequestView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = "wallet-connect-title-unsigned-requests".localized

        hidesCloseBarButtonItem = true
    }

    override func prepareLayout() {
        super.prepareLayout()

        addScrollView()
        addContentView()
    }

    override func linkInteractors() {
        super.linkInteractors()

        unsignedRequestView.setDataSource(dataSource)
        unsignedRequestView.setDelegate(layoutBuilder)
        unsignedRequestView.delegate = self
        layoutBuilder.delegate = self
    }
}

extension WCUnsignedArbitrayDataRequestScreen {
    private func addScrollView() {
        scrollView.isScrollEnabled = false

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addContentView() {
        let contentView = UIView()
        contentView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalToSuperview().priority(.low)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(unsignedRequestView)
        unsignedRequestView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension WCUnsignedArbitrayDataRequestScreen: WCUnsignedRequestViewDelegate {
    func wcUnsignedRequestViewDidTapCancel(_ requestView: WCUnsignedRequestView) {
        delegate?.wcUnsignedArbitraryDataRequestScreenDidReject(self)
    }

    func wcUnsignedRequestViewDidTapConfirm(_ requestView: WCUnsignedRequestView) {
        delegate?.wcUnsignedArbitraryDataRequestScreenDidConfirm(self)
    }
}

extension WCUnsignedArbitrayDataRequestScreen: WCMainArbitraryDataLayoutDelegate {
    func wcMainArbitraryDataLayout(
        _ wcMainArbitraryDataLayout: WCMainArbitraryDataLayout,
        didSelect data: WCArbitraryData
    ) {
        open(
            .wcArbitraryDataScreen(
                data: data,
                wcSession: dataSource.wcSession
            ),
            by: .push
        )
    }
}

protocol WCUnsignedArbitraryDataRequestScreenDelegate: AnyObject {
    func wcUnsignedArbitraryDataRequestScreenDidConfirm(
        _ wcUnsignedArbitraryDataRequestScreen: WCUnsignedArbitrayDataRequestScreen
    )
    func wcUnsignedArbitraryDataRequestScreenDidReject(
        _ wcUnsignedArbitraryDataRequestScreen: WCUnsignedArbitrayDataRequestScreen
    )
}
