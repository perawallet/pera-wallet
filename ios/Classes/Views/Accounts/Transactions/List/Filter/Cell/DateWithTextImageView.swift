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
//  DateWithTextImageView.swift

import UIKit

class DateWithTextImageView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .extraBold(size: 10.0)))
            .withTextColor(Colors.Text.secondary)
        label.isHidden = true
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupDayLabelLayout()
    }
}

extension DateWithTextImageView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.imageSize)
            make.edges.equalToSuperview()
        }
    }
    
    private func setupDayLabelLayout() {
        addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.leading.trailing.equalToSuperview().inset(layout.current.labelInset)
        }
    }
}

extension DateWithTextImageView {
    func setImage(_ image: UIImage?) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.Text.secondary
    }
    
    func setDate(_ date: String) {
        dayLabel.isHidden = false
        dayLabel.text = date
    }
    
    func setSelected() {
        dayLabel.textColor = Colors.General.selected
        imageView.tintColor = Colors.General.selected
    }
    
    func setDeselected() {
        dayLabel.textColor = Colors.Text.secondary
        imageView.tintColor = Colors.Text.secondary
    }
    
    func setDayLabelHidden(_ isHidden: Bool) {
        dayLabel.isHidden = isHidden
    }
}

extension DateWithTextImageView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelInset: CGFloat = 4.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
