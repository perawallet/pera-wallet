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
//  AddContactViewController.swift

import UIKit

final class AddContactViewController: BaseScrollViewController {
    weak var delegate: AddContactViewControllerDelegate?

    private lazy var theme = Theme()
    private lazy var addContactView = AddContactView()
    private lazy var imagePicker = ImagePicker()
    private lazy var keyboardController = KeyboardController()

    private var address: String?
    private var contactName: String?

    init(address: String?, name: String?, configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        self.address = address
        self.contactName = name
    }
    
    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        addContactView.delegate = self
        (scrollView as? TouchDetectingScrollView)?.touchDetectingDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addContactView.customize(theme.addContactViewTheme)
        contentView.addSubview(addContactView)
        addContactView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        super.bindData()
        addContactView.badgedImageView.bindData(image: nil, badgeImage: "icon-circle-add".uiImage)
        addContactView.nameInputView.text = contactName
        addContactView.addressInputView.text = address
    }
}

extension AddContactViewController: AddContactViewDelegate {
    func addContactViewInputFieldViewShouldReturn(
        _ addContactView: AddContactView,
        inputFieldView: FloatingTextInputFieldView
    ) -> Bool {
        if inputFieldView == addContactView.nameInputView {
            addContactView.addressInputView.beginEditing()
        } else {
            inputFieldView.endEditing()
        }
        return true
    }

    func addContactViewDidTapAddContactButton(_ addContactView: AddContactView) {
        guard let keyedValues = parseFieldsForContact() else {
            return
        }
        addContact(with: keyedValues)
    }
    
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView) {
        imagePicker.delegate = self
        imagePicker.present(from: self)
    }
    
    private func parseFieldsForContact() -> [String: Any]? {
        guard let name = addContactView.nameInputView.text,
              !name.isEmptyOrBlank else {
                  displaySimpleAlertWith(title: "title-error".localized, message: "contacts-name-validation-error".localized)
                  return nil
              }
        
        guard let address = addContactView.addressInputView.text,
              !address.isEmpty,
              address.isValidatedAddress else {
                  displaySimpleAlertWith(title: "title-error".localized, message: "contacts-address-validation-error".localized)
                  return nil
              }
        
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var keyedValues: [String: Any] = [
            Contact.CodingKeys.name.rawValue: name,
            Contact.CodingKeys.address.rawValue: trimmedAddress
        ]
        
        if let placeholderImage = img("icon-user-placeholder"),
           let image = addContactView.badgedImageView.imageView.image,
           let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
           image != placeholderImage {
            
            keyedValues[Contact.CodingKeys.image.rawValue] = imageData
        }
        
        return keyedValues
    }
    
    private func addContact(with values: [String: Any]) {
        Contact.create(entity: Contact.entityName, with: values) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .result(object: object):
                guard let contact = object as? Contact else {
                    return
                }
                
                NotificationCenter.default.post(name: .ContactAddition, object: self, userInfo: ["contact": contact])

                if self.presentingViewController == nil {
                    self.popScreen()
                } else {
                    self.dismissScreen()
                }

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
        
        guard let qrScannerViewController = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController else {
            return
        }
        
        qrScannerViewController.delegate = self
    }
}

extension AddContactViewController: ImagePickerDelegate {
    func imagePicker(didPick image: UIImage, withInfo info: [String: Any]) {
        let resizedImage = image.convert(to: CGSize(width: 80, height: 80))
        addContactView.badgedImageView.bindData(image: resizedImage, badgeImage: "icon-circle-edit".uiImage)
    }
}

extension AddContactViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return addContactView.addressInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 0
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
        
        addContactView.addressInputView.text = qrAddress
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension AddContactViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if addContactView.addContactButton.frame.contains(point) ||
            addContactView.addressInputView.frame.contains(point) ||
            addContactView.nameInputView.frame.contains(point) {
            return
        }
        contentView.endEditing(true)
    }
}

protocol AddContactViewControllerDelegate: AnyObject {
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact)
}
