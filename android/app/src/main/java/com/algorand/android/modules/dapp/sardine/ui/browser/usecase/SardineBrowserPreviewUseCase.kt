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

package com.algorand.android.modules.dapp.sardine.ui.browser.usecase

import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.modules.dapp.sardine.ui.browser.model.SardineBrowserPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.getBaseUrlOrNull
import javax.inject.Inject

class SardineBrowserPreviewUseCase @Inject constructor() {

    fun getInitialStatePreview(
        title: String,
        url: String
    ) = SardineBrowserPreview(
        isLoading = true,
        reloadPageEvent = Event(Unit),
        title = title,
        url = url,
        toolbarSubtitle = getBaseUrlOrNull(url) ?: emptyString()
    )

    fun requestLoadHomepage(
        previousState: SardineBrowserPreview,
        title: String,
        url: String
    ) = previousState.copy(
        isLoading = true,
        reloadPageEvent = Event(Unit),
        title = title,
        url = url
    )

    fun onPreviousNavButtonClicked(previousState: SardineBrowserPreview) = previousState.copy(
        webViewGoBackEvent = Event(Unit)
    )

    fun onNextNavButtonClicked(previousState: SardineBrowserPreview) = previousState.copy(
        webViewGoForwardEvent = Event(Unit)
    )

    fun onPageFinished(
        previousState: SardineBrowserPreview,
        title: String?,
        url: String?
    ) = previousState.copy(
        isLoading = false,
        title = title ?: previousState.title,
        url = url ?: previousState.url,
        toolbarSubtitle = getBaseUrlOrNull(url) ?: previousState.toolbarSubtitle
    )

    fun onError(previousState: SardineBrowserPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.NO_CONNECTION)
    )

    fun onPageUrlChanged(previousState: SardineBrowserPreview) = previousState.copy(
        pageUrlChangedEvent = Event(Unit)
    )

    fun onHttpError(previousState: SardineBrowserPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.HTTP_ERROR)
    )
}
