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
//  LoadingIndicator.swift

import UIKit

class LoadingIndicator: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let width: CGFloat = 20.0
        let height: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupActivityIndicatorLayout()
    }
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    private func setupActivityIndicatorLayout() {
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.width.equalTo(layout.current.width)
            make.height.equalTo(layout.current.height)
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: API
    
    func show() {
        activityIndicator.startAnimating()
    }
    
    func dismiss() {
        activityIndicator.stopAnimating()
    }
}
