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
//  IntroductionViewController.swift

import UIKit

class IntroductionViewController: BaseViewController {
    
    private lazy var introductionView = IntroductionView()
    
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        switch accountSetupFlow {
        case .addNewAccount:
            leftBarButtonItems = [closeBarButtonItem]
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        introductionView.animateImages()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        
        switch accountSetupFlow {
        case .addNewAccount:
            introductionView.setTitle("introduction-title-add-text".localized)
        case .initializeAccount:
            introductionView.setTitle("introduction-title-text".localized)
        case .none:
            break
        }
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationEnterForeground),
            name: .ApplicationWillEnterForeground,
            object: nil
        )
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupIntroducitionViewLayout()
    }
    
    override func linkInteractors() {
        introductionView.delegate = self
    }
}

extension IntroductionViewController {
    private func setupIntroducitionViewLayout() {
        view.addSubview(introductionView)
        
        introductionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension IntroductionViewController {
    @objc
    private func didApplicationEnterForeground() {
        introductionView.animateImages()
    }
}

extension IntroductionViewController: IntroductionViewDelegate {
    func introductionViewDidAddAccount(_ introductionView: IntroductionView) {
        open(.welcome(flow: accountSetupFlow), by: .push)
    }
    
    func introductionView(_ introductionView: IntroductionView, didOpen url: URL) {
        open(url)
    }
}

enum AccountSetupFlow {
    case initializeAccount(mode: AccountSetupMode)
    case addNewAccount(mode: AccountSetupMode)
    case none
}

enum AccountSetupMode {
    case add(type: AccountAdditionType)
    case recover
    case rekey(account: Account)
    case none
}

enum AccountAdditionType {
    case create
    case watch
    case pair
    case none
}
