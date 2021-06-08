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
//  RangeSelectionView.swift

import UIKit

class RangeSelectionView: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var imageView = UIImageView()
    
    private lazy var dateLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var separatorView = UIImageView(image: img("img-custom-range-separator"))
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupDateLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension RangeSelectionView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.labelOffset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelOffset)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalTo(imageView)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.labelOffset)
        }
    }
}

extension RangeSelectionView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setDate(_ date: String) {
        dateLabel.text = date
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            imageView.tintColor = Colors.General.selected
            separatorView.image = img("img-custom-range-separator-selected")
        } else {
            imageView.tintColor = Colors.RangeSelection.rangeIcon
            separatorView.image = img("img-custom-range-separator")
        }
    }
}

extension Colors {
    fileprivate enum RangeSelection {
        static let rangeIcon = color("transactionFilterRange")
    }
}

extension RangeSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelOffset: CGFloat = 8.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
