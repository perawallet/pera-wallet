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
//  NotificationView.swift

import UIKit

class NotificationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var badgeImageView: UIImageView = {
        let imageView = UIImageView(image: img("img-nc-item-badge"))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.Background.reversePrimary
        imageView.layer.cornerRadius = layout.current.notificationImageSize.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var timeLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupBadgeImageViewLayout()
        setupNotificationImageViewLayout()
        setupTitleLabelLayout()
        setupTimeLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension NotificationView {
    private func setupBadgeImageViewLayout() {
        addSubview(badgeImageView)
        
        badgeImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.badgeImageSize)
            make.top.equalToSuperview().inset(layout.current.badgeImageTopInset)
            make.leading.equalToSuperview().inset(layout.current.badgeImageHorizontalInset)
        }
    }
    
    private func setupNotificationImageViewLayout() {
        addSubview(notificationImageView)
        
        notificationImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.notificationImageSize)
            make.top.equalToSuperview().inset(layout.current.notificationImageTopInset)
            make.leading.equalTo(badgeImageView.snp.trailing).offset(layout.current.badgeImageHorizontalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleLabelInset)
            make.leading.equalTo(notificationImageView.snp.trailing).offset(layout.current.titleLabelInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTimeLabelLayout() {
        addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.timeLabelTopInset)
            make.leading.equalTo(titleLabel)
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

extension NotificationView {
    func setBadgeHidden(_ hidden: Bool) {
        badgeImageView.isHidden = hidden
    }
    
    func setNotificationImage(_ image: UIImage?) {
        notificationImageView.image = image
    }
    
    func setAttributedTitle(_ title: NSAttributedString?) {
        titleLabel.attributedText = title
    }
    
    func setTime(_ time: String?) {
        timeLabel.text = time
    }
    
    func reset() {
        setBadgeHidden(true)
        setNotificationImage(nil)
        setAttributedTitle(nil)
        setTime(nil)
    }
    
    static func calculatePreferredSize(_ viewModel: NotificationsViewModel?, with layout: Layout<LayoutConstants>) -> CGSize {
        guard let viewModel = viewModel else {
            return .zero
        }
        
        let width = UIScreen.main.bounds.width
        let constantHeight = layout.current.timeLabelTopInset + layout.current.timeLabelBottomInset + layout.current.titleLabelInset
        let titleLabelHeight = viewModel.title?.string.height(
            withConstrained: width - (
                layout.current.badgeImageSize.width +
                    (layout.current.badgeImageHorizontalInset * 2) +
                    layout.current.notificationImageSize.width +
                    layout.current.titleLabelInset +
                    layout.current.horizontalInset
            ),
            font: UIFont.font(withWeight: .regular(size: 14.0))
        ) ?? 40.0
        let timeLabelHeight: CGFloat = 20.0
        let height: CGFloat = constantHeight + titleLabelHeight + timeLabelHeight
        return CGSize(width: width, height: height)
    }
}

extension NotificationView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let badgeImageSize = CGSize(width: 4.0, height: 4.0)
        let badgeImageTopInset: CGFloat = 36.0
        let badgeImageHorizontalInset: CGFloat = 8.0
        let notificationImageTopInset: CGFloat = 20.0
        let titleLabelInset: CGFloat = 16.0
        let timeLabelTopInset: CGFloat = 4.0
        let timeLabelBottomInset: CGFloat = 16.0
        let notificationImageSize = CGSize(width: 36.0, height: 36.0)
        let horizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
}
