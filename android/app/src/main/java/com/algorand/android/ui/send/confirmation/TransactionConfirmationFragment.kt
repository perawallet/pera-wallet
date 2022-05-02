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
 *
 */

package com.algorand.android.ui.send.confirmation

import android.os.Bundle
import android.view.View
import androidx.core.os.bundleOf
import androidx.fragment.app.setFragmentResult
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.SendAlgoNavigationDirections
import com.algorand.android.core.BaseFragment
import com.algorand.android.models.FragmentConfiguration
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class TransactionConfirmationFragment : BaseFragment(R.layout.fragment_transaction_confirmation) {

    override val fragmentConfiguration = FragmentConfiguration()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.lifecycleScope.launch {
            delay(ANIMATION_DURATION)
            setFragmentResult(TRANSACTION_CONFIRMATION_KEY, bundleOf(TRANSACTION_CONFIRMED_KEY to true))
            nav(SendAlgoNavigationDirections.actionSendAlgoNavigationPop())
        }
    }

    companion object {
        const val TRANSACTION_CONFIRMATION_KEY = "transaction_confirmation_key"
        const val TRANSACTION_CONFIRMED_KEY = "transaction_confirmed_key"
        private const val ANIMATION_DURATION = 1000L
    }
}
