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
//  TestNetTitleDisplayable.swift

import Foundation

protocol TestNetTitleDisplayable {
    func displayTestNetTitleView(with title: String)
}

extension TestNetTitleDisplayable where Self: BaseViewController {
    func displayTestNetTitleView(with title: String) {
        guard let isTestNet = api?.isTestNet, isTestNet else {
            self.title = title
            return
        }
        
        let titleView = TestNetTitleView()
        titleView.setTitle(title)
        navigationItem.titleView = titleView
    }
}
