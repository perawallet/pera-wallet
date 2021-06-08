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
//   InputSuggestionDataSource.swift

import UIKit

class InputSuggestionDataSource: NSObject {

    weak var dataController: InputSuggestionsDataController?

    init(dataController: InputSuggestionsDataController) {
        self.dataController = dataController
        super.init()
    }
}

extension InputSuggestionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let suggestion = dataController?.suggestion(at: indexPath.item),
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InputSuggestionCell.reusableIdentifier,
                for: indexPath
            ) as? InputSuggestionCell else {
            fatalError("Index path is out of bounds")
        }

        cell.bind(InputSuggestionViewModel(suggestion: suggestion, index: indexPath.item))
        return cell
    }
}
