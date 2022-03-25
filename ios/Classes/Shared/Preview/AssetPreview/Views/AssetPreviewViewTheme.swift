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
//   AssetPreviewViewTheme.swift

import MacaroonUIKit

protocol AssetPreviewViewTheme: StyleSheet, LayoutSheet {
    var primaryAssetTitle: TextStyle { get }
    var secondaryAssetTitle: TextStyle { get }
    var primaryAssetValue: TextStyle { get }
    var secondaryAssetValue: TextStyle { get }
    var imageSize: LayoutSize { get }
    var horizontalPadding: LayoutMetric { get }
    var verticalPadding: LayoutMetric { get }
    var secondaryImageLeadingPadding: LayoutMetric { get }
    var assetValueMinRatio: LayoutMetric { get }
}
