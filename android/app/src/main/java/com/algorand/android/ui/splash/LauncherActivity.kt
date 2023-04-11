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
import com.algorand.android.MainActivity.Companion.DEEPLINK_KEY
import com.algorand.android.core.BaseActivity
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

        fun newIntentWithDeeplink(context: Context, deeplink: String): Intent {
            return Intent(context, LauncherActivity::class.java).apply {
                putExtra(DEEPLINK_KEY, deeplink)
            }
        }
    }
}
