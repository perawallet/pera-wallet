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
//  Colors.swift

import UIKit

enum Colors {
    enum Main {
        static let primary600 = color("primary600")
        static let primary700 = color("primary700")
        static let secondary600 = color("secondary600")
        static let secondary700 = color("secondary700")
        static let blue600 = color("blue600")
        static let red600 = color("red600")
        static let white = color("white")
        static let black = color("black")
        static let yellow600 = color("yellow600")
        static let yellow700 = color("yellow700")
        static let gray50 = color("gray50")
        static let gray100 = color("gray100")
        static let gray200 = color("gray200")
        static let gray300 = color("gray300")
        static let gray400 = color("gray400")
        static let gray500 = color("gray500")
        static let gray600 = color("gray600")
        static let gray700 = color("gray700")
        static let gray800 = color("gray800")
        static let gray900 = color("gray900")
    }
}

extension Colors {
    enum Background {
        static let primary = color("primaryBackground")
        static let secondary = color("secondaryBackground")
        static let tertiary = color("tertiaryBackground")
        static let disabled = color("disabledBackground")
        static let reversePrimary = color("reversePrimaryBackground")
    }
}

extension Colors {
    enum Component {
        static let separator = color("separatorColor")
        static let accountHeader = color("accountHeaderColor")
        static let assetHeader = color("selectAssetHeaderColor")
        static let transactionDetailCopyIcon = color("transactionDetailCopyColor")
        static let inputSuggestionText = color("inputSuggestionTextColor")
        static let inputSuggestionBackground = color("inputSuggestionBackgroundColor")
    }
}

extension Colors {
    enum General {
        static let verified = color("verified")
        static let testNetBanner = color("testNetBanner")
        static let error = color("errorColor")
        static let success = color("primary600")
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
            static let increasing = color("chartLineIncreasingColor")
            static let decreasing = color("chartLineDecreasingColor")
            static let stable = color("chartLineStableColor")
        }
    }
}
