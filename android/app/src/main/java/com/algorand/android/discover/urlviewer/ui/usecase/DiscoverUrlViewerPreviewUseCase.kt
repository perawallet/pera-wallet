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

package com.algorand.android.discover.urlviewer.ui.usecase

import android.content.SharedPreferences
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.home.domain.model.DappInfo
import com.algorand.android.discover.home.domain.model.UrlElement
import com.algorand.android.discover.home.ui.mapper.DiscoverDappFavoritesMapper
import com.algorand.android.discover.urlviewer.ui.DiscoverUrlViewerFragmentDirections
import com.algorand.android.discover.urlviewer.ui.model.DiscoverUrlViewerPreview
import com.algorand.android.discover.utils.isValidDiscoverURL
import com.algorand.android.utils.Event
import com.algorand.android.utils.preference.getSavedThemePreference
import com.google.gson.Gson
import javax.inject.Inject

class DiscoverUrlViewerPreviewUseCase @Inject constructor(
    private val sharedPreferences: SharedPreferences,
    private val discoverDappFavoritesMapper: DiscoverDappFavoritesMapper,
    private val gson: Gson
) {

    fun getInitialStatePreview(
        url: String
    ) = DiscoverUrlViewerPreview(
        themePreference = sharedPreferences.getSavedThemePreference(),
        isLoading = true,
        reloadPageEvent = Event(Unit),
        url = url
    )

    fun onPageRequestedShouldOverrideUrlLoading(previousState: DiscoverUrlViewerPreview) = previousState.copy(
        isLoading = true
    )

    fun onPageFinished(
        previousState: DiscoverUrlViewerPreview,
        url: String?
    ) = previousState.copy(
        isLoading = false,
        url = url ?: previousState.url,
    )

    fun onError(previousState: DiscoverUrlViewerPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.NO_CONNECTION)
    )

    fun onHttpError(previousState: DiscoverUrlViewerPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.HTTP_ERROR)
    )

    fun pushNewScreen(
        data: String,
        previousState: DiscoverUrlViewerPreview
    ): DiscoverUrlViewerPreview {
        val newUrl = gson.fromJson(data, UrlElement::class.java).url
        return if (newUrl?.let { isValidDiscoverURL(it) } == true) {
            previousState.copy(
                isLoading = true,
                reloadPageEvent = Event(Unit),
                url = newUrl
            )
        } else {
            previousState
        }
    }

    fun pushDappViewerScreen(
        data: String,
        previousState: DiscoverUrlViewerPreview
    ): DiscoverUrlViewerPreview {
        val dappInfo = gson.fromJson(data, DappInfo::class.java)
        return if (!dappInfo.url.isNullOrBlank()) {
            previousState.copy(
                dappViewerScreenRequestEvent = Event(
                    DiscoverUrlViewerFragmentDirections
                        .actionDiscoverUrlViewerFragmentToDiscoverDappNavigation(
                            dappUrl = dappInfo.url,
                            dappTitle = dappInfo.name.orEmpty(),
                            favorites = dappInfo.favorites?.map {
                                discoverDappFavoritesMapper.mapToDappFavoriteElement(it)
                            }?.toTypedArray() ?: emptyArray()
                        )
                )
            )
        } else {
            previousState
        }
    }
}
