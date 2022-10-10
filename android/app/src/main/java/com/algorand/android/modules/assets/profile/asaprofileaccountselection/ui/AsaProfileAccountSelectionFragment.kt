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

package com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui

import android.widget.TextView
import androidx.core.os.bundleOf
import androidx.fragment.app.setFragmentResult
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.model.AsaProfileAccountSelectionPreview
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.utils.extensions.show
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest

@AndroidEntryPoint
class AsaProfileAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val asaProfileAccountSelectionViewModel by viewModels<AsaProfileAccountSelectionViewModel>()

    private val asaProfileAccountSelectionPreviewCollector: suspend (AsaProfileAccountSelectionPreview) -> Unit = {
        if (it.isLoading) showProgress() else hideProgress()
        accountAdapter.submitList(it.accountListItems)
    }

    override fun setTitleTextView(textView: TextView) {
        textView.apply {
            text = resources.getString(R.string.select_account)
            show()
        }
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.apply {
            text = resources.getString(
                R.string.please_select_an_account_to,
                asaProfileAccountSelectionViewModel.assetShortName
            )
            show()
        }
    }

    // TODO: Use wrapper function when you merge this branch
    override fun onAccountSelected(publicKey: String) {
        setFragmentResult(
            requestKey = ASA_PROFILE_ACCOUNT_SELECTION_RESULT_KEY,
            result = bundleOf(ASA_PROFILE_ACCOUNT_SELECTION_RESULT_KEY to publicKey)
        )
        navBack()
    }

    override fun initUi() {
        super.initUi()
        getAppToolbar()?.changeTitle(asaProfileAccountSelectionViewModel.assetShortName)
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            asaProfileAccountSelectionViewModel.accountSelectionFlow.collectLatest(
                asaProfileAccountSelectionPreviewCollector
            )
        }
    }

    companion object {
        const val ASA_PROFILE_ACCOUNT_SELECTION_RESULT_KEY = "asaProfileAccountSelectionResult"
    }
}
