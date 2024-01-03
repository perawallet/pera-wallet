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

package com.algorand.android.modules.webimport.loading.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.webimport.loading.domain.model.ImportedAccountResult
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WebImportLoadingFragment : BaseFragment(R.layout.fragment_web_import_loading) {
    override val fragmentConfiguration = FragmentConfiguration()

    private val webImportLoadingViewModel: WebImportLoadingViewModel by viewModels()

    private val requestSendSuccessEventCollector: suspend (Event<ImportedAccountResult>?) -> Unit = {
        it?.consume()?.run {
            nav(
                WebImportLoadingFragmentDirections
                    .actionWebImportLoadingFragmentToWebImportResultFragment(
                        importedAccountList.toTypedArray(),
                        unimportedAccountList.toTypedArray()
                )
            )
        }
    }

    private val globalErrorEventCollector: suspend (Event<String>?) -> Unit = {
        it?.consume()?.run {
            nav(
                WebImportLoadingFragmentDirections
                    .actionWebImportLoadingFragmentToWebImportResultFragment(
                        arrayOf(),
                        arrayOf()
                    )
            )
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
    }

    private fun initObservers() {
        with(webImportLoadingViewModel.webImportLoadingPreviewFlow) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                map { it.requestSendSuccessEvent }.distinctUntilChanged(),
                requestSendSuccessEventCollector
            )

            viewLifecycleOwner.collectOnLifecycle(
                map { it.globalErrorEvent }.distinctUntilChanged(),
                globalErrorEventCollector
            )
        }
    }
}
