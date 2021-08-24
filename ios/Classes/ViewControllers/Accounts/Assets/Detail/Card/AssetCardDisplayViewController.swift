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
//  AssetCardDisplayViewController.swift

import UIKit

class AssetCardDisplayViewController: BaseViewController {
    
    weak var delegate: AssetCardDisplayViewControllerDelegate?
    
    private lazy var rewardsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 472.0))
    )

    private lazy var analyticsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: UIScreen.main.bounds.height * 0.8))
    )

    private lazy var assetCardDisplayDataController: AssetCardDisplayDataController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return AssetCardDisplayDataController(api: api)
    }()

    private var account: Account
    private var selectedIndex: Int
    private var currency: Currency?
    
    private lazy var assetCardDisplayView = AssetCardDisplayView()

    private lazy var rewardCalculator: RewardCalculator = {
        guard let api = api else {
            fatalError("Api must be set before accessing reward calculator.")
        }

        return RewardCalculator(api: api, account: account)
    }()
    
    init(account: Account, selectedIndex: Int, configuration: ViewControllerConfiguration) {
        self.account = account
        self.selectedIndex = selectedIndex
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assetCardDisplayView.setNumberOfPages(account.assetDetails.count + 1)
        assetCardDisplayView.setCurrentPage(selectedIndex)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrency()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assetCardDisplayView.scrollTo(selectedIndex, animated: true)
    }
    
    override func prepareLayout() {
        setupAssetCardDisplayViewLayout()
    }
    
    override func linkInteractors() {
        assetCardDisplayView.setDelegate(self)
        assetCardDisplayView.setDataSource(self)
        rewardCalculator.delegate = self
    }
}

extension AssetCardDisplayViewController {
    private func setupAssetCardDisplayViewLayout() {
        view.addSubview(assetCardDisplayView)
        
        assetCardDisplayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetCardDisplayViewController {
    private func fetchCurrency() {
        assetCardDisplayDataController.getCurrency { response in
            if let currency = response {
                self.currency = currency
                self.assetCardDisplayView.reloadData(at: 0)
            }
        }
    }
}

extension AssetCardDisplayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.assetDetails.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlgosCardCell.reusableIdentifier,
                for: indexPath
            ) as? AlgosCardCell {
                cell.delegate = self
                cell.bind(AlgosCardViewModel(account: account, currency: currency))
                return cell
            }
        } else {
            if let assetDetail = account.assetDetails[safe: indexPath.item - 1],
               let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AssetCardCell.reusableIdentifier,
                for: indexPath
            ) as? AssetCardCell {
                cell.delegate = self
                cell.bind(AssetCardViewModel(account: account, assetDetail: assetDetail))
                return cell
            }
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension AssetCardDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: AssetCardDisplayView.CardViewConstants.cardWidth,
            height: AssetCardDisplayView.CardViewConstants.cardHeight
        )
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let pageWidth = AssetCardDisplayView.CardViewConstants.cardWidth + AssetCardDisplayView.CardViewConstants.cardSpacing
        var currentPage = CGFloat(assetCardDisplayView.currentPage)
        
        if velocity.x == 0 {
            currentPage = floor((targetContentOffset.pointee.x - pageWidth / 2) / pageWidth) + 1.0
        } else {
            currentPage = CGFloat(velocity.x > 0 ? assetCardDisplayView.currentPage + 1 : assetCardDisplayView.currentPage - 1)
            if currentPage < 0 {
                return
            }
            
            if currentPage > assetCardDisplayView.contentWidth / pageWidth {
                currentPage = ceil(assetCardDisplayView.contentWidth / pageWidth) - 1.0
            }
        }
        
        if currentPage >= CGFloat(assetCardDisplayView.numberOfPages) {
            return
        }
        
        selectedIndex = Int(currentPage)
        assetCardDisplayView.setCurrentPage(selectedIndex)
        targetContentOffset.pointee = CGPoint(x: currentPage * pageWidth, y: targetContentOffset.pointee.y)
        delegate?.assetCardDisplayViewController(self, didSelect: selectedIndex)
    }
}

extension AssetCardDisplayViewController: AlgosCardCellDelegate {
    func algosCardCellDidOpenRewardDetails(_ algosCardCell: AlgosCardCell) {
        open(
            .rewardDetail(account: account),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: rewardsModalPresenter
            )
        )
    }

    func algosCardCellDidOpenAnalytics(_ algosCardCell: AlgosCardCell) {
        guard let currency = currency else {
            return
        }

        open(
            .algoUSDAnalytics(account: account, currency: currency),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: analyticsModalPresenter
            )
        )
    }
}

extension AssetCardDisplayViewController: AssetCardCellDelegate {
    func assetCardCellDidCopyAssetId(_ assetCardCell: AssetCardCell) {
        guard let index = assetCardDisplayView.index(for: assetCardCell),
              let assetDetail = account.assetDetails[safe: index - 1] else {
            return
        }
        
        NotificationBanner.showInformation("asset-id-copied-title".localized)
        UIPasteboard.general.string = "\(assetDetail.id)"
    }
}

extension AssetCardDisplayViewController {
    func updateAccount(_ updatedAccount: Account) {
        account = updatedAccount
        rewardCalculator.updateAccount(updatedAccount)
        assetCardDisplayView.reloadData()
    }
}

extension AssetCardDisplayViewController: RewardCalculatorDelegate {
    func rewardCalculator(_ rewardCalculator: RewardCalculator, didCalculate rewards: Double) {
        guard let algosCardCell = assetCardDisplayView.item(at: 0) as? AlgosCardCell else {
            return
        }

        algosCardCell.bind(RewardCalculationViewModel(account: account, calculatedRewards: rewards, currency: currency))
    }
}

protocol AssetCardDisplayViewControllerDelegate: AnyObject {
    func assetCardDisplayViewController(_ assetCardDisplayViewController: AssetCardDisplayViewController, didSelect index: Int)
}
