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
//  RangeSelectionView.swift

import UIKit
import MacaroonUIKit

final class RangeSelectionView: Control {
    private lazy var theme = RangeSelectionViewTheme()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(theme.intrinsicContentSize)
    }

    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var dateLabel = UILabel()
    private lazy var focusIndicatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: RangeSelectionViewTheme) {
        addTitleLabel(theme)
        addImageView(theme)
        addDateLabel(theme)
        addFocusIndicatorView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension RangeSelectionView {
    private func addTitleLabel(_ theme: RangeSelectionViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }
    
    private func addImageView(_ theme: RangeSelectionViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageViewSize)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.imageViewTopInset)
        }
    }
    
    private func addDateLabel(_ theme: RangeSelectionViewTheme) {
        dateLabel.customizeAppearance(theme.dateLabel)

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.dateLabelLeadingPadding)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerY.equalTo(imageView)
        }
    }

    private func addFocusIndicatorView(_ theme: RangeSelectionViewTheme) {
        focusIndicatorView.customizeAppearance(theme.focusIndicator)

        addSubview(focusIndicatorView)
        focusIndicatorView.snp.makeConstraints {
            $0.fitToHeight(theme.focusIndicatorViewDefaultHeight)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension RangeSelectionView {
    private func updateFocusIndicator(_ isSelected: Bool?) {
        let height: LayoutMetric
        let backgroundColor: Color

        if isSelected.falseIfNil {
            backgroundColor = theme.focusIndicatorViewSelectedColor
            height = theme.focusIndicatorViewSelectedHeight
        } else {
            backgroundColor = theme.focusIndicatorViewDefaultColor
            height = theme.focusIndicatorViewDefaultHeight
        }

        focusIndicatorView.backgroundColor = backgroundColor.uiColor
        focusIndicatorView.snp.updateConstraints {
            $0.fitToHeight(height)
        }
    }
}

extension RangeSelectionView: ViewModelBindable {
    func bindData(_ viewModel: RangeSelectionViewModel?) {
        if let date = viewModel?.date {
            dateLabel.text = date
            return
        }

        titleLabel.text = viewModel?.title
        imageView.image = viewModel?.image
    }
    
    func setSelected(_ isSelected: Bool?) {
        updateFocusIndicator(isSelected)
    }
}
