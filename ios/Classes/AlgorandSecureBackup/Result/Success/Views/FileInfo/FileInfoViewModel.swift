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

//   FileInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct FileInfoViewModel: ViewModel {
    var icon: Image?
    var name: TextProvider?
    var size: TextProvider?

    init(file: AlgorandSecureBackup) {
        bindIcon()
        bindName(using: file)
        bindSize(using: file)
    }
}

extension FileInfoViewModel {
    mutating func bindIcon() {
        icon = "icon-txt-file"
    }

    mutating func bindName(using backup: AlgorandSecureBackup) {
        name = backup.fileName.footnoteMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindSize(using backup: AlgorandSecureBackup) {
        guard let data = backup.data else { return }
        let dataByteFormatter = ByteCountFormatter()
        dataByteFormatter.allowedUnits = [.useKB]
        dataByteFormatter.countStyle = .binary
        let formattedSize = dataByteFormatter.string(fromByteCount: Int64(data.count))

        size = formattedSize.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
