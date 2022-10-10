package com.algorand.android.modules.walletconnect.transactionrequest.ui.mapper

import com.algorand.android.modules.walletconnect.transactionrequest.ui.model.WalletConnectTransactionRequestPreview
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectTransactionRequestPreviewMapper @Inject constructor() {

    fun mapToInitialPreview(peerMetaName: String): WalletConnectTransactionRequestPreview {
        return WalletConnectTransactionRequestPreview(
            peerMetaName = peerMetaName,
            multipleFallbackBrowserFoundEvent = null,
            singleFallbackBrowserFoundEvent = null,
            noFallbackBrowserFoundEvent = null
        )
    }

    fun mapToMultipleFallbackBrowserFoundState(
        preview: WalletConnectTransactionRequestPreview,
        browserList: List<FallbackBrowserListItem>
    ): WalletConnectTransactionRequestPreview {
        return preview.copy(
            multipleFallbackBrowserFoundEvent = Event(browserList)
        )
    }

    fun mapToSingleFallbackBrowserFoundState(
        preview: WalletConnectTransactionRequestPreview,
        browser: FallbackBrowserListItem
    ): WalletConnectTransactionRequestPreview {
        return preview.copy(
            singleFallbackBrowserFoundEvent = Event(browser)
        )
    }

    fun mapToNoFallbackBrowserFoundState(
        preview: WalletConnectTransactionRequestPreview
    ): WalletConnectTransactionRequestPreview {
        return preview.copy(
            noFallbackBrowserFoundEvent = Event(Unit)
        )
    }
}
