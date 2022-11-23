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

package com.algorand.android.modules.swap.utils

import com.algorand.android.models.Account
import com.algorand.android.modules.swap.introduction.domain.usecase.IsSwapFeatureIntroductionPageShownUseCase
import com.algorand.android.modules.swap.reddot.domain.usecase.SetSwapFeatureRedDotVisibilityUseCase
import com.algorand.android.usecase.GetLocalAccountsUseCase
import javax.inject.Inject

class SwapNavigationDestinationHelper @Inject constructor(
    private val isSwapFeatureIntroductionPageShownUseCase: IsSwapFeatureIntroductionPageShownUseCase,
    private val setSwapFeatureRedDotVisibilityUseCase: SetSwapFeatureRedDotVisibilityUseCase,
    private val accountsUseCase: GetLocalAccountsUseCase
) {

    suspend fun getSwapNavigationDestination(
        accountAddress: String? = null,
        onNavToIntroduction: () -> Unit,
        onNavToSwap: (accountAddress: String) -> Unit,
        onNavToAccountSelection: (() -> Unit)? = null
    ) {
        hideSwapButtonRedDot()
        if (isSwapFeatureIntroductionPageShownUseCase.isSwapFeatureIntroductionPageShown()) {
            handleDestinationWithAccount(accountAddress, onNavToSwap, onNavToAccountSelection)
        } else {
            onNavToIntroduction()
        }
    }

    private fun handleDestinationWithAccount(
        accountAddress: String?,
        onNavToSwap: (accountAddress: String) -> Unit,
        onNavToAccountSelection: (() -> Unit)?
    ) {
        if (accountAddress != null) {
            onNavToSwap(accountAddress)
        } else {
            val authorizedAccounts = getAccountsThatCanSignTransaction()
            if (authorizedAccounts.size == 1) {
                onNavToSwap(authorizedAccounts.first().address)
            } else {
                onNavToAccountSelection?.invoke()
            }
        }
    }

    private fun getAccountsThatCanSignTransaction(): List<Account> {
        return accountsUseCase.getLocalAccountsFromAccountManagerCache().filter {
            it.canSignTransaction()
        }
    }

    private suspend fun hideSwapButtonRedDot() {
        setSwapFeatureRedDotVisibilityUseCase.setSwapFeatureRedDotVisibility(isVisible = false)
    }
}
