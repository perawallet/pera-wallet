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
//  PinLimitViewController.swift

import UIKit

final class PinLimitViewController: BaseViewController {
    weak var delegate: PinLimitViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private var pinLimitStore = PinLimitStore()
    private var timer: PollingOperation?
    private var remainingTime = 0

    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var pinLimitView = PinLimitView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePinLimitCounter()
        startCountingForPinLimit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startCounterWhenBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopCounterInBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func prepareLayout() {
        addPinLimitView()
    }
}

extension PinLimitViewController {
    private func addPinLimitView() {
        pinLimitView.customize(PinLimitViewTheme())

        view.addSubview(pinLimitView)
        pinLimitView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        pinLimitView.startObserving(event: .resetAllData) {
            [weak self] in
            guard let self = self else { return }
            self.presentLogoutAlert()
        }
    }
}

extension PinLimitViewController {
    @objc
    private func startCounterWhenBecomeActive() {
        remainingTime = pinLimitStore.remainingTime
        startCountingForPinLimit()
    }
    
    @objc
    private func stopCounterInBackground() {
        stopCountingForPinLimit()
    }
}

extension PinLimitViewController {
    private func calculateAndSetRemainingTime() {        
        pinLimitView.bindData(PinLimitViewModel(remainingTime))
        remainingTime -= 1
        
        if remainingTime <= 0 {
            self.pinLimitStore.setRemainingTime(0)
            self.closeScreen(by: .dismiss, animated: false)
        }
    }
    
    private func initializePinLimitCounter() {
        remainingTime = pinLimitStore.remainingTime
        pinLimitView.bindData(PinLimitViewModel(remainingTime))
    }
    
    private func startCountingForPinLimit() {
        timer = PollingOperation(interval: 1.0) { [weak self] in
            DispatchQueue.main.async {
                self?.calculateAndSetRemainingTime()
            }
        }
        
        timer?.start()
    }
    
    private func stopCountingForPinLimit() {
        pinLimitStore.setRemainingTime(remainingTime)
        timer?.invalidate()
    }
}

extension PinLimitViewController {
    private func presentLogoutAlert() {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-settings-logout".uiImage,
            title: "settings-logout-title".localized,
            description: .plain("settings-logout-detail".localized),
            primaryActionButtonTitle: "node-settings-action-delete-title".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.pinLimitViewControllerDidResetAllData(self)
            }
        )

        bottomModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator),
            by: .presentWithoutNavigationController
        )
    }
}

protocol PinLimitViewControllerDelegate: AnyObject {
    func pinLimitViewControllerDidResetAllData(_ pinLimitViewController: PinLimitViewController)
}
