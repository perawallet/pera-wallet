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

package com.algorand.android.modules.assets.profile.detail.ui.adapter

import androidx.fragment.app.Fragment
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.algorand.android.R
import com.algorand.android.modules.assets.profile.about.ui.AssetAboutFragment
import com.algorand.android.modules.assets.profile.activity.ui.AssetActivityFragment
import com.algorand.android.modules.assets.profile.detail.ui.model.AssetDetailPagerAdapterItem

class AssetDetailPagerAdapter(
    accountAddress: String,
    assetId: Long,
    fragment: Fragment
) : FragmentStateAdapter(fragment) {

    private val pagerItemList = listOf(
        AssetDetailPagerAdapterItem(
            fragmentInstance = AssetActivityFragment.newInstance(accountAddress = accountAddress, assetId = assetId),
            titleResId = R.string.activity
        ),
        AssetDetailPagerAdapterItem(
            fragmentInstance = AssetAboutFragment.newInstance(assetId = assetId, isBottomPaddingNeeded = false),
            titleResId = R.string.about
        )
    )

    override fun getItemCount() = pagerItemList.size

    override fun createFragment(position: Int): Fragment {
        return pagerItemList.getOrNull(position)?.fragmentInstance ?: throw Exception("$logTag unknown tab")
    }

    fun getItem(position: Int): AssetDetailPagerAdapterItem? {
        return pagerItemList.getOrNull(position)
    }

    companion object {
        private val logTag = AssetDetailPagerAdapter::class.simpleName
    }
}
