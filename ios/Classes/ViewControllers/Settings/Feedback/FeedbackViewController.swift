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
//  FeedbackViewController.swift

import UIKit
import SVProgressHUD
import Magpie

class FeedbackViewController: BaseScrollViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 318.0))
    )
    
    private(set) lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private var categories = [FeedbackCategory]()
    private var selectedCategory: FeedbackCategory? {
        didSet {
            if let selectedCategory = selectedCategory {
                self.feedbackView.categorySelectionView.detailLabel.text = selectedCategory.name
                self.feedbackView.categorySelectionView.detailLabel.textColor = Colors.Text.primary
            }
        }
    }
    
    private var selectedAccount: Account? {
        didSet {
            if let account = selectedAccount {
                self.feedbackView.accountSelectionView.detailLabel.text = account.name
                self.feedbackView.accountSelectionView.detailLabel.textColor = Colors.Text.primary
            }
        }
    }
    
    private var keyboardController = KeyboardController()
    
    private lazy var feedbackView = FeedbackView()
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "feedback-title".localized
        fetchFeedbackCategories()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        feedbackView.delegate = self
        feedbackView.categoryPickerView.delegate = self
        feedbackView.categoryPickerView.dataSource = self
        keyboardController.dataSource = self
    }
    
    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupFeedbackViewLayout()
    }
}

extension FeedbackViewController {
    private func fetchFeedbackCategories() {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        api?.getFeedbackCategories { response in
            switch response {
            case let .success(result):
                SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                SVProgressHUD.dismiss()
                
                self.categories = result
                self.feedbackView.categoryPickerView.reloadAllComponents()
            case .failure:
                SVProgressHUD.dismiss()
            }
        }
    }
}

extension FeedbackViewController {
    private func setupFeedbackViewLayout() {
        contentView.addSubview(feedbackView)
        
        feedbackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension FeedbackViewController: FeedbackViewDelegate {
    func feedbackViewDidSelectCategory(_ feedbackView: FeedbackView) {
        if feedbackView.categoryPickerView.isHidden {
            feedbackView.categoryPickerView.isHidden = false
            feedbackView.categoryPickerView.snp.updateConstraints { make in
                make.height.equalTo(layout.current.pickerOpenedHeight)
            }
        } else {
            feedbackView.categoryPickerView.isHidden = true
            feedbackView.categoryPickerView.snp.updateConstraints { make in
                make.height.equalTo(0.0)
            }
            
            let currentRow = feedbackView.categoryPickerView.selectedRow(inComponent: 0)
            
            if currentRow >= categories.count {
                return
            }
            
            selectedCategory = categories[currentRow]
        }
    }
    
    func feedbackViewDidSelectAccount(_ feedbackView: FeedbackView) {
        let accountListViewController = open(
            .accountList(mode: .empty),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
    }
    
    func feedbackViewDidTapSendButton(_ feedbackView: FeedbackView) {
        sendFeedback()
    }
    
    func feedbackView(_ feedbackView: FeedbackView, inputDidReturn inputView: BaseInputView) {
        if inputView == feedbackView.noteInputView {
            sendFeedback()
        }
    }
}

extension FeedbackViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        
        selectedAccount = account
    }
}

extension FeedbackViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return layout.current.pickerRowHeight
    }
}

extension FeedbackViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row >= categories.count {
            return
        }
        
        selectedCategory = categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row >= categories.count {
            return nil
        }
        return categories[row].name
    }
}

extension FeedbackViewController {
    private func sendFeedback() {
        guard let selectedCategory = selectedCategory else {
            displaySimpleAlertWith(title: "feedback-empty-title".localized, message: "feedback-empty-category-message".localized)
            return
        }
        
        guard let feedbackNote = feedbackView.noteInputView.inputTextView.text,
            !feedbackNote.isEmpty else {
            displaySimpleAlertWith(title: "feedback-empty-title".localized, message: "feedback-empty-note-message".localized)
            return
        }
        
        guard let email = feedbackView.emailInputView.inputTextField.text,
            !email.isEmpty else {
            displaySimpleAlertWith(title: "feedback-empty-title".localized, message: "feedback-empty-note-message".localized)
            return
        }
        
        let feedbackDraft = FeedbackDraft(
            note: feedbackNote,
            category: selectedCategory.slug,
            email: email,
            address: selectedAccount?.address
        )
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        api?.sendFeedback(with: feedbackDraft) { response in
            switch response {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                SVProgressHUD.dismiss()
                
                self.displaySuccessAlert()
            case .failure:
                SVProgressHUD.dismiss()
                self.displaySimpleAlertWith(title: "feedback-error-title".localized, message: "feedback-error-message".localized)

            }
        }
    }
    
    private func displaySuccessAlert() {
        let configurator = BottomInformationBundle(
            title: "feedback-success-title".localized,
            image: img("img-green-checkmark"),
            explanation: "feedback-success-detail".localized,
            actionTitle: "title-close".localized,
            actionImage: img("bg-main-button")
        ) {
            self.popScreen()
        }
        
        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
}

extension FeedbackViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return feedbackView.noteInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}

extension FeedbackViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let pickerRowHeight: CGFloat = 50.0
        let pickerOpenedHeight: CGFloat = 130.0
    }
}
