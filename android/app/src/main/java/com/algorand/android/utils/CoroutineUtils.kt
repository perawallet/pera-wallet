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

package com.algorand.android.utils

import kotlinx.coroutines.Deferred

/**
 * awaitOrdered works like awaitAll.
 * Difference is that it waits for all function calls to be finished, then sorts result by their call order.
 */
suspend fun <T> awaitOrdered(vararg block: Deferred<T>): List<T> {
    return block.toList().mapIndexed { index, deferred ->
        Pair(index, deferred.await())
    }.sortedBy {
        it.first
    }.map {
        it.second
    }
}
