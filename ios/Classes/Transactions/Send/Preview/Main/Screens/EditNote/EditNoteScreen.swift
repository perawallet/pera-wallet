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
//   EditNoteScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class EditNoteScreen: BaseViewController {
    weak var delegate: EditNoteScreenDelegate?

    private lazy var theme = Theme()
    private lazy var editNoteView = EditNoteView()

    private var note: String?
    private let isLocked: Bool

    init(note: String?, isLocked: Bool, configuration: ViewControllerConfiguration) {
        self.note = note
        self.isLocked = isLocked
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    override func setListeners() {
        editNoteView.delegate = self
    }
    
    override func linkInteractors() {
        editNoteView.doneButton.addTarget(
            self,
            action: #selector(didTapDoneButton),
            for: .touchUpInside
        )
    }

    override func prepareLayout() {
        editNoteView.customize(theme.editNoteViewTheme)

        view.addSubview(editNoteView)
        editNoteView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        editNoteView.bindData(note)

        if isLocked {
            title = "send-transaction-show-note-title".localized

            editNoteView.noteInputView.isUserInteractionEnabled = false
            return
        }

        if note.isNilOrEmpty {
            title = "edit-note-title".localized
        } else {
            title = "send-transaction-edit-note-title".localized
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isLocked else {
            return
        }

        editNoteView.beginEditing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        editNoteView.endEditing()
    }

    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done) {
            [weak self] in

            guard let self = self else {
                return
            }

            self.didTapDoneButton()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }
}

extension EditNoteScreen {
    @objc
    private func didTapDoneButton() {
        delegate?.editNoteScreen(self, didUpdateNote: editNoteView.noteInputView.text)
        dismissScreen()
    }
}

extension EditNoteScreen: EditNoteViewDelegate {
    func editNoteViewDidReturn(_ editNoteView: EditNoteView) {
        didTapDoneButton()
    }
}

extension EditNoteScreen: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight)
    }
}

protocol EditNoteScreenDelegate: AnyObject {
    func editNoteScreen(_ editNoteScreen: EditNoteScreen, didUpdateNote note: String?)
}
