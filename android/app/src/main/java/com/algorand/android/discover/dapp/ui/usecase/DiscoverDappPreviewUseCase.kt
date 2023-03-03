/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.discover.dapp.ui.usecase

import android.content.SharedPreferences
import com.algorand.android.discover.common.ui.model.DappFavoriteElement
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.dapp.ui.model.DiscoverDappPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.preference.getSavedThemePreference
import javax.inject.Inject

class DiscoverDappPreviewUseCase @Inject constructor(
    private val sharedPreferences: SharedPreferences
) {

    fun getInitialStatePreview(
        dappUrl: String,
        dappTitle: String,
        favorites: List<DappFavoriteElement>
    ) = DiscoverDappPreview(
        themePreference = sharedPreferences.getSavedThemePreference(),
        isLoading = true,
        reloadPageEvent = Event(Unit),
        dappUrl = dappUrl,
        dappTitle = dappTitle,
        favorites = favorites,
        isFavorite = favorites.any { it.isSameUrl(dappUrl) }
    )

    fun requestLoadHomepage(previousState: DiscoverDappPreview) = previousState.copy(
        isLoading = true,
        reloadPageEvent = Event(Unit)
    )

    fun onPreviousNavButtonClicked(previousState: DiscoverDappPreview) = previousState.copy(
        webViewGoBackEvent = Event(Unit)
    )

    fun onNextNavButtonClicked(previousState: DiscoverDappPreview) = previousState.copy(
        webViewGoForwardEvent = Event(Unit)
    )

    fun onFavoritesNavButtonClicked(previousState: DiscoverDappPreview): DiscoverDappPreview {
        val newFavorites = addOrRemoveCurrentFromFavorites(previousState)
        return previousState.copy(
            favoritingEvent = Event(DappFavoriteElement(previousState.dappTitle, previousState.dappUrl)),
            favorites = newFavorites,
            isFavorite = newFavorites.any {
                it.isSameUrl(previousState.dappUrl)
            }
        )
    }

    fun onPageRequestedShouldOverrideUrlLoading(previousState: DiscoverDappPreview) = previousState.copy(
        isLoading = true
    )

    fun onPageFinished(
        previousState: DiscoverDappPreview,
        title: String?,
        url: String?
    ) = previousState.copy(
        isLoading = false,
        dappTitle = title ?: previousState.dappTitle,
        dappUrl = url ?: previousState.dappUrl,
    )

    fun onError(previousState: DiscoverDappPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.NO_CONNECTION)
    )

    fun onPageUrlChanged(previousState: DiscoverDappPreview) = previousState.copy(
        pageUrlChangedEvent = Event(Unit)
    )

    fun onHttpError(previousState: DiscoverDappPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.HTTP_ERROR)
    )

    private fun addOrRemoveCurrentFromFavorites(previousState: DiscoverDappPreview): MutableList<DappFavoriteElement> {
        val newFavorites = previousState.favorites.toMutableList()
        val alreadyFavorited = newFavorites.firstOrNull {
            it.isSameUrl(previousState.dappUrl)
        }
        if (alreadyFavorited == null) {
            newFavorites.add(DappFavoriteElement(previousState.dappTitle, previousState.dappUrl))
        } else {
            newFavorites.remove(alreadyFavorited)
        }
        return newFavorites
    }
}
