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
 */

package com.algorand.android.core

import androidx.lifecycle.LifecycleOwner
import androidx.navigation.NavController
import com.algorand.android.CoreMainActivity
import com.algorand.android.R

class BottomNavigationBackPressedDelegate : BackPressedControllerComponent {

    private lateinit var activity: CoreMainActivity

    private val navController: NavController
        get() = activity.navController

    override fun initBackPressedControllerComponent(activity: CoreMainActivity, lifecycleOwner: LifecycleOwner) {
        this.activity = activity
        activity.onBackPressedDispatcher.addCallback(lifecycleOwner, onBackPressedCallback)
    }

    override fun onBackButtonPressed() {
        val currentDestination = navController.currentDestination
        if (activity.isCoreActionsTabBarViewVisible()) {
            activity.hideCoreActionsTabBarView()
        } else {
            if (currentDestination?.id != ACCOUNTS_FRAGMENT_NAVIGATION_ID) {
                activity.setBottomNavigationBarSelectedItem(ACCOUNTS_FRAGMENT_NAVIGATION_ID)
            } else {
                activity.finish()
            }
        }
    }

    companion object {
        private const val ACCOUNTS_FRAGMENT_NAVIGATION_ID = R.id.accountsFragment
    }
}
