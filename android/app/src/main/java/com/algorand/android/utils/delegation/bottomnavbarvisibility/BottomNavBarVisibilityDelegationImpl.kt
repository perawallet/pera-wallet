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

package com.algorand.android.utils.delegation.bottomnavbarvisibility

import com.algorand.android.core.BaseFragment
import com.algorand.android.utils.delegation.keyboardvisibility.KeyboardHandlerDelegation
import com.algorand.android.utils.delegation.keyboardvisibility.KeyboardHandlerDelegationImpl

class BottomNavBarVisibilityDelegationImpl : BottomNavBarVisibilityDelegation,
    KeyboardHandlerDelegation by KeyboardHandlerDelegationImpl() {

    private var baseFragment: BaseFragment? = null

    private val onKeyboardClosedListener = KeyboardHandlerDelegationImpl.OnKeyboardClosedListener {
        baseFragment?.handleBottomBarVisibility(true)
    }

    private val onKeyboardOpenedListener = KeyboardHandlerDelegationImpl.OnKeyboardOpenedListener {
        baseFragment?.handleBottomBarVisibility(false)
    }

    override fun registerBottomNavBarVisibilityDelegation(baseFragment: BaseFragment) {
        this.baseFragment = baseFragment
        registerKeyboardHandlerDelegation(
            baseFragment = baseFragment,
            onKeyboardClosedListener = onKeyboardClosedListener,
            onKeyboardOpenedListener = onKeyboardOpenedListener
        )
    }
}
