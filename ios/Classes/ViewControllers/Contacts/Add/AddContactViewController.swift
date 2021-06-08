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
//  AddContactViewController.swift

import UIKit

class AddContactViewController: BaseScrollViewController {
    
    private lazy var removeContactModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 382.0))
    )
    
    private(set) lazy var addContactView = AddContactView()
    
    private var isUserEdited = false
    
    private var imagePicker: ImagePicker
    
    private var keyboardController = KeyboardController()
    
    weak var delegate: AddContactViewControllerDelegate?
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        imagePicker = ImagePicker()
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        switch mode {
        case .new:
            super.configureNavigationBarAppearance()
        case let .edit(contact):
            self.setupEditModeBarButtons(for: contact)
        }
    }
    
    private func setupEditModeBarButtons(for contact: Contact) {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            self.checkFieldsHaveChanges()
            
            if self.isUserEdited {
                self.presentCloseWithoutSavingAlert()
            } else {
                self.closeScreen(by: .dismiss, animated: true)
            }
        }
        
        let saveBarButtonItem = ALGBarButtonItem(kind: .done) {
            if let keyedValues = self.parseFieldsForContact() {
                self.edit(contact, with: keyedValues)
            }
        }
        
        leftBarButtonItems = [closeBarButtonItem]
        rightBarButtonItems = [saveBarButtonItem]
    }
    
    private func checkFieldsHaveChanges() {
        switch mode {
        case let .edit(contact):
            guard let name = addContactView.userInformationView.contactNameInputView.inputTextField.text,
                let address = addContactView.userInformationView.algorandAddressInputView.inputTextView.text else {
                    return
            }
            
            if contact.name != name || contact.address != address {
                isUserEdited = true
            }
        default:
            break
        }
    }
    
    private func presentCloseWithoutSavingAlert() {
        let alertController = UIAlertController(
            title: "contacts-close-warning-subtitle".localized,
            message: "contacts-close-warning-subtitle".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: "title-done".localized, style: .default) { _ in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        switch mode {
        case let .new(address, name):
            title = "contacts-add".localized
            
            if let address = address {                
                addContactView.userInformationView.algorandAddressInputView.value = address
            }
            addContactView.userInformationView.contactNameInputView.inputTextField.text = name
            
            addContactView.deleteContactButton.isHidden = true
        case let .edit(contact):
            title = "contacts-info-edit".localized
            
            addContactView.addContactButton.isHidden = true
            addContactView.setUserActionButtonIcon(img("icon-edit"))
            addContactView.userInformationView.contactNameInputView.inputTextField.text = contact.name
            
            if let address = contact.address {
                addContactView.userInformationView.algorandAddressInputView.value = address
            }
            
            if let imageData = contact.image,
                let image = UIImage(data: imageData) {
                let resizedImage = image.convert(to: CGSize(width: 88.0, height: 88.0))
                
                addContactView.userInformationView.userImageView.image = resizedImage
            }
        }
    }
    
    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        addContactView.delegate = self
        scrollView.touchDetectingDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(addContactView)
        
        addContactView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AddContactViewController: AddContactViewDelegate {
    func addContactViewDidTapActionButton(_ addContactView: AddContactView) {
        switch mode {
        case .new:
            guard let keyedValues = parseFieldsForContact() else {
                return
            }
            
            addContact(with: keyedValues)
        case let .edit(contact):
            displayDeleteAlert(for: contact)
        }
    }
    
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView) {
        imagePicker.delegate = self
        imagePicker.present(from: self)
    }
    
    private func parseFieldsForContact() -> [String: Any]? {
        guard let name = addContactView.userInformationView.contactNameInputView.inputTextField.text,
            !name.isEmpty else {
                displaySimpleAlertWith(title: "title-error".localized, message: "contacts-name-validation-error".localized)
                return nil
        }
        
        guard let address = addContactView.userInformationView.algorandAddressInputView.inputTextView.text,
            !address.isEmpty,
            address.isValidatedAddress() else {
                displaySimpleAlertWith(title: "title-error".localized, message: "contacts-address-validation-error".localized)
                return nil
        }
        
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var keyedValues: [String: Any] = [
            Contact.CodingKeys.name.rawValue: name,
            Contact.CodingKeys.address.rawValue: trimmedAddress
        ]
        
        if let placeholderImage = img("icon-user-placeholder-big"),
            let image = addContactView.userInformationView.userImageView.image,
            let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
            image != placeholderImage {
            
            keyedValues[Contact.CodingKeys.image.rawValue] = imageData
        }
        
        return keyedValues
    }
    
    private func addContact(with values: [String: Any]) {
        Contact.create(entity: Contact.entityName, with: values) { result in
            switch result {
            case let .result(object: object):
                guard let contact = object as? Contact else {
                    return
                }
                
                NotificationCenter.default.post(name: .ContactAddition, object: self, userInfo: ["contact": contact])
                self.closeScreen(by: .pop)
            default:
                break
            }
        }
    }
    
    private func edit(_ contact: Contact, with values: [String: Any]) {
        contact.update(entity: Contact.entityName, with: values) { result in
            switch result {
            case let .result(object: object):
                guard let contact = object as? Contact else {
                    return
                }
                
                NotificationCenter.default.post(name: .ContactEdit, object: self, userInfo: ["contact": contact])
                self.delegate?.addContactViewController(self, didSave: contact)
                self.closeScreen(by: .dismiss)
            default:
                break
            }
        }
    }
    
    func addContactViewDidTapQRCodeButton(_ addContactView: AddContactView) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }
        
        guard let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController else {
            return
        }
        
        qrScannerViewController.delegate = self
    }
    
    private func displayDeleteAlert(for contact: Contact) {
        let configurator = BottomInformationBundle(
            title: "contacts-delete-contact".localized,
            image: img("img-remove-account"),
            explanation: "contacts-delete-contact-alert-explanation".localized,
            actionTitle: "contacts-delete-contact".localized,
            actionImage: img("bg-button-red"),
            closeTitle: "title-keep".localized) {
                contact.remove(entity: Contact.entityName)
                NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: ["contact": contact])
                self.dismissScreen()
                return
        }
        
        open(
            .bottomInformation(mode: .action, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: removeContactModalPresenter
            )
        )
    }
}

extension AddContactViewController: ImagePickerDelegate {
    func imagePicker(didPick image: UIImage, withInfo info: [String: Any]) {
        isUserEdited = true
        addContactView.setUserActionButtonIcon(img("icon-edit"))
        let resizedImage = image.convert(to: CGSize(width: 88.0, height: 88.0))
        addContactView.userInformationView.userImageView.image = resizedImage
    }
}

extension AddContactViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return addContactView.userInformationView.algorandAddressInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}

extension AddContactViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard qrText.mode == .address,
            let qrAddress = qrText.address else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-address-message".localized) { _ in
                if let handler = completionHandler {
                    handler()
                }
            }
            return
        }
        
        addContactView.userInformationView.algorandAddressInputView.value = qrAddress
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension AddContactViewController {
    enum Mode {
        case new(address: String? = nil, name: String? = nil)
        case edit(contact: Contact)
    }
}

extension AddContactViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if addContactView.addContactButton.frame.contains(point) ||
            addContactView.userInformationView.algorandAddressInputView.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}

protocol AddContactViewControllerDelegate: class {
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact)
}
