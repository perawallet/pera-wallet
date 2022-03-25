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

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.annotation.LayoutRes
import androidx.navigation.NavController
import com.algorand.android.CoreMainActivity
import com.algorand.android.R

abstract class BaseBottomBarFragment(@LayoutRes private val layoutResId: Int) : DaggerBaseFragment(layoutResId) {

    private val navController: NavController?
        get() = (activity as? CoreMainActivity)?.navController

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            onBackButtonPressed()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    private fun onBackButtonPressed() {
        val currentDestination = navController?.currentDestination
        if (currentDestination?.id != ACCOUNTS_FRAGMENT_NAVIGATION_ID) {
            setAccountTabOnBottomNavigationBar()
        } else {
            activity?.finish()
        }
    }

    private fun setAccountTabOnBottomNavigationBar() {
        (activity as? CoreMainActivity)?.setBottomNavigationBarSelectedItem(ACCOUNTS_FRAGMENT_NAVIGATION_ID)
    }

    companion object {
        private const val ACCOUNTS_FRAGMENT_NAVIGATION_ID = R.id.accountsFragment
    }
}
