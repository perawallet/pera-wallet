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
//   EditContactViewController.swift

import UIKit

final class EditContactViewController: BaseScrollViewController {
    weak var delegate: EditContactViewControllerDelegate?

    private lazy var removeContactModalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var theme = Theme()
    private lazy var editContactView = EditContactView()
    private lazy var imagePicker = ImagePicker()
    private lazy var keyboardController = KeyboardController()

    private var isUserEdited = false
    private var contact: Contact

    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        super.init(configuration: configuration)
    }

    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
    }

    override func linkInteractors() {
        keyboardController.dataSource = self
        editContactView.delegate = self
        (scrollView as? TouchDetectingScrollView)?.touchDetectingDelegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        editContactView.customize(theme.editContactViewTheme)
        contentView.addSubview(editContactView)
        editContactView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "contacts-info-edit".localized
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        super.bindData()
        editContactView.bindData(EditContactViewModel(contact))
    }
}

extension EditContactViewController {
    private func addBarButtons() {
        let saveBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Text.main.uiColor)) {
            if let keyedValues = self.parseFieldsForContact() {
                self.edit(self.contact, with: keyedValues)
            }
        }

        rightBarButtonItems = [saveBarButtonItem]
     }
}

extension EditContactViewController: EditContactViewDelegate {
    func editContactViewInputFieldViewShouldReturn(
        _ editContactView: EditContactView,
        inputFieldView: FloatingTextInputFieldView
    ) -> Bool {
        if inputFieldView == editContactView.nameInputView {
            editContactView.addressInputView.beginEditing()
        } else {
            inputFieldView.endEditing()
        }
        return true
    }

    func editContactViewDidTapDeleteButton(_ editContactView: EditContactView) {
        displayDeleteAlert(for: contact)
    }

    func editContactViewDidTapAddImageButton(_ editContactView: EditContactView) {
        imagePicker.delegate = self
        imagePicker.present(from: self)
    }

    private func parseFieldsForContact() -> [String: Any]? {
        guard let name = editContactView.nameInputView.text,
              !name.isEmptyOrBlank else {
                  displaySimpleAlertWith(title: "title-error".localized, message: "contacts-name-validation-error".localized)
                  return nil
              }

        guard let address = editContactView.addressInputView.text,
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
           let image = editContactView.badgedImageView.imageView.image,
           let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
           image != placeholderImage {

            keyedValues[Contact.CodingKeys.image.rawValue] = imageData
        }

        return keyedValues
    }

    private func edit(_ contact: Contact, with values: [String: Any]) {
        contact.update(entity: Contact.entityName, with: values) { result in
            switch result {
            case let .result(object: object):
                guard let contact = object as? Contact else {
                    return
                }

                NotificationCenter.default.post(name: .ContactEdit, object: self, userInfo: ["contact": contact])
                self.delegate?.editContactViewController(self, didSave: contact)
                self.popScreen()
            default:
                break
            }
        }
    }

    private func displayDeleteAlert(for contact: Contact) {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-trash-red".uiImage,
            title: "contacts-delete-contact".localized,
            description: .plain("contacts-delete-contact-alert-explanation".localized),
            primaryActionButtonTitle: "contacts-approve-delete-contact".localized,
            secondaryActionButtonTitle: "title-keep".localized,
            primaryAction: {
                [weak self] in
                guard let self = self else {
                    return
                }

                contact.remove(entity: Contact.entityName)

                self.popScreenToContactsScreen()

                NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: ["contact": contact])
            }
        )

        removeContactModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator),
            by: .presentWithoutNavigationController
        )
    }

    private func popScreenToContactsScreen() {
        guard let navigationController = navigationController else {
            return
        }

        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast(2)
        navigationController.setViewControllers(viewControllers, animated: true)
    }

    func editContactViewDidTapQRCodeButton(_ editContactView: EditContactView) {
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

extension EditContactViewController: ImagePickerDelegate {
    func imagePicker(didPick image: UIImage, withInfo info: [String: Any]) {
        isUserEdited = true
        let resizedImage = image.convert(to: CGSize(width: 80, height: 80))
        editContactView.badgedImageView.bindData(image: resizedImage)
    }
}

extension EditContactViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15
    }

    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return editContactView.addressInputView
    }

    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 0
    }
}

extension EditContactViewController: QRScannerViewControllerDelegate {
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

        editContactView.addressInputView.text = qrAddress
    }

    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension EditContactViewController: TouchDetectingScrollViewDelegate {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if editContactView.deleteContactButton.frame.contains(point) ||
            editContactView.addressInputView.frame.contains(point) ||
            editContactView.nameInputView.frame.contains(point) {
            return
        }

        contentView.endEditing(true)
    }
}

protocol EditContactViewControllerDelegate: AnyObject {
    func editContactViewController(_ editContactViewController: EditContactViewController, didSave contact: Contact)
}
