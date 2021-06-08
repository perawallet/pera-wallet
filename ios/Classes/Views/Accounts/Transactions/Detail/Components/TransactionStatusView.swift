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
//  TransactionStatusView.swift

import UIKit

class TransactionStatusView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var statusLabel: UILabel = {
        UILabel().withFont(UIFont.font(withWeight: .bold(size: 12.0))).withAlignment(.center)
    }()
    
    override func configureAppearance() {
        layer.cornerRadius = 14.0
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupStatusLabelLayout()
    }
}

extension TransactionStatusView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupStatusLabelLayout() {
        addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.centerY.equalTo(imageView)
        }
    }
}

extension TransactionStatusView {
    func setStatus(_ status: Transaction.Status) {
        statusLabel.text = status.rawValue
        
        switch status {
        case .completed:
            imageView.image = img("icon-check")
            statusLabel.textColor = Colors.TransactionStatus.Text.completed
            backgroundColor = Colors.TransactionStatus.Background.completed
        case .pending:
            imageView.image = img("icon-pending")
            statusLabel.textColor = Colors.TransactionStatus.Text.pending
            backgroundColor = Colors.TransactionStatus.Background.pending
        case .failed:
            imageView.image = img("icon-failed-red")
            statusLabel.textColor = Colors.TransactionStatus.Text.failed
            backgroundColor = Colors.TransactionStatus.Background.failed
        }
    }
}

extension Colors {
    fileprivate enum TransactionStatus {
        fileprivate enum Background {
            static let pending = Colors.Main.yellow600.withAlphaComponent(0.1)
            static let completed = Colors.Main.primary600.withAlphaComponent(0.1)
            static let failed = Colors.Main.red600.withAlphaComponent(0.1)
        }
        
        fileprivate enum Text {
            static let pending = Colors.Main.yellow700
            static let completed = Colors.Main.primary700
            static let failed = Colors.Main.red600
        }
    }
}

extension TransactionStatusView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let leadingInset: CGFloat = 8.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let verticalInset: CGFloat = 4.0
        let labelLeadingInset: CGFloat = 4.0
        let trailingInset: CGFloat = 12.0
    }
}
