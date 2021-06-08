/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.core

import android.os.Build
import android.os.Bundle
import android.view.View
import androidx.annotation.LayoutRes
import androidx.fragment.app.Fragment
import androidx.navigation.NavDirections
import com.algorand.android.CoreMainActivity
import com.algorand.android.MainActivity
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.hideKeyboard

abstract class BaseFragment(
    @LayoutRes private val layoutResId: Int,
) : Fragment(layoutResId) {

    abstract val fragmentConfiguration: FragmentConfiguration

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        customizeFragment()
    }

    private fun customizeFragment() {
        with(fragmentConfiguration) {
            setupToolbar(toolbarConfiguration)
            setupStatusBar(statusBarConfiguration)
            handleBottomBarVisibility(isBottomBarNeeded)
        }
    }

    private fun setupToolbar(toolbarConfiguration: ToolbarConfiguration?) {
        getAppToolbar()?.configure(toolbarConfiguration)
    }

    private fun setupStatusBar(statusBarConfiguration: StatusBarConfiguration) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            (activity as? CoreMainActivity)?.statusBarConfiguration = statusBarConfiguration
        }
    }

    private fun handleBottomBarVisibility(isBottomBarVisible: Boolean?) {
        if (isBottomBarVisible != null) {
            (activity as? CoreMainActivity)?.isBottomBarNavigationVisible = isBottomBarVisible
        }
    }

    fun navBack() {
        (activity as? CoreMainActivity)?.navBack()
    }

    fun navBackHidingKeyboard() {
        view?.hideKeyboard()
        navBack()
    }

    fun nav(directions: NavDirections) {
        (activity as? CoreMainActivity)?.nav(directions)
    }

    fun getAppToolbar(): CustomToolbar? {
        return (activity as? CoreMainActivity)?.getToolbar()
    }

    fun showGlobalError(errorMessage: CharSequence?, title: String? = null) {
        (activity as? MainActivity)?.showGlobalError(errorMessage, title)
    }
}
