// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupFileViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupFileViewModel: ViewModel {
    var isActionVisible: Bool {
        actionTheme != nil
    }

    var isEmptyState: Bool {
        switch state {
        case .empty:
            return true
        default:
            return false
        }
    }

    private(set) var image: ImageProvider?
    private(set) var imageStyle: ImageStyle?
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?
    private(set) var actionTheme: ButtonStyle?

    private let state: State

    init(state: State) {
        self.state = state
        bindImage(for: state)
        bindTitle(for: state)
        bindSubtitle(for: state)
        bindActionTheme(for: state)
    }
}

extension AlgorandSecureBackupFileViewModel {
    private mutating func bindImage(for state: State) {
        switch state {
        case .empty:
            image = "icon-share-24".templateImage
            imageStyle = [
                .tintColor(Colors.Text.main)
            ]
        case .uploaded:
            image = "icon-check".templateImage
            imageStyle = [
                .tintColor(Colors.Helpers.positive)
            ]
        case .uploadFailed:
            image = "icon-error-close".templateImage
            imageStyle = [
                .tintColor(Colors.Helpers.negative)
            ]
        }
    }

    private mutating func bindTitle(for state: State) {
        switch state {
        case .empty:
            title = "algorand-secure-backup-import-backup-title".localized.bodyMedium(alignment: .center)
        case .uploaded:
            title = "algorand-secure-backup-import-backup-upload-successful-title".localized.bodyMedium(alignment: .center)
        case .uploadFailed(let validationError):
            bindValidationError(validationError)
        }
    }

    private mutating func bindValidationError(
        _ validationError: BackupValidationError
    ) {
        let errorTitle: String

        switch validationError {
        case .emptySource:
            errorTitle = "algorand-secure-backup-import-backup-clipboard-failed-subtitle".localized
        case .wrongFormat:
            errorTitle = "algorand-secure-backup-import-backup-clipboard-json-failed-title".localized
        case .unsupportedVersion:
            errorTitle = "algorand-secure-backup-import-backup-clipboard-version-failed-title".localized
        case .cipherSuiteUnknown:
            errorTitle = "algorand-secure-backup-import-backup-clipboard-cipher-suite-failed-title".localized
        case .jsonSerialization:
            errorTitle = "algorand-secure-backup-import-backup-clipboard-json-failed-title".localized
        case .unauthorized:
            errorTitle = "algorand-secure-backup-import-backup-clipboard-unauthorized-failed-title".localized
        case .keyNotFound(let key):
            errorTitle = "algorand-secure-backup-import-backup-clipboard-key-not-exist".localized(params: key)
        }

        title = errorTitle.bodyMedium(alignment: .center)
    }

    private mutating func bindSubtitle(for state: State) {
        switch state {
        case .empty:
            subtitle = nil
        case .uploaded(let fileName):
            subtitle = fileName.footnoteRegular(alignment: .center)
        case .uploadFailed:
            subtitle = nil
        }
    }

    private mutating func bindActionTheme(for state: State) {
        let theme = AlgorandSecureBackupFileViewTheme()

        switch state {
        case .empty:
            actionTheme = nil
        case .uploaded:
            actionTheme = theme.replaceAction
        case .uploadFailed:
            actionTheme = theme.action
        }
    }
}

extension AlgorandSecureBackupFileViewModel {
    enum State {
        case empty
        case uploaded(fileName: String)
        case uploadFailed(BackupValidationError)
    }
}

struct AlgorandSecureBackup {
    let data: Data?
    let fileName: String

    init(url: URL) throws {
        let base64EncodedData = try Data(contentsOf: url)
        data = Data(base64Encoded: base64EncodedData)
        fileName = url.lastPathComponent
    }

    init(data: Data) {
        self.data = data
        let dateString = Date().toFormat(.shortNumericReversed(separator: "-"))
        self.fileName = "\(dateString)_backup.txt"
    }
}
