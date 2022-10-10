package com.algorand.android.modules.walletconnectfallbackbrowser.ui.mapper

import com.algorand.android.modules.walletconnectfallbackbrowser.ui.decider.FallbackBrowserItemIconResIdDecider
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.decider.FallbackBrowserItemNameDecider
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import com.algorand.android.modules.walletconnectfallbackbrowser.domain.model.WalletConnectFallbackBrowser
import javax.inject.Inject

class WalletConnectFallbackBrowserItemMapper @Inject constructor(
    private val fallbackBrowserItemIconResIdDecider: FallbackBrowserItemIconResIdDecider,
    private val fallbackBrowserItemNameDecider: FallbackBrowserItemNameDecider
) {

    fun mapTo(walletConnectFallbackBrowser: WalletConnectFallbackBrowser): FallbackBrowserListItem {
        return FallbackBrowserListItem(
            iconDrawableResId = fallbackBrowserItemIconResIdDecider.provideFallbackBrowserItemIconResId(
                walletConnectFallbackBrowser
            ),
            nameStringResId = fallbackBrowserItemNameDecider.provideFallbackBrowserItemNameResId(
                walletConnectFallbackBrowser
            ),
            packageName = walletConnectFallbackBrowser.packageName
        )
    }
}
