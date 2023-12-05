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

package com.algorand.android.modules.accountdetail.assets.ui.model

import com.algorand.android.R

sealed class QuickActionItem {

    abstract val iconResId: Int
    abstract val labelResId: Int

    object BuySellButton : QuickActionItem() {
        override val iconResId: Int = R.drawable.ic_buy_sell_quick_actions
        override val labelResId: Int = R.string.buy_sell
    }

    data class SwapButton(val isSelected: Boolean) : QuickActionItem() {
        override val iconResId: Int = R.drawable.ic_swap_quick_actions
        override val labelResId: Int = R.string.swap
    }

    object SendButton : QuickActionItem() {
        override val iconResId: Int = R.drawable.ic_send_helper_button_bg_ghost
        override val labelResId: Int = R.string.send
    }

    object MoreButton : QuickActionItem() {
        override val iconResId: Int = R.drawable.ic_more_helper_button
        override val labelResId: Int = R.string.more
    }

    object CopyAddressButton : QuickActionItem() {
        override val iconResId: Int = R.drawable.ic_copy_address_helper_button
        override val labelResId: Int = R.string.copy_address
    }

    object ShowAddressButton : QuickActionItem() {
        override val iconResId: Int = R.drawable.ic_qr_helper_button_bg_ghost
        override val labelResId: Int = R.string.show_address
    }
}
