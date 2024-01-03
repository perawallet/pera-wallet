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

package com.algorand.android.modules.walletconnect.launchback.connection.ui

import androidx.fragment.app.viewModels
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.launchback.base.ui.WcLaunchBackBrowserBottomSheet
import com.algorand.android.modules.walletconnect.launchback.base.ui.WcLaunchBackBrowserViewModel
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WCConnectionLaunchBackBrowserBottomSheet : WcLaunchBackBrowserBottomSheet() {

    override val wcLaunchBackBrowserViewModel: WcLaunchBackBrowserViewModel
        get() = wcConnectionLaunchBackBrowserViewModel

    private val wcConnectionLaunchBackBrowserViewModel by viewModels<WCConnectionLaunchBackBrowserViewModel>()

    private val sessionInformationAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        binding.sessionInformationTextView.apply {
            if (annotatedString != null) {
                show()
                text = context.getXmlStyledString(annotatedString)
            } else {
                hide()
            }
        }
    }

    override fun initObservers() {
        super.initObservers()
        with(wcConnectionLaunchBackBrowserViewModel.wcLaunchBackBrowserFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.sessionInformationAnnotatedString },
                collection = sessionInformationAnnotatedStringCollector
            )
        }
    }
}
