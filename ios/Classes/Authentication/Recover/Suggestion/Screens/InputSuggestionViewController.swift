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
//   InputSuggestionViewController.swift

import UIKit

final class InputSuggestionViewController: BaseViewController {
    weak var delegate: InputSuggestionViewControllerDelegate?

    private lazy var dataController = InputSuggestionsDataController()
    private lazy var dataSource = InputSuggestionDataSource(dataController: dataController)
    private lazy var layoutBuilder = InputSuggestionLayoutBuilder()

    private lazy var suggestionsCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = Colors.Keyboard.accessoryBackground.uiColor
        collectionView.register(InputSuggestionCell.self)
        return collectionView
    }()

    override func linkInteractors() {
        suggestionsCollectionView.dataSource = dataSource
        suggestionsCollectionView.delegate = layoutBuilder
        layoutBuilder.delegate = self
        dataController.delegate = self
    }

    override func prepareLayout() {
        addSuggestionsCollectionView()
    }
}

extension InputSuggestionViewController {
    private func addSuggestionsCollectionView() {
        view.addSubview(suggestionsCollectionView)
        suggestionsCollectionView.pinToSuperview()
    }
}

extension InputSuggestionViewController: InputSuggestionLayoutBuilderDelegate {
    func inputSuggestionLayoutBuilder(
        _ inputSuggestionLayoutBuilder: InputSuggestionLayoutBuilder,
        didSelectItemAt index: Int
    ) {
        if let suggestion = dataController.suggestion(at: index),
           !suggestion.isEmpty {
            delegate?.inputSuggestionViewController(self, didSelect: suggestion)
        }
    }
}

extension InputSuggestionViewController: InputSuggestionsDataControllerDelegate {
    func inputSuggestionsDataController(
        _ inputSuggestionsDataController: InputSuggestionsDataController,
        didFailedWith error: InputSuggestionsDataController.SuggestionError
    ) { }
}

extension InputSuggestionViewController {
    func findTopSuggestions(for text: String?) {
        guard let query = text else {
            return
        }

        dataController.findTopSuggestions(for: query)
        suggestionsCollectionView.reloadData()
    }

    func hasMatchingSuggestion(with input: String) -> Bool {
        dataController.hasMatchingSuggestion(with: input)
    }

    var hasSuggestions: Bool {
        return dataController.hasSuggestions
    }
}

protocol InputSuggestionViewControllerDelegate: AnyObject {
    func inputSuggestionViewController(
        _ inputSuggestionViewController: InputSuggestionViewController,
        didSelect mnemonic: String
    )
}
