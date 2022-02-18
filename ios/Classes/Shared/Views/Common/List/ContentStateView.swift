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
//  ContentStateView.swift

import UIKit

class ContentStateView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let loadingIndicatorInset: CGFloat = 100.0
    }
    
    private let layout = Layout<LayoutConstants>()

    var state = State.none {
        didSet {
            if state == oldValue {
                return
            }
            
            updateAppearance()
        }
    }
    
    // MARK: Components
    
    var onContentStateChanged: ((State) -> Void)?
    
    private lazy var contentView = UIView()
    
    private var emptyStateView: UIView?
    private var errorStateView: UIView?
    
    private(set) lazy var loadingIndicator = LoadingIndicator()

    private let bottomInset: CGFloat

    init(bottomInset: CGFloat = 0.0) {
        self.bottomInset = bottomInset
        super.init(frame: .zero)
    }

    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
        updateAppearance()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupContentViewLayout()
        setupLoadingIndicatorLayout()
    }
    
    private func setupContentViewLayout() {
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(bottomInset)
        }
    }
    
    private func setupLoadingIndicatorLayout() {
        contentView.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.loadingIndicatorInset)
        }
    }
    
    // MARK: Updates
    
    private func updateAppearance() {
        switch state {
        case .none:
            setLoadingIndicator(visible: false)
            setEmpty(emptyStateView, visible: false)
            setError(errorStateView, visible: false)
        case .loading:
            setLoadingIndicator(visible: true)
            setEmpty(emptyStateView, visible: false)
            setError(errorStateView, visible: false)
        case let .empty(emptyView):
            setLoadingIndicator(visible: false)
            setError(errorStateView, visible: false)
            setEmpty(emptyView, visible: true)
        case let .error(errorView):
            setLoadingIndicator(visible: false)
            setEmpty(emptyStateView, visible: false)
            setError(errorView, visible: true)
        }
    }
    
    private func setEmpty(_ emptyView: UIView?, visible: Bool) {
        if visible {
            if emptyStateView == emptyView {
                return
            }
            
            guard let view = emptyView else {
                emptyStateView?.removeFromSuperview()
                emptyStateView = nil
                return
            }
            
            contentView.addSubview(view)
            
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            emptyStateView = emptyView
            
            return
        }
        
        self.emptyStateView = nil
        emptyView?.removeFromSuperview()
    }
    
    private func setError(_ errorView: UIView?, visible: Bool) {
        if visible {
            if errorStateView == errorView {
                return
            }
            
            guard let view = errorView else {
                errorStateView?.removeFromSuperview()
                errorStateView = nil
                return
            }
            
            contentView.addSubview(view)
            
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            errorStateView = errorView
            return
        }
        
        self.errorStateView = nil
        errorView?.removeFromSuperview()
    }
    
    private func setLoadingIndicator(visible: Bool) {
        if visible {
            loadingIndicator.show()
        } else {
            loadingIndicator.dismiss()
        }
    }

}

// MARK: State

extension ContentStateView {
    
    enum State: Equatable {
        case none
        case loading
        case empty(UIView)
        case error(UIView)
    }
}
