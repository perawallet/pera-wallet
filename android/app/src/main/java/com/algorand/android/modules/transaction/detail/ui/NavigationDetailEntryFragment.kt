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

package com.algorand.android.modules.transaction.detail.ui

import android.os.Bundle
import android.view.View
import androidx.navigation.NavDirections
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailEntryPoint

class NavigationDetailEntryFragment : BaseFragment(R.layout.fragment_navigation_detail_entry) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val args by navArgs<NavigationDetailEntryFragmentArgs>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        navToTransactionDetailByEntryPoint()
    }

    private fun navToTransactionDetailByEntryPoint() {
        when (args.entryPoint) {
            TransactionDetailEntryPoint.STANDARD_TRANSACTION -> getStandardTransactionDetailDirection()
            TransactionDetailEntryPoint.APPLICATION_CALL_TRANSACTION -> getApplicationCallTransactionDetailDirection()
        }.also { nav(it) }
    }

    private fun getApplicationCallTransactionDetailDirection(): NavDirections {
        return NavigationDetailEntryFragmentDirections
            .actionNavigationDetailEntryFragmentToApplicationCallTransactionDetailFragment(
                transactionId = args.transactionId,
                accountAddress = args.accountAddress
            )
    }

    private fun getStandardTransactionDetailDirection(): NavDirections {
        return NavigationDetailEntryFragmentDirections
            .actionNavigationDetailEntryFragmentToStandardTransactionDetailFragment(
                transactionId = args.transactionId,
                accountAddress = args.accountAddress
            )
    }
}
