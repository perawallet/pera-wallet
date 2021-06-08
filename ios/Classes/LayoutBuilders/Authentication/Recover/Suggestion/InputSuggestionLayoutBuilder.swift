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
//   InputSuggestionLayoutBuilder.swift

import UIKit

class InputSuggestionLayoutBuilder: NSObject {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: InputSuggestionLayoutBuilderDelegate?

    func registerCells(to collectionView: UICollectionView) {
        collectionView.register(InputSuggestionCell.self, forCellWithReuseIdentifier: InputSuggestionCell.reusableIdentifier)
    }
}

extension InputSuggestionLayoutBuilder: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.inputSuggestionLayoutBuilder(self, didSelectItemAt: indexPath.item)
    }
}

extension InputSuggestionLayoutBuilder {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width / 3.0, height: 44.0)
    }
}

protocol InputSuggestionLayoutBuilderDelegate: class {
    func inputSuggestionLayoutBuilder(_ inputSuggestionLayoutBuilder: InputSuggestionLayoutBuilder, didSelectItemAt index: Int)
}
