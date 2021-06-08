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
//   TransactionTutorialViewController.swift

import UIKit

class TransactionTutorialViewController: BaseScrollViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    weak var delegate: TransactionTutorialViewControllerDelegate?

    private lazy var transactionTutorialView = TransactionTutorialView()

    private let isInitialDisplay: Bool

    init(isInitialDisplay: Bool, configuration: ViewControllerConfiguration) {
        self.isInitialDisplay = isInitialDisplay
        super.init(configuration: configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transactionTutorialView.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionTutorialView.stopAnimating()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.Background.secondary
        transactionTutorialView.bind(TransactionTutorialViewModel(isInitialDisplay: isInitialDisplay))
    }

    override func linkInteractors() {
        super.linkInteractors()
        transactionTutorialView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionTutorialViewLayout()
    }
}

extension TransactionTutorialViewController {
    private func setupTransactionTutorialViewLayout() {
        contentView.addSubview(transactionTutorialView)

        transactionTutorialView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionTutorialViewController: TransactionTutorialViewDelegate {
    func transactionTutorialViewDidConfirmTutorial(_ transactionTutorialView: TransactionTutorialView) {
        delegate?.transactionTutorialViewControllerDidConfirmTutorial(self)
    }

    func transactionTutorialViewDidOpenMoreInfo(_ transactionTutorialView: TransactionTutorialView) {
        if let url = AlgorandWeb.transactionSupport.link {
            open(url)
        }
    }
}

protocol TransactionTutorialViewControllerDelegate: class {
    func transactionTutorialViewControllerDidConfirmTutorial(_ transactionTutorialViewController: TransactionTutorialViewController)
}
