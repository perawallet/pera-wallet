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

package com.algorand.android.core

import android.os.Bundle
import android.view.View
import androidx.annotation.LayoutRes
import androidx.fragment.app.Fragment
import androidx.navigation.NavDirections
import androidx.navigation.fragment.FragmentNavigator
import com.algorand.android.CoreMainActivity
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.customviews.toolbar.CustomToolbar
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.notification.domain.model.NotificationMetadata
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.toShortenedAddress

abstract class BaseFragment(
    @LayoutRes private val layoutResId: Int,
) : Fragment(layoutResId) {

    abstract val fragmentConfiguration: FragmentConfiguration

    private val fragmentTag: String = this::class.simpleName.orEmpty()
    protected val baseActivityTag: String
        get() = (activity as? BaseActivity)?.getTag().orEmpty()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // When navigating from Fragment A->B, 'onViewCreated()' of B is called prior to 'onDestroyView()' of A
        // So, we remove previous fragment's click listeners on 'onViewCreated()' of B
        getAppToolbar()?.removeClickListeners()
        customizeFragment()
    }

    override fun onPause() {
        super.onPause()
        removeAlertsWithTag(fragmentTag)
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
        (activity as? CoreMainActivity)?.statusBarConfiguration = statusBarConfiguration
    }

    fun handleBottomBarVisibility(isBottomBarVisible: Boolean?) {
        if (isBottomBarVisible != null) {
            (activity as? CoreMainActivity)?.isBottomBarNavigationVisible = isBottomBarVisible
            if (isBottomBarVisible) {
                (activity as? CoreMainActivity)?.handleNavigationButtonsForChosenNetwork()
            }
        }
    }

    protected fun showTopToast(title: String? = null, description: String? = null) {
        (activity as? BaseActivity)?.showTopToast(title, description)
    }

    fun changeStatusBarConfiguration(statusBarConfiguration: StatusBarConfiguration) {
        setupStatusBar(statusBarConfiguration)
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

    fun nav(directions: NavDirections, extras: FragmentNavigator.Extras) {
        (activity as? CoreMainActivity)?.nav(directions, extras)
    }

    fun getAppToolbar(): CustomToolbar? {
        return (activity as? CoreMainActivity)?.getToolbar()
    }

    fun showGlobalError(
        errorMessage: CharSequence?,
        title: String? = null,
        tag: String = fragmentTag
    ) {
        (activity as? MainActivity)?.showGlobalError(errorMessage, title, tag)
    }

    fun showAlertSuccess(
        title: String,
        successMessage: String? = null,
        tag: String = fragmentTag
    ) {
        (activity as? MainActivity)?.showAlertSuccess(title, successMessage, tag)
    }

    fun showForegroundNotification(
        notificationMetadata: NotificationMetadata,
        tag: String = fragmentTag
    ) {
        (activity as? MainActivity)?.showForegroundNotification(notificationMetadata, tag)
    }

    fun showMaxAccountLimitExceededError() {
        (activity as? MainActivity)?.showMaxAccountLimitExceededError()
    }

    fun onAccountAddressCopied(accountAddress: String) {
        context?.copyToClipboard(textToCopy = accountAddress, showToast = false)
        showTopToast(getString(R.string.address_copied_to_clipboard), accountAddress.toShortenedAddress())
    }

    fun onAssetIdCopied(assetId: Long) {
        context?.copyToClipboard(textToCopy = assetId.toString(), showToast = false)
        showTopToast(getString(R.string.asset_id_copied_to_clipboard), assetId.toString())
    }

    private fun removeAlertsWithTag(tag: String) {
        (activity as? MainActivity)?.removeAlertsWithTag(tag)
    }

    protected fun handleWalletConnectUrl(url: String) {
        (activity as? MainActivity)?.handleWalletConnectUrl(url)
    }
}
