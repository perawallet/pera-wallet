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

package com.algorand.android.modules.banner.ui.usecase

import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.modules.banner.ui.model.BannerPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class BannerPreviewUseCase @Inject constructor() {

    fun getInitialStatePreview() = BannerPreview(
        isLoading = true,
        reloadPageEvent = Event(Unit)
    )

    fun requestLoadHomepage(previousState: BannerPreview) = previousState.copy(
        isLoading = true,
        reloadPageEvent = Event(Unit)
    )

    fun onPreviousNavButtonClicked(previousState: BannerPreview) = previousState.copy(
        webViewGoBackEvent = Event(Unit)
    )

    fun onNextNavButtonClicked(previousState: BannerPreview) = previousState.copy(
        webViewGoForwardEvent = Event(Unit)
    )

    fun onPageRequested(previousState: BannerPreview) = previousState.copy(
        isLoading = true
    )

    fun onPageFinished(previousState: BannerPreview) = previousState.copy(
        isLoading = false
    )

    fun onError(previousState: BannerPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.NO_CONNECTION)
    )

    fun onPageUrlChanged(previousState: BannerPreview) = previousState.copy(
        pageUrlChangedEvent = Event(Unit)
    )

    fun onHttpError(previousState: BannerPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.HTTP_ERROR)
    )
}
