package com.algorand.android.modules.walletconnectfallbackbrowser.ui.mapper

import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserSelectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class FallbackBrowserSelectionPreviewMapper @Inject constructor() {

    fun mapToInitialLoadingState(): FallbackBrowserSelectionPreview {
        return FallbackBrowserSelectionPreview(
            isLoading = true,
            fallbackBrowserList = null,
            noBrowserFoundEvent = null,
            singleBrowserFoundEvent = null
        )
    }

    fun mapToSuccessState(browserList: List<FallbackBrowserListItem>): FallbackBrowserSelectionPreview {
        return FallbackBrowserSelectionPreview(
            isLoading = false,
            fallbackBrowserList = browserList,
            noBrowserFoundEvent = null,
            singleBrowserFoundEvent = null
        )
    }

    fun mapToNoBrowserFoundErrorState(): FallbackBrowserSelectionPreview {
        return FallbackBrowserSelectionPreview(
            isLoading = false,
            fallbackBrowserList = null,
            noBrowserFoundEvent = Event(Unit),
            singleBrowserFoundEvent = null
        )
    }

    fun mapToSingleBrowserFoundState(browser: FallbackBrowserListItem): FallbackBrowserSelectionPreview {
        return FallbackBrowserSelectionPreview(
            isLoading = false,
            fallbackBrowserList = null,
            noBrowserFoundEvent = null,
            singleBrowserFoundEvent = Event(browser)
        )
    }
}
