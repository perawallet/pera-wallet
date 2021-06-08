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
//  TransactionContactInformationView.swift

import UIKit

class TransactionContactInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionContactInformationViewDelegate?
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private(set) lazy var copyImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-copy", isTemplate: true))
        imageView.tintColor = Colors.Component.transactionDetailCopyIcon
        imageView.isHidden = true
        return imageView
    }()
    
    private(set) lazy var contactDisplayView = ContactDisplayView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        contactDisplayView.delegate = self
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupCopyImageViewLayout()
        setupContactDisplayViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionContactInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
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
    
    private func setupContactDisplayViewLayout() {
        addSubview(contactDisplayView)
        
        contactDisplayView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.contactDisplayViewOffset)
            make.leading.greaterThanOrEqualTo(copyImageView.snp.trailing).offset(layout.current.contactDisplayViewOffset)
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

extension TransactionContactInformationView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setContact(_ contact: Contact) {
        contactDisplayView.setContact(contact)
    }
    
    func setName(_ name: String) {
        contactDisplayView.setName(name)
    }
    
    func removeContactAction() {
        contactDisplayView.removeAction()
    }
    
    func removeContactImage() {
        contactDisplayView.removeImage()
    }
    
    func setContactButtonImage(_ image: UIImage?) {
        contactDisplayView.setButtonImage(image)
    }
    
    func setContactImage(hidden: Bool) {
        contactDisplayView.setImage(hidden: hidden)
    }
}

extension TransactionContactInformationView: ContactDisplayViewDelegate {
    func contactDisplayViewDidTapActionButton(_ contactDisplayView: ContactDisplayView) {
        delegate?.transactionContactInformationViewDidTapActionButton(self)
    }
}

extension TransactionContactInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let contactDisplayViewOffset: CGFloat = 10.0
        let labelTopInset: CGFloat = 20.0
        let copyImageOffset: CGFloat = 8.0
        let copyImageSize = CGSize(width: 20.0, height: 20.0)
        let separatorHeight: CGFloat = 1.0
    }
}

protocol TransactionContactInformationViewDelegate: class {
    func transactionContactInformationViewDidTapActionButton(_ transactionContactInformationView: TransactionContactInformationView)
}
