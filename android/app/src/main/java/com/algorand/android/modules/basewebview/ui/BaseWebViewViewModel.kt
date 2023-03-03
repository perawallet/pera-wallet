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

package com.algorand.android.modules.basewebview.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.customviews.PeraWebView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

abstract class BaseWebViewViewModel : BaseViewModel() {

    private val _peraWebViewFlow: MutableStateFlow<PeraWebView?> = MutableStateFlow(null)

    fun saveWebView(webView: PeraWebView?) {
        viewModelScope.launch(Dispatchers.IO) {
            _peraWebViewFlow.emit(webView)
        }
    }

    fun getWebView(): PeraWebView? {
        return _peraWebViewFlow.value
    }

    fun destroyWebView() {
        viewModelScope.launch {
            _peraWebViewFlow
                .emit(null)
        }
    }
}
