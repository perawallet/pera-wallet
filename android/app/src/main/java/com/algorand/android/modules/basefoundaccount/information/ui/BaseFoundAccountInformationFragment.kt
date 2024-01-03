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

package com.algorand.android.modules.basefoundaccount.information.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseFoundAccountInformationBinding
import com.algorand.android.modules.basefoundaccount.information.ui.adapter.FoundAccountInformationAdapter
import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.map

abstract class BaseFoundAccountInformationFragment : BaseFragment(R.layout.fragment_base_found_account_information) {

    protected abstract val baseFoundAccountInformationViewModel: BaseFoundAccountInformationViewModel

    protected val binding by viewBinding(FragmentBaseFoundAccountInformationBinding::bind)

    private val foundAccountInformationAdapterListener = object : FoundAccountInformationAdapter.Listener {
        override fun onAccountItemLongClick(accountAddress: String) {
            onAccountAddressCopied(accountAddress)
        }

        override fun onAssetItemLongClick(assetId: Long) {
            onAssetIdCopied(assetId)
        }
    }

    private val foundAccountInformationAdapter = FoundAccountInformationAdapter(foundAccountInformationAdapterListener)

    private val foundAccountInformationItemListCollector: suspend (List<BaseFoundAccountInformationItem>) -> Unit = {
        foundAccountInformationAdapter.submitList(it)
    }

    private val loadingVisibilityCollector: suspend (Boolean) -> Unit = { isVisible ->
        binding.progressBar.root.isVisible = isVisible
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.foundAccountInformationRecyclerView.adapter = foundAccountInformationAdapter
    }

    private fun initObservers() {
        with(baseFoundAccountInformationViewModel.foundAccountInformationFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it.foundAccountInformationItemList },
                collection = foundAccountInformationItemListCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isLoading },
                collection = loadingVisibilityCollector
            )
        }
    }
}
