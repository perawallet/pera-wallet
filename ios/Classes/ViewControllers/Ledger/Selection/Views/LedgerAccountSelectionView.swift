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
//  LedgerAccountSelectionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class LedgerAccountSelectionView: View {
    weak var delegate: LedgerAccountSelectionViewDelegate?

    private lazy var theme = LedgerAccountSelectionViewTheme()
    private lazy var errorView = NoContentWithActionView()

    private lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.collectionViewMinimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.allowsMultipleSelection = isMultiSelect
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.listContentInset)
        collectionView.register(SingleSelectionLedgerAccountCell.self)
        collectionView.register(MultipleSelectionLedgerAccountCell.self)
        return collectionView
    }()

    private lazy var verticalStackView = UIStackView()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var verifyButtonContainer = UIView()
    private lazy var verifyButton = Button()
    
    private let isMultiSelect: Bool

    private var isLayoutFinalized = false
    
    init(isMultiSelect: Bool) {
        self.isMultiSelect = isMultiSelect
        super.init(frame: .zero)

        customize(theme)
        setListeners()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isLayoutFinalized {
            isLayoutFinalized = true

            addLinearGradient(theme)
        }
    }

    private func customize(_ theme: LedgerAccountSelectionViewTheme) {
        errorView.customize(NoContentWithActionViewCommonTheme())
        errorView.bindData(ListErrorViewModel())

        addVerticalStackView(theme)
        addAccountsCollectionView(theme)
        addVerifyButton(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        errorView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.ledgerAccountSelectionViewDidTryAgain(self)
        }

        verifyButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
}

extension LedgerAccountSelectionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.ledgerAccountSelectionViewDidAddAccount(self)
    }
}

extension LedgerAccountSelectionView {
    private func addVerticalStackView(_ theme: LedgerAccountSelectionViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.spacing = theme.verticalStackViewSpacing
        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
    }

    private func addImageView(_ theme: LedgerAccountSelectionViewTheme) {
        imageView.customizeAppearance(theme.image)

        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.setCustomSpacing(theme.titleLabelTopPadding, after: imageView)
    }

    private func addTitleLabel(_ theme: LedgerAccountSelectionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        verticalStackView.addArrangedSubview(titleLabel)
    }

    private func addDescriptionLabel(_ theme: LedgerAccountSelectionViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        verticalStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func addAccountsCollectionView(_ theme: LedgerAccountSelectionViewTheme) {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints {
            $0.top.equalTo(verticalStackView.snp.bottom).offset(theme.devicesListTopPadding)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addVerifyButton(_ theme: LedgerAccountSelectionViewTheme) {
        addSubview(verifyButtonContainer)
        verifyButtonContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.fitToHeight(theme.linearGradientHeight + safeAreaBottom)
        }
        
        verifyButton.customize(theme.verifyButtonTheme)

        verifyButtonContainer.addSubview(verifyButton)
        verifyButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }

    private func addLinearGradient(_ theme: LedgerAccountSelectionViewTheme) {
        let layer = CAGradientLayer()
        layer.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: bounds.width,
                height: theme.linearGradientHeight + safeAreaBottom
            )
        )

        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = Colors.Defaults.background.uiColor.cgColor

        layer.colors = [color0, color1]
        verifyButtonContainer.layer.insertSublayer(layer, at: 0)
    }
}

extension LedgerAccountSelectionView {
    func reloadData() {
        accountsCollectionView.reloadData()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        accountsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        accountsCollectionView.dataSource = dataSource
    }
    
    func setErrorState() {
        accountsCollectionView.contentState = .error(errorView)
    }
    
    func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
        return accountsCollectionView.indexPath(for: cell)
    }
    
    func setNormalState() {
        accountsCollectionView.contentState = .none
    }
    
    func setLoadingState() {
        accountsCollectionView.contentState = .loading
    }
    
    var selectedIndexes: [IndexPath] {
        return accountsCollectionView.indexPathsForSelectedItems ?? []
    }
}

extension LedgerAccountSelectionView: ViewModelBindable {
    func bindData(_ viewModel: LedgerAccountSelectionViewModel?) {
        if let title = viewModel?.accountCount {
            title.load(in: titleLabel)
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = nil
        }

        if let description = viewModel?.detail {
            description.load(in: descriptionLabel)
        } else {
            descriptionLabel.attributedText = nil
            descriptionLabel.text = nil
        }

        verifyButton.isEnabled = (viewModel?.isEnabled).ifNil(false)

        if let buttonText = viewModel?.buttonText {
            verifyButton.bindData(ButtonCommonViewModel(title: buttonText))
        } else {
            verifyButton.bindData(nil)
        }
    }
}

protocol LedgerAccountSelectionViewDelegate: AnyObject {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView)
    func ledgerAccountSelectionViewDidTryAgain(_ ledgerAccountSelectionView: LedgerAccountSelectionView)
}
