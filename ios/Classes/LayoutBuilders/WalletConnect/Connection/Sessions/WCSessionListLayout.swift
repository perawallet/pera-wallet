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
//   WCSessionListLayout.swift

import UIKit

class WCSessionListLayout: NSObject {

    private let layout = Layout<LayoutConstants>()

    private weak var dataSource: WCSessionListDataSource?

    init(dataSource: WCSessionListDataSource) {
        self.dataSource = dataSource
        super.init()
    }
}

extension WCSessionListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let session = dataSource?.session(at: indexPath.item) else {
            return .zero
        }

        var descriptionHeight: CGFloat = 0.0

        if let description = session.peerMeta.description {
            descriptionHeight = description.height(
                withConstrained: UIScreen.main.bounds.width - layout.current.horizontalInset,
                font: UIFont.font(withWeight: .regular(size: 14.0))
            )
        }

        return CGSize(width: UIScreen.main.bounds.width, height: descriptionHeight + layout.current.constantHeight)
    }
}

extension WCSessionListLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let constantHeight: CGFloat = 128.0
        let horizontalInset: CGFloat = 100.0
    }
}
