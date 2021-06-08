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
//  TransactionTextInformationView.swift

import UIKit

class TransactionTextInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private(set) lazy var copyImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-copy", isTemplate: true))
        imageView.tintColor = Colors.Component.transactionDetailCopyIcon
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.right)
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupCopyImageViewLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionTextInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCopyImageViewLayout() {
        addSubview(copyImageView)
        
        copyImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.copyImageOffset)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(layout.current.copyImageSize)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.detailLabelOffset)
            make.leading.greaterThanOrEqualTo(copyImageView.snp.trailing).offset(layout.current.detailLabelOffset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension TransactionTextInformationView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String?) {
        detailLabel.text = detail
    }
}

extension TransactionTextInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let detailLabelOffset: CGFloat = 20.0
        let horizontalInset: CGFloat = 20.0
        let labelTopInset: CGFloat = 20.0
        let copyImageOffset: CGFloat = 8.0
        let copyImageSize = CGSize(width: 20.0, height: 20.0)
        let separatorHeight: CGFloat = 1.0
    }
}
