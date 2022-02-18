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
//  TooltipViewController.swift

import UIKit

class TooltipViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var tooltipLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withText(tooltipText)
            .withTextColor(Colors.Main.white)
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    private let tooltipText: String
    
    init(title: String, configuration: ViewControllerConfiguration) {
        tooltipText = title
        super.init(configuration: configuration)
        modalPresentationStyle = .popover
        setPreferredContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissScreen()
        }
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.TooltipView.background
        popoverPresentationController?.backgroundColor = Colors.TooltipView.background
        popoverPresentationController?.permittedArrowDirections = .up
    }
    
    override func prepareLayout() {
        setupTooltipLabelLayout()
    }
}

extension TooltipViewController {
    private func setPreferredContentSize() {
        let tooltipFont = UIFont.font(withWeight: .semiBold(size: 14.0))
        let totalHorizontalInset = layout.current.horizontalInset * 4
        let height = tooltipText.height(withConstrained: UIScreen.main.bounds.width - totalHorizontalInset, font: tooltipFont)
        
        preferredContentSize = CGSize(
            width: UIScreen.main.bounds.width - layout.current.horizontalInset * 2,
            height: height + layout.current.verticalInset * 2
        )
    }
}

extension TooltipViewController {
    func setSourceView(_ sourceView: UIView) {
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceView.bounds
    }
}

extension TooltipViewController {
    private func setupTooltipLabelLayout() {
        view.addSubview(tooltipLabel)
        
        tooltipLabel.setContentHuggingPriority(.required, for: .horizontal)
        tooltipLabel.setContentHuggingPriority(.required, for: .vertical)
        tooltipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        tooltipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        tooltipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.safeEqualToTop(of: self).inset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension TooltipViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 12.0
    }
}

extension Colors {
    fileprivate enum TooltipView {
        static let background = color("tooltipBackground")
    }
}
