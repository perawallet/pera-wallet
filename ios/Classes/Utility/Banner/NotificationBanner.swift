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
//  NotificationBanner.swift

import Foundation
import NotificationBannerSwift

enum NotificationBanner {
    static func showInformation(_ information: String, completion handler: EmptyHandler? = nil) {
        let banner = FloatingNotificationBanner(
            title: information,
            titleFont: UIFont.font(withWeight: .semiBold(size: 16.0)),
            titleColor: Colors.Text.primary,
            titleTextAlign: .left,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.8
        
        if UIApplication.shared.isDarkModeDisplay {
            banner.show(edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0), cornerRadius: 12.0)
        } else {
            banner.show(
                edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0),
                cornerRadius: 10.0,
                shadowColor: rgba(0.0, 0.0, 0.0, 0.1),
                shadowOpacity: 1.0,
                shadowBlurRadius: 6.0,
                shadowCornerRadius: 6.0,
                shadowOffset: UIOffset(horizontal: 0.0, vertical: 2.0)
            )
        }
        
        banner.onTap = handler
    }
    
    static func showError(_ error: String, message: String) {
        let banner = FloatingNotificationBanner(
            title: error,
            subtitle: message,
            titleFont: UIFont.font(withWeight: .semiBold(size: 16.0)),
            titleColor: Colors.ButtonText.primary,
            titleTextAlign: .left,
            subtitleFont: UIFont.font(withWeight: .regular(size: 14.0)),
            subtitleColor: Colors.ButtonText.primary,
            subtitleTextAlign: .left,
            leftView: UIImageView(image: img("icon-warning-circle")),
            style: .warning,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.8
        
        if UIApplication.shared.isDarkModeDisplay {
            banner.show(edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0), cornerRadius: 12.0)
        } else {
            banner.show(
                edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0),
                cornerRadius: 12.0,
                shadowColor: Colors.Shadow.error,
                shadowOpacity: 1.0,
                shadowBlurRadius: 20.0,
                shadowCornerRadius: 6.0,
                shadowOffset: UIOffset(horizontal: 0.0, vertical: 12.0)
            )
        }
    }
    
    static func showSuccess(_ success: String, message: String) {
        let banner = FloatingNotificationBanner(
            title: success,
            subtitle: message,
            titleFont: UIFont.font(withWeight: .semiBold(size: 16.0)),
            titleColor: Colors.ButtonText.primary,
            titleTextAlign: .left,
            subtitleFont: UIFont.font(withWeight: .regular(size: 14.0)),
            subtitleColor: Colors.ButtonText.primary,
            subtitleTextAlign: .left,
            style: .success,
            colors: CustomBannerColors()
        )
        
        banner.duration = 3.8
        banner.show(edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0), cornerRadius: 12.0)
    }
}

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .warning:
            return Colors.General.error
        case .success:
            return Colors.General.success
        default:
            return Colors.Background.secondary
        }
    }
}

extension Colors {
    fileprivate enum NotificationBanner {
        
    }
}
