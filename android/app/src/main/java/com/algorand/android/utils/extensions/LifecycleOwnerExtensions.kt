/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.utils.extensions

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

fun <T> LifecycleOwner.collectLatestOnLifecycle(
    flow: Flow<T>?,
    collection: suspend (T) -> Unit,
    state: Lifecycle.State = Lifecycle.State.RESUMED
) {
    lifecycleScope.launch {
        // This operator on a flow uses repeatOnLifecycle under the hood
        flow?.flowWithLifecycle(lifecycle, state)
            ?.collectLatest(collection)
    }
}

fun <T> LifecycleOwner.collectOnLifecycle(
    flow: Flow<T>?,
    collection: suspend (T) -> Unit,
    state: Lifecycle.State = Lifecycle.State.RESUMED
) {
    lifecycleScope.launch {
        // This operator on a flow uses repeatOnLifecycle under the hood
        flow?.flowWithLifecycle(lifecycle, state)
            ?.collect { collection.invoke(it) }
    }
}
