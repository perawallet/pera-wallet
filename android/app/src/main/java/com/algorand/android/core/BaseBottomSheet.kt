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

import android.app.Dialog
import android.os.Bundle
import android.view.ContextThemeWrapper
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.annotation.LayoutRes
import androidx.navigation.NavDirections
import com.algorand.android.CoreMainActivity
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.notification.domain.model.NotificationMetadata
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.toShortenedAddress
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

// TODO: 5.08.2022 Having a default value in abstract class constructor may create Hilt crashes.
// TODO: 5.08.2022 A work around is to provide all fields again in child classes which makes having default parameter
// TODO: 5.08.2022 completely non-sense. It would be good to investigate
abstract class BaseBottomSheet(@LayoutRes private val layoutResId: Int) : BottomSheetDialogFragment() {

    open val fullPageNeeded: Boolean = false

    private val bottomSheetTag: String = this::class.simpleName.orEmpty()
    protected val baseActivityTag: String
        get() = (activity as? BaseActivity)?.getTag().orEmpty()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val contextThemeWrapper = ContextThemeWrapper(activity, R.style.AppTheme)
        return inflater.cloneInContext(contextThemeWrapper).inflate(layoutResId, container, false)
    }

    override fun getTheme() = R.style.BottomSheetDialogTheme_Primary

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState)
        dialog.window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE) // resizes acc. to keyboard
        return dialog
    }

    override fun onStart() {
        super.onStart()
        val bottomSheet = getBottomSheetFrameLayout()
        if (bottomSheet != null) {
            with(BottomSheetBehavior.from(bottomSheet)) {
                skipCollapsed = true
                state = BottomSheetBehavior.STATE_EXPANDED
            }
            if (fullPageNeeded) {
                makeBottomSheetFullPage(bottomSheet)
            }
        }
    }

    override fun onPause() {
        super.onPause()
        removeAlertsWithTag(bottomSheetTag)
    }

    protected fun setDraggableEnabled(isEnabled: Boolean) {
        val bottomSheet = getBottomSheetFrameLayout() ?: return
        BottomSheetBehavior.from(bottomSheet).isDraggable = isEnabled
    }

    protected fun showTopToast(title: String? = null, description: String? = null) {
        (activity as? BaseActivity)?.showTopToast(title, description)
    }

    private fun getBottomSheetFrameLayout(): FrameLayout? {
        return dialog?.findViewById(com.google.android.material.R.id.design_bottom_sheet) as? FrameLayout?
    }

    private fun makeBottomSheetFullPage(bottomSheetLayout: FrameLayout) {
        val fullExceptedHeight = activity?.resources?.displayMetrics?.heightPixels?.times(FULL_PAGE_RATIO)
        if (fullExceptedHeight != null) {
            if (bottomSheetLayout.layoutParams.height != fullExceptedHeight.toInt()) {
                bottomSheetLayout.layoutParams.height = fullExceptedHeight.toInt()
                bottomSheetLayout.requestLayout()
            }
        }
    }

    fun nav(directions: NavDirections) {
        (activity as? CoreMainActivity)?.nav(directions)
    }

    fun navBack() {
        (activity as? CoreMainActivity)?.navBack()
    }

    fun showGlobalError(
        errorMessage: CharSequence?,
        title: String? = null,
        tag: String = bottomSheetTag
    ) {
        (activity as? MainActivity)?.showGlobalError(errorMessage, title, tag)
    }

    fun showAlertSuccess(
        title: String,
        successMessage: String? = null,
        tag: String = bottomSheetTag
    ) {
        (activity as? MainActivity)?.showAlertSuccess(title, successMessage, tag)
    }

    fun showForegroundNotification(
        notificationMetadata: NotificationMetadata,
        tag: String = bottomSheetTag
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

    private fun removeAlertsWithTag(tag: String) {
        (activity as? MainActivity)?.removeAlertsWithTag(tag)
    }

    companion object {
        private const val FULL_PAGE_RATIO = 0.92
    }
}
