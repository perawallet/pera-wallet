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

//   CollectibleDetailLayout+Theme.swift

import MacaroonUIKit

extension CollectibleDetailLayout {
    struct Theme:
        StyleSheet,
        LayoutSheet {
        let sectionHorizontalInsets: LayoutHorizontalPaddings
        let headerHeight: LayoutMetric
        let propertyHeight: LayoutMetric
        let propertiesCellSpacing: LayoutMetric
        let nameTopPadding: LayoutMetric
        let accountInformationTopPadding: LayoutMetric
        let mediaTopPadding: LayoutMetric
        let mediaBottomPadding: LayoutMetric
        let actionBottomPadding: LayoutMetric
        let descriptionTopPadding: LayoutMetric
        let descriptionBottomPadding: LayoutMetric
        let propertiesTopPadding: LayoutMetric
        let propertiesBottomPadding: LayoutMetric

        init(
            _ family: LayoutFamily
        ) {
            self.sectionHorizontalInsets = (24, 24)
            self.headerHeight = 28
            self.propertyHeight = 60
            self.propertiesCellSpacing = 16
            self.nameTopPadding = 10
            self.accountInformationTopPadding = 12
            self.mediaTopPadding = 20
            self.mediaBottomPadding = 24
            self.actionBottomPadding = 24
            self.descriptionTopPadding = 12
            self.descriptionBottomPadding = 16
            self.propertiesTopPadding = 16
            self.propertiesBottomPadding = 40
        }
    }
}
