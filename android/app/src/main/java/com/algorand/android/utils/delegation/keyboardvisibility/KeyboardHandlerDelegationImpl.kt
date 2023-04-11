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

package com.algorand.android.utils.delegation.keyboardvisibility

import android.graphics.Rect
import android.view.View
import android.view.ViewTreeObserver
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Observer
import com.algorand.android.core.BaseFragment
import kotlin.properties.Delegates

class KeyboardHandlerDelegationImpl : KeyboardHandlerDelegation, ViewTreeObserver.OnGlobalLayoutListener {

    private var baseFragment: BaseFragment? = null
    private var onKeyboardClosedListener: OnKeyboardClosedListener? = null
    private var onKeyboardOpenedListener: OnKeyboardOpenedListener? = null

    override var isKeyboardVisible: Boolean by Delegates.observable(false) { _, _, newValue ->
        if (newValue) onKeyboardOpenedListener?.onKeyboardOpened() else onKeyboardClosedListener?.onKeyboardClosed()
    }

    private val rootVew: View?
        get() = baseFragment?.view

    override fun registerKeyboardHandlerDelegation(
        baseFragment: BaseFragment,
        onKeyboardClosedListener: OnKeyboardClosedListener?,
        onKeyboardOpenedListener: OnKeyboardOpenedListener?
    ) {
        this.baseFragment = baseFragment
        this.onKeyboardClosedListener = onKeyboardClosedListener
        this.onKeyboardOpenedListener = onKeyboardOpenedListener
        baseFragment.lifecycle.addObserver(fragmentLifecycleObserver)
    }

    private val fragmentLifecycleObserver = object : DefaultLifecycleObserver {
        override fun onCreate(owner: LifecycleOwner) {
            baseFragment?.viewLifecycleOwnerLiveData?.observeForever(viewLifecycleOwnerLiveDataObserver)
        }

        override fun onDestroy(owner: LifecycleOwner) {
            baseFragment?.viewLifecycleOwnerLiveData?.removeObserver(viewLifecycleOwnerLiveDataObserver)
        }
    }

    private val viewLifecycleOwnerLiveDataObserver = Observer<LifecycleOwner?> { viewLifecycleOwner ->
        viewLifecycleOwner?.lifecycle?.addObserver(viewLifecycleObserver)
    }

    private val viewLifecycleObserver = object : DefaultLifecycleObserver {
        override fun onResume(owner: LifecycleOwner) {
            super.onResume(owner)
            rootVew?.viewTreeObserver?.addOnGlobalLayoutListener(this@KeyboardHandlerDelegationImpl)
        }

        override fun onPause(owner: LifecycleOwner) {
            super.onPause(owner)
            rootVew?.viewTreeObserver?.removeOnGlobalLayoutListener(this@KeyboardHandlerDelegationImpl)
        }
    }

    override fun onGlobalLayout() {
        rootVew?.run {
            val windowVisibleDisplayFrameRect = Rect().apply { rootView.getWindowVisibleDisplayFrame(this) }
            val screenHeight = rootView.height
            val keypadHeight = screenHeight - windowVisibleDisplayFrameRect.bottom
            val isKeyboardVisibleNow = keypadHeight > screenHeight * MINIMUM_KEYBOARD_SCREEN_HEIGHT_RATIO
            if (isKeyboardVisibleNow != isKeyboardVisible) {
                isKeyboardVisible = isKeyboardVisibleNow
            }
        }
    }

    fun interface OnKeyboardClosedListener {
        fun onKeyboardClosed()
    }

    fun interface OnKeyboardOpenedListener {
        fun onKeyboardOpened()
    }

    companion object {
        private const val MINIMUM_KEYBOARD_SCREEN_HEIGHT_RATIO = 0.15
    }
}
