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
//  RekeyInstructionsViewController.swift

import UIKit

final class RekeyInstructionsViewController: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?
    
    private lazy var rekeyInstructionsView = RekeyInstructionsView()
    
    private let viewModel: RekeyToAnyAccountInstructionsViewModel
    
    init(
        viewModel: RekeyToAnyAccountInstructionsViewModel,
        configuration: ViewControllerConfiguration
    ) {
        self.viewModel = viewModel
        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        rekeyInstructionsView.delegate = self
    }

    override func setListeners() {
        super.setListeners()
        rekeyInstructionsView.setListeners()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
        scrollView.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
        contentView.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        rekeyInstructionsView.customize(RekeyInstructionsViewTheme())
        contentView.addSubview(rekeyInstructionsView)
        rekeyInstructionsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        super.bindData()
        rekeyInstructionsView.bindData(viewModel)
    }
}

extension RekeyInstructionsViewController: RekeyInstructionsViewDelegate {
    func rekeyInstructionsViewDidStartRekeying(_ rekeyInstructionsView: RekeyInstructionsView) {
        self.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            self.eventHandler?(.performRekey)
        }
    }
}

extension RekeyInstructionsViewController {
    enum Event {
        case performRekey
    }
}
