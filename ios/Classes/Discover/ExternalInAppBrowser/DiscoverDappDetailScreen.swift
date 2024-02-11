// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   DiscoverDappDetailScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class DiscoverDappDetailScreen: DiscoverExternalInAppBrowserScreen {
    private let dappParameters: DiscoverDappParamaters
    private lazy var favoriteButton = makeFavoriteButton()
    private lazy var favoriteDapps = createFavoriteDapps()

    init(dappParameters: DiscoverDappParamaters, configuration: ViewControllerConfiguration) {
        self.dappParameters = dappParameters
        super.init(destination: .url(dappParameters.url), configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        bindNavigationTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recordAnalyticsEvent()
        addFavoriteAction()
    }

    override func updateToolbarActionsForLoading() {
        super.updateToolbarActionsForLoading()

        if shouldAllowFavoriteAction() {
            updateFavoriteActionForLoading()
        }
    }

    override func updateToolbarActionsForURL() {
        super.updateToolbarActionsForURL()

        if shouldAllowFavoriteAction() {
            updateFavouriteActionForURL()
        }
    }

    override func updateToolbarActionsForError() {
        super.updateToolbarActionsForError()

        if shouldAllowFavoriteAction() {
            updateFavoriteActionForError()
        }
    }
}

// MARK: Navigation
extension DiscoverDappDetailScreen {
    private func bindNavigationTitle() {
        navigationTitleView.bindData(
            DiscoverExternalInAppBrowserNavigationViewModel(dappParameters)
        )
    }
}

// MARK: Favorite Dapp
extension DiscoverDappDetailScreen {
    private func addFavoriteAction() {
        guard var items = toolbar.items else { return }

        if shouldAllowFavoriteAction() {
            items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            items.append( favoriteButton )
        }

        toolbar.items = items
    }
    @objc
    private func didTapFavorite() {
        guard let url = createURLToAddFavorites() else {
            return
        }

        let dappDetails = DiscoverFavouriteDappDetails(
            name: webView.title,
            url: url
        )

        if isFavorite(url) {
            removeFromFavorites(url: url, dapp: dappDetails)
        } else {
            addToFavorites(url: url, dapp: dappDetails)
        }
    }

    private func makeFavoriteButton() -> UIBarButtonItem {
        let button = MacaroonUIKit.Button()

        button.snp.makeConstraints {
            $0.fitToSize((40, 40))
        }
        button.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)

        return UIBarButtonItem(customView: button)
    }

    private func createFavoriteDapps() -> Set<URL> {
        return dappParameters.favorites?.reduce(into: Set<URL>(), {
            guard let url = URL(string: $1.url) else { return }
            $0.insert(url)
        }) ?? []
    }

    private func shouldAllowFavoriteAction() -> Bool {
        return dappParameters.favorites != nil
    }

    private func createURLToAddFavorites() -> URL? {
        guard let currentUrl = webView.url else {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = currentUrl.scheme
        urlComponents.host = currentUrl.host

        return urlComponents.url
    }

    private func isFavorite(_ url: URL) -> Bool {
        return favoriteDapps.contains(url)
    }

    private func addToFavorites(
        url: URL,
        dapp: DiscoverFavouriteDappDetails
    ) {
        if hasExceededFavouritesLimit() {
            self.bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "discover-error-favorites-max-limit".localized
            )
            return
        }

        favoriteDapps.insert(url)
        setFavoriteActionSelected(true)
        eventHandler?(.addToFavorites(dapp))
    }

    private func hasExceededFavouritesLimit() -> Bool {
        return favoriteDapps.count >= 100
    }

    private func removeFromFavorites(
        url: URL,
        dapp: DiscoverFavouriteDappDetails
    ) {
        favoriteDapps.remove(url)
        setFavoriteActionSelected(false)
        eventHandler?(.removeFromFavorites(dapp))
    }

    private func updateFavoriteActionForLoading() {
        updateFavoriteStatusForURL()
        favoriteButton.isEnabled = false
    }

    private func updateFavouriteActionForURL() {
        updateFavoriteStatusForURL()
        favoriteButton.isEnabled = true
    }

    private func updateFavoriteActionForError() {
        setFavoriteActionSelected(false)
        favoriteButton.isEnabled = false
    }

    private func updateFavoriteStatusForURL() {
        let url = createURLToAddFavorites()
        let isSelected = url.unwrap(isFavorite) ?? false
        setFavoriteActionSelected(isSelected)
    }

    private func setFavoriteActionSelected(_ selected: Bool) {
        let actionView = favoriteButton.customView as? UIButton
        let image = (selected ? "icon-favourite-filled" : "icon-favourite").uiImage
        actionView?.setImage(
            image,
            for: .normal
        )
    }
}

// MARK: Analytics
extension DiscoverDappDetailScreen {
    private func recordAnalyticsEvent() {
        self.analytics.track(.discoverDappDetail(dappParameters: dappParameters))
    }
}
