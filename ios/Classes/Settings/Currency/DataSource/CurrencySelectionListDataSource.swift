import Foundation
import UIKit

final class CurrencySelectionListDataSource: UICollectionViewDiffableDataSource<CurrencySelectionSection, CurrencySelectionItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let .currency(item):
                let cell =  collectionView.dequeue(
                    CurrencySelectionCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case let .empty(item):
                switch item {
                case .loading:
                    return collectionView.dequeue(
                        CurrencySelectionLoadingViewCell.self,
                        at: indexPath
                    )
                case let .noContent(noContentItem):
                    let cell = collectionView.dequeue(
                        NoContentCell.self,
                        at: indexPath
                    )
                    cell.bindData(noContentItem)
                    return cell
                }
            case .error:
                let cell = collectionView.dequeue(
                    NoContentWithActionCell.self,
                    at: indexPath
                )
                cell.bindData(ListErrorViewModel())
                return cell
            }
        }
        
        collectionView.register(CurrencySelectionCell.self)
        collectionView.register(CurrencySelectionLoadingViewCell.self)
        collectionView.register(NoContentCell.self)
        collectionView.register(NoContentWithActionCell.self)
    }
}
