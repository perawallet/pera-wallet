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

package com.algorand.android.utils.delegation.bottomnavfragment

import com.algorand.android.core.BaseFragment
import com.algorand.android.utils.delegation.bottomnavbarvisibility.BottomNavBarVisibilityDelegation
import com.algorand.android.utils.delegation.bottomnavbarvisibility.BottomNavBarVisibilityDelegationImpl
import com.algorand.android.utils.delegation.nativebackpress.BackPressedControllerComponent
import com.algorand.android.utils.delegation.nativebackpress.BottomNavigationBackPressedDelegate

class BottomNavBarFragmentDelegationImpl : BottomNavBarFragmentDelegation,
    BottomNavBarVisibilityDelegation by BottomNavBarVisibilityDelegationImpl(),
    BackPressedControllerComponent by BottomNavigationBackPressedDelegate() {

    override fun registerBottomNavBarFragmentDelegation(baseFragment: BaseFragment) {
        registerBottomNavBarVisibilityDelegation(baseFragment)
        initBackPressedControllerComponent(baseFragment)
    }
}
