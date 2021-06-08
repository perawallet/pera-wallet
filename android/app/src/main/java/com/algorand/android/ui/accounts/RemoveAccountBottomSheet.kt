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

package com.algorand.android.ui.accounts

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetRemoveAccountBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class RemoveAccountBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_remove_account,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private val toolbarConfiguration = ToolbarConfiguration(R.string.remove_account)

    private val binding by viewBinding(BottomSheetRemoveAccountBinding::bind)

    private val args: RemoveAccountBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        binding.canceButton.setOnClickListener {
            navBack()
        }
        binding.confirmationButton.setOnClickListener {
            accountManager.removeAccount(args.publicKey, accountCacheManager)
            navBack()
        }
    }
}
