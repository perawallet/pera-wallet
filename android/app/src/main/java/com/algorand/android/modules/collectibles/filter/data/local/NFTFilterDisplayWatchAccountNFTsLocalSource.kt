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

package com.algorand.android.modules.collectibles.filter.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class NFTFilterDisplayWatchAccountNFTsLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Boolean>(sharedPreferences) {

    override val key: String = NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_KEY

    override fun getData(defaultValue: Boolean): Boolean {
        return sharedPref.getBoolean(NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_KEY, defaultValue)
    }

    override fun getDataOrNull(): Boolean? {
        return with(sharedPref) {
            if (contains(NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_KEY)) {
                getBoolean(
                    NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_KEY,
                    NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_DEFAULT_PREFERENCES
                )
            } else {
                null
            }
        }
    }

    override fun saveData(data: Boolean) {
        saveData {
            it.putBoolean(NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_KEY, data)
        }
    }

    companion object {
        const val NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_DEFAULT_PREFERENCES = true
        private const val NFT_FILTER_DISPLAY_WATCH_ACCOUNT_NFTS_KEY = "nft_filter_display_watch_account_nfts"
    }
}
