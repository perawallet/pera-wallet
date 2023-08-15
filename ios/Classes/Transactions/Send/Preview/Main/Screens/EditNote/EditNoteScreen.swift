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
import MacaroonBottomSheet
import MacaroonForm
import MacaroonUIKit

final class EditNoteScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable,
    MacaroonForm.KeyboardControllerDataSource {
    weak var delegate: EditNoteScreenDelegate?

    var modalBottomPadding: LayoutMetric {
        return bottomInsetUnderKeyboardWhenKeyboardDidShow(keyboardController)
    }

    let modalHeight: MacaroonUIKit.ModalHeight = .compressed

    private lazy var theme = EditNoteScreenTheme()

    private lazy var noteInputView = MultilineTextInputFieldView()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private var contentSizeObservation: NSKeyValueObservation?

    private var note: String?
    private let isLocked: Bool
    
    private var transactionNoteValidator = NoteSizeValidator()

    init(
        note: String?,
        isLocked: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.note = note
        self.isLocked = isLocked
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        bindNavigationTitle()
        addNavigationActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureKeyboardController()
        addUI()
        startObservingContentSizeChanges()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isLocked else {
            return
        }

        noteInputView.beginEditing()
    }
}

extension EditNoteScreen {
    private func addUI() {
        addBackground()
        addNoteInput()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNoteInput() {
        noteInputView.customize(theme.noteInput)

        contentView.addSubview(noteInputView)
        noteInputView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.greaterThanHeight(theme.noteInputMinHeight)
        }

        noteInputView.delegate = self
        noteInputView.editingDelegate = self

        bindNoteInput()
    }
}

extension EditNoteScreen {
    private func bindNavigationTitle() {
        if isLocked {
            navigationItem.title = "send-transaction-show-note-title".localized
            return
        }

        if note.isNilOrEmpty {
            navigationItem.title = "edit-note-title".localized
        } else {
            navigationItem.title = "send-transaction-edit-note-title".localized
        }
    }

    private func addNavigationActions() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Text.main.uiColor)) {
            [unowned self] in
            self.didTapDoneButton()
        }

        rightBarButtonItems = [ doneBarButtonItem ]
    }
}

extension EditNoteScreen {
    private func bindNoteInput() {
        noteInputView.text = note

        if isLocked {
            noteInputView.isUserInteractionEnabled = false
        }
    }
}

extension EditNoteScreen: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView) {
        didTapDoneButton()
    }
}

extension EditNoteScreen: FormInputFieldViewEditingDelegate {
    func formInputFieldViewDidEdit(_ view: MacaroonForm.FormInputFieldView) {
        updateNoteAfterValidation()
    }
    
    func formInputFieldViewDidEndEditing(_ view: MacaroonForm.FormInputFieldView) {}
    
    func formInputFieldViewDidBeginEditing(_ view: MacaroonForm.FormInputFieldView) {}
}

extension EditNoteScreen {
    private func updateNoteAfterValidation() {
        guard let noteByteArray = noteInputView.text?.convertToByteArray() else {
            return
        }
        
        let validation = transactionNoteValidator.validate(byteArray: noteByteArray)
        
        switch validation {
        case .success:
            return
        case .failure(let validationError):
            switch validationError {
            case .exceededSize(let extraSize):
                noteInputView.text = String(
                    decoding: noteByteArray.dropLast(extraSize),
                    as: UTF8.self
                )
            }
        }
    }
}

extension EditNoteScreen {
    private func didTapDoneButton() {
        delegate?.editNoteScreen(self, didUpdateNote: noteInputView.text)
    }
}

/// <mark>
/// MacaroonForm.KeyboardControllerDataSource
extension EditNoteScreen {
    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return keyboardController.keyboard?.height ?? 0
    }
}

extension EditNoteScreen {
    private func configureKeyboardController() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            self.performLayoutUpdates(animated: false)
        }
    }
}

extension EditNoteScreen {
    private func startObservingContentSizeChanges() {
        contentSizeObservation = scrollView.observe(
            \.contentSize,
             options: .new
        ) {
            [weak self] _, _ in
            guard let self = self else {
                return
            }

            if !self.isViewAppeared {
                return
            }

            self.performLayoutUpdates(animated: true)
        }
    }
}

protocol EditNoteScreenDelegate: AnyObject {
    func editNoteScreen(_ screen: EditNoteScreen, didUpdateNote note: String?)
}
