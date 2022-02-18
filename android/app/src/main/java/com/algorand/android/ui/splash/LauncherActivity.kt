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

package com.algorand.android.ui.splash

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.MainActivity
import com.algorand.android.core.BaseActivity
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.ASSET_SUPPORT_REQUESTED_ASSET_KEY
import com.algorand.android.utils.ASSET_SUPPORT_REQUESTED_PUBLIC_KEY
import com.algorand.android.utils.SELECTED_ACCOUNT_KEY
import com.algorand.android.utils.SELECTED_ASSET_ID_KEY
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class LauncherActivity : BaseActivity() {

    private val launcherViewModel: LauncherViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initObservers()
    }

    private fun initObservers() {
        launcherViewModel.isNodeOperationFinished.observe(this, Observer {
            handleNavigation()
        })
    }

    private fun handleNavigation() {
        startActivity(MainActivity.newIntentWithDeeplinkOrNavigation(this, intent))
        this.overridePendingTransition(0, 0)
        finish()
    }

    companion object {
        fun newIntent(context: Context) = Intent(context, LauncherActivity::class.java)

        fun newIntentWithNewSelectedAccount(context: Context, publicKey: String?, assetId: Long?): Intent {
            return Intent(context, LauncherActivity::class.java).apply {
                putExtra(SELECTED_ACCOUNT_KEY, publicKey)
                putExtra(SELECTED_ASSET_ID_KEY, assetId ?: AssetInformation.ALGORAND_ID)
            }
        }

        fun newIntentWithAssetSupportRequest(
            context: Context,
            publicKey: String?,
            assetInformation: AssetInformation
        ): Intent {
            return Intent(context, LauncherActivity::class.java).apply {
                putExtra(ASSET_SUPPORT_REQUESTED_PUBLIC_KEY, publicKey)
                putExtra(ASSET_SUPPORT_REQUESTED_ASSET_KEY, assetInformation)
            }
        }
    }
}
