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

//   ALGActiveLabel.swift

import ActiveLabel
import MacaroonUIKit
import UIKit

final class ALGActiveLabel: ActiveLabel {
    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        preferredMaxLayoutWidth = bounds.width
    }
}

enum ALGActiveType {
    case mention
    case hashtag
    case url
    case email
    case word(String)
    case custom(pattern: String)

    var mapped: ActiveType {
        switch self {
        case .mention: return .mention
        case .hashtag: return .hashtag
        case .url: return .url
        case .email: return .email
        case .word(let word): return .custom(pattern: "\(word)\\b") /// <note> Regex that looks for `word`
        case .custom(let pattern): return .custom(pattern: pattern)
        }
    }
}

extension ALGActiveLabel {
    func attachHyperlink(
        _ hyperlink: ALGActiveType,
        to text: TextProvider,
        attributes: TextAttributeGroup,
        handler: @escaping () -> Void
    ) {
        customize { label in
            text.load(in: label)

            let activeType = hyperlink.mapped

            label.enabledTypes = label.enabledTypes + [ activeType ]

            label.configureLinkAttribute = {
                type, someAttributes, _ in

                var mutableAttributes = someAttributes

                switch type {
                case activeType:
                    attributes.asSystemAttributes().forEach {
                        mutableAttributes[$0.key] = $0.value
                    }
                default: break
                }

                return mutableAttributes
            }

            label.handleCustomTap(for: activeType) { _ in
                handler()
            }
        }
    }
}
