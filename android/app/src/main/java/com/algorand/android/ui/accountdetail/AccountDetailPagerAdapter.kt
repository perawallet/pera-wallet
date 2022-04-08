/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.accountdetail

import androidx.fragment.app.Fragment
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.algorand.android.ui.accountdetail.assets.AccountAssetsFragment
import com.algorand.android.ui.accountdetail.history.AccountHistoryFragment
import com.algorand.android.ui.accountdetail.nfts.AccountCollectiblesFragment

class AccountDetailPagerAdapter(
    fragment: Fragment,
    private val accountPublicKey: String
) : FragmentStateAdapter(fragment) {

    override fun getItemCount() = 3

    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> AccountAssetsFragment.newInstance(accountPublicKey)
            1 -> AccountCollectiblesFragment.newInstance(accountPublicKey)
            2 -> AccountHistoryFragment.newInstance(accountPublicKey)
            else -> throw Exception("Unknown Account Detail Tab")
        }
    }
}
