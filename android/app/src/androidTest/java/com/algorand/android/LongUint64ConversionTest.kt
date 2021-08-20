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

package com.algorand.android

import com.algorand.algosdk.mobile.Uint64
import com.algorand.android.utils.toUint64
import org.junit.Test

class LongUint64ConversionTest {

    @Test
    fun isLongToUInt64ConversionsWorksOver32Bit() {
        val longValue = 9_223_372_036_854_775_805L
        val uint64 = longValue.toUint64()

        val expectedUint64 = Uint64().apply {
            upper = 2147483647L
            lower = 2147483645L
        }

        assert(uint64.lower == expectedUint64.lower && uint64.upper == expectedUint64.upper)
    }

    @Test
    fun isLongToUInt64ConversionsWorks() {
        val longValue = 9_223_372L
        val uint64 = longValue.toUint64()

        val expectedUint64 = Uint64().apply {
            upper = 0L
            lower = 9223372L
        }

        assert(uint64.lower == expectedUint64.lower && uint64.upper == expectedUint64.upper)
    }
}
