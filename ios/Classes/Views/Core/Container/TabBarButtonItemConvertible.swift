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
//  TabBarButtonItemConvertible.swift

import UIKit

protocol TabBarButtonItemConvertible {
    var icon: UIImage? { get }
    var selectedIcon: UIImage? { get }
    var badgeIcon: UIImage? { get }
    var badgePositionAdjustment: CGPoint? { get }
    var width: CGFloat { get } /// <note> The explicit width for the tabbar button
    var isSelectable: Bool { get }
}

extension TabBarButtonItemConvertible {
    var badgeIcon: UIImage? {
        return nil
    }
    
    var badgePositionAdjustment: CGPoint? {
        return .zero
    }
}
