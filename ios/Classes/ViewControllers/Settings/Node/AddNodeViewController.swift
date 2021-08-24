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
//  AddNodeViewController.swift

import UIKit
import SnapKit
import SVProgressHUD

protocol AddNodeViewControllerDelegate: AnyObject {
    func addNodeViewController(_ controller: AddNodeViewController, didChangeNodeFor action: AddNodeViewController.ActionType)
}

class AddNodeViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var addNodeView = AddNodeView()
    
    weak var delegate: AddNodeViewControllerDelegate?
    
    private var contentViewBottomConstraint: Constraint?
    
    private var keyboard = Keyboard()
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillHide:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        switch mode {
        case .new:
            title = "add-node-title".localized
            return
        case let .edit(node):
            title = "edit-node-title".localized
            
            addNodeView.nameInputView.inputTextField.text = node.name
            addNodeView.addressInputView.inputTextField.text = node.address
            addNodeView.tokenInputView.value = node.token ?? ""
        }
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        switch mode {
        case .new:
            return
        case let .edit(node):
            let barButtonItem = ALGBarButtonItem(kind: .close) {
                let alertController = UIAlertController(title: "node-settings-warning-title".localized,
                                                        message: "node-settings-warning-message".localized,
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(
                    title: "node-settings-action-delete-title".localized,
                    style: .destructive) { _ in
                        if node.isActive {
                            self.session?.setDefaultNodeActive(true)
                        }
                        self.delegate?.addNodeViewController(self, didChangeNodeFor: .delete)
                        node.remove(entity: Node.entityName)
                        self.popScreen()
                        return
                }
                alertController.addAction(deleteAction)
                
                self.present(alertController, animated: true)
            }
            
            rightBarButtonItems = [barButtonItem]
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        scrollView.touchDetectingDelegate = self
        addNodeView.testButton.addTarget(self, action: #selector(tap(test:)), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(addNodeView)
        
        addNodeView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
    
    // MARK: Keyboard
    
    @objc
    private func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? view.safeAreaBottom
        
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        if addNodeView.tokenInputView.frame.maxY > UIScreen.main.bounds.height - kbHeight - 76.0 {
            scrollView.contentInset.bottom = kbHeight
        } else {
            contentViewBottomConstraint?.update(inset: kbHeight)
        }
        
        contentViewBottomConstraint?.update(inset: kbHeight)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc
    private func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        scrollView.contentInset.bottom = 0.0
        
        contentViewBottomConstraint?.update(inset: view.safeAreaBottom)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc
    private func tap(test button: MainButton) {
        view.endEditing(true)
        
        guard let name = addNodeView.nameInputView.inputTextField.text, !name.isEmpty,
            let address = addNodeView.addressInputView.inputTextField.text, !address.isEmpty,
            let token = addNodeView.tokenInputView.inputTextView.text, !token.isEmpty else {
                displaySimpleAlertWith(title: "title-error".localized,
                                       message: "node-settings-text-validation-empty-error".localized)
                return
        }
        
        let testDraft = NodeTestDraft(address: address, token: token)
        
        let predicate = NSPredicate(format: "address = %@", address)
        
        switch self.mode {
        case .new:
            if Node.hasResult(entity: Node.entityName, with: predicate) {
                displaySimpleAlertWith(title: "title-error".localized, message: "node-settings-has-same-result".localized)
                return
            }
        default:
            break
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.checkNodeHealth(with: testDraft) { isValidated in
            SVProgressHUD.dismiss()
            
            if isValidated {
                switch self.mode {
                case .new:
                    self.createNode(with: [Node.DBKeys.name.rawValue: name,
                                           Node.DBKeys.address.rawValue: address,
                                           Node.DBKeys.token.rawValue: token,
                                           Node.DBKeys.isActive.rawValue: false,
                                           Node.DBKeys.creationDate.rawValue: Date()])
                case let .edit(node):
                    self.edit(node, with: [Node.DBKeys.name.rawValue: name,
                                           Node.DBKeys.address.rawValue: address,
                                           Node.DBKeys.token.rawValue: token])
                }
            } else {
                self.displayAlert(message: "node-settings-text-validation-health-error".localized,
                                  mode: .testFail)
            }
        }
    }
    
    private func createNode(with values: [String: Any]) {
        Node.create(
            entity: Node.entityName,
            with: values
        ) { response in
            switch response {
            case .error:
                self.displayAlert(message: "node-settings-database-error-description".localized, mode: .dbFail)
            case let .result(object):
                guard object is Node else {
                    self.displayAlert(message: "node-settings-database-error-description".localized, mode: .dbFail)
                    return
                }
                self.delegate?.addNodeViewController(self, didChangeNodeFor: .create)
                self.displayAlert(message: nil, mode: .success)
            case let .results(objects):
                guard objects.first is Node else {
                    self.displayAlert(message: "node-settings-database-error-description".localized, mode: .dbFail)
                    return
                }
                self.displayAlert(message: nil, mode: .success)
            }
        }
    }
    
    private func edit(_ node: Node, with values: [String: Any]) {
        node.update(entity: Node.entityName, with: values) { result in
            switch result {
            case let .result(object):
                guard object is Node else {
                    self.displayAlert(message: "node-settings-database-error-description".localized, mode: .dbFail)
                    return
                }
                
                self.delegate?.addNodeViewController(self, didChangeNodeFor: .update)
                self.displayAlert(message: nil, mode: .success)
            case .error:
                self.displayAlert(message: "node-settings-database-error-description".localized, mode: .dbFail)
            default:
                break
            }
        }
    }
    
    private func displayAlert(message: String?, mode: AlertMode) {
        let alertTitle: String
        let image: UIImage?
        
        switch mode {
        case .dbFail:
            alertTitle = "node-settings-db-error-title".localized
            image = img("icon-black-server")
        case .testFail:
            alertTitle = "node-settings-test-error-title".localized
            image = img("icon-black-server")
        case .success:
            alertTitle = "node-settings-test-success-title".localized
            image = img("icon-green-server")
        }
        
        let configurator = BottomInformationBundle(
            title: alertTitle,
            image: image,
            explanation: message ?? "",
            actionTitle: "title-close".localized,
            actionImage: img("bg-main-button")) {
                if mode == .success {
                    self.popScreen()
                }
        }
        
        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            )
        )
    }
}

// MARK: Mode

extension AddNodeViewController {
    enum Mode {
        case new
        case edit(node: Node)
    }
    
    enum AlertMode {
        case dbFail
        case testFail
        case success
    }
    
    enum ActionType {
        case create
        case update
        case delete
    }
}

// MARK: TouchDetectingScrollViewDelegate

extension AddNodeViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if addNodeView.testButton.frame.contains(point) ||
            addNodeView.addressInputView.frame.contains(point) ||
            addNodeView.nameInputView.frame.contains(point) ||
            addNodeView.tokenInputView.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}
