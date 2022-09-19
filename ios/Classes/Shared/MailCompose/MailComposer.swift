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

//   MailComposer.swift

import Foundation
import MessageUI

final class MailComposer:
    NSObject,
    MailComposing {
    weak var delegate: MailComposerDelegate?

    private var mail: Mail?
    private var composeViewController: MFMailComposeViewController? {
        return configureComposeViewController()
    }

    func configureMail(for type: MailType) {
        mail = Mail(type)
    }

    private func configureComposeViewController() -> MFMailComposeViewController? {
        if !MFMailComposeViewController.canSendMail() {
            return nil
        }

        let composeViewController = MFMailComposeViewController()

        guard let mail = mail else {
            return nil
        }

        if let subject = mail.subject {
            composeViewController.setSubject(subject)
        }

        if let message = mail.message {
            composeViewController.setMessageBody(
                message,
                isHTML: false
            )
        }

        composeViewController.setToRecipients(mail.recipients)

        composeViewController.mailComposeDelegate = self

        return composeViewController
    }

    func present(from viewController: UIViewController) {
        guard let composeViewController = composeViewController else {
            return
        }

        viewController.present(
            composeViewController,
            animated: true,
            completion: nil
        )
    }
}

extension MailComposer: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Swift.Error?
    ) {
        controller.dismiss(animated: true) {
            switch result {
            case .cancelled, .saved:
                return
            case .sent:
                self.delegate?.mailComposerDidSent(self)
            case .failed:
                self.delegate?.mailComposerDidFailed(self)
            @unknown default:
                return
            }
        }
    }
}

protocol MailComposerDelegate: AnyObject {
    func mailComposerDidSent(_ mailComposer: MailComposer)
    func mailComposerDidFailed(_ mailComposer: MailComposer)
}
