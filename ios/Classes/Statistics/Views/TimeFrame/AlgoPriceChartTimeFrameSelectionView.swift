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
//   AlgoPriceChartTimeFrameSelectionView.swift

import UIKit
import MacaroonUIKit
import SnapKit

final class AlgoPriceChartTimeFrameSelectionView:
    View,
    ViewModelBindable {
    typealias SelectionHandler = (Int) -> Void
    
    var selectedIndex: Int? {
        get { return selectedOptionView?.tag }
        set {
            let optionsView = contentView.arrangedSubviews as? [UIControl]
            let optionView = optionsView?[safe: newValue]
            selectedOptionView = optionView
        }
    }
    
    var selectionHandler: SelectionHandler?
    
    private lazy var contentView = UIStackView()
    private lazy var selectionView = MacaroonUIKit.BaseView()
    private lazy var loadingView = ShimmerView()
    
    private var selectedOptionView: UIControl? {
        didSet { updateOptionsForSelection(selectedOptionView) }
    }
    
    private var selectionViewPositionConstraints: [Constraint] = []
    private var theme: AlgoPriceChartTimeFrameSelectionViewTheme?

    func customize(
        _ theme: AlgoPriceChartTimeFrameSelectionViewTheme
    ) {
        self.theme = theme

        addContent(theme)
        addSelection(theme)
        addLoading(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: AlgoPriceChartTimeFrameSelectionViewModel?
    ) {
        addOptions(viewModel?.options)
        loadingView.isHidden = viewModel != nil
        selectionView.isHidden = viewModel == nil
    }
}

extension AlgoPriceChartTimeFrameSelectionView {
    private func addContent(
        _ theme: AlgoPriceChartTimeFrameSelectionViewTheme
    ) {
        addSubview(contentView)
        contentView.distribution = .fillEqually
        contentView.alignment = .center
        contentView.spacing = theme.spacingBetweenOptions
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addSelection(
        _ theme: AlgoPriceChartTimeFrameSelectionViewTheme
    ) {
        selectionView.customizeAppearance(theme.selection)
        selectionView.drawAppearance(corner: theme.selectionCorner)
        
        contentView.insertSubview(
            selectionView,
            at: 0
        )
        selectionView.snp.makeConstraints {
            $0.top == 0
            $0.bottom == 0
            
            $0.lessThanWidth(theme.selectionMaxWidth)
        }
    }
    
    private func addOptions(
        _ options: [AlgoPriceChartTimeFrameSelection]?
    ) {
        contentView.deleteAllArrangedSubviews()
        options?.enumerated().forEach {
            index, option in
            let optionView = createOption(option)
            optionView.tag = index
            contentView.addArrangedSubview(optionView)
        }

        (contentView.arrangedSubviews[safe: 3] as? UIControl)?.isSelected = true
    }
    
    private func updateOptionsForSelection(
        _ optionView: UIControl?
    ) {
        selectionViewPositionConstraints.deactivate()
        
        guard let optionView = optionView else {
            return
        }
        
        selectionView.snp.makeConstraints {
            let widthConstraint = $0.width <= optionView
            let centerXConstraint = $0.centerX == optionView
            
            selectionViewPositionConstraints = [
                widthConstraint,
                centerXConstraint
            ]
        }
    }
    
    private func createOption(
        _ timeFrame: AlgoPriceChartTimeFrameSelection
    ) -> UIControl {
        let optionView = MacaroonUIKit.Button()

        if let theme = theme {
            optionView.customizeAppearance(theme.option)
        }
        
        optionView.setTitle(
            timeFrame.title,
            for: .normal
        )
        optionView.addTouch(
            target: self,
            action: #selector(selectOption(_:))
        )
        
        return optionView
    }
    
    private func addLoading(
        _ theme: AlgoPriceChartTimeFrameSelectionViewTheme
    ) {
        loadingView.draw(corner: theme.loadingCorner)
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension AlgoPriceChartTimeFrameSelectionView {
    @objc
    private func selectOption(
        _ optionView: UIControl
    ) {
        deselectPreviousOption(selectedOptionView)

        selectedOptionView = optionView
        selectedOptionView?.isSelected = true
        selectionHandler?(optionView.tag)
    }

    private func deselectPreviousOption(
        _ optionView: UIControl?
    ) {
        optionView?.isSelected = false
    }
}
