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
//  Colors.swift

import UIKit

enum Colors {
    enum Main {
        static let primary600 = color("primary600")
        static let white = color("white")
    }
}

extension Colors {
    enum Background {
        static let primary = color("primaryBackground")
        static let secondary = color("secondaryBackground")
        static let tertiary = color("tertiaryBackground")
        static let disabled = color("disabledBackground")
    }
}

extension Colors {
    enum Component {
        static let separator = color("separatorColor")
        static let accountHeader = color("accountHeaderColor")
        static let assetHeader = color("selectAssetHeaderColor")
        static let dappImageBorderColor = color("wcAccountSelectionBorderColor")
    }
}

extension Colors {
    enum General {
        static let testNetBanner = color("testNetBanner")
        static let error = color("errorColor")
        static let selected = color("selectedColor")
        static let unknown = color("unknownColor")
    }
}

extension Colors {
    enum ButtonText {
        static let primary = color("primaryButtonTitle")
        static let secondary = color("secondaryButtonTitle")
        static let tertiary = color("tertiaryButtonTitle")
        static let actionButton = color("actionButtonTitle")
    }
}

extension Colors {
    enum Text {
        static let primary = color("primaryText")
        static let secondary = color("secondaryText")
        static let tertiary = color("tertiaryText")
        static let hint = color("hintText")
        static let link = color("linkText")
    }
}

extension Colors {
    enum Shadow {
        static let mediumBottom = color("mediumBottomShadow")
        static let mediumTop = color("mediumTopShadow")
        static let smallBottom = color("smallBottomShadow")
        static let smallTop = color("smallTopShadow")
        static let error = color("errorShadow")
    }
}

extension Colors {
    enum Chart {
        enum Line {
            static let increasing = AppColors.Shared.Helpers.positive.uiColor
            static let decreasing = AppColors.Shared.Helpers.negative.uiColor
            static let stable = AppColors.Components.Text.gray.uiColor
        }
    }
}
