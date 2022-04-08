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

package com.algorand.android

import com.algorand.android.utils.PrismUrlBuilder
import org.junit.Test

class PrismUrlBuilderTest {

    @Test
    fun ensureAddingWidthWorks() {
        val width = 150
        val builder = PrismUrlBuilder.create(RAW_PRISM_URL)
        builder.addWidth(width)

        val builtUrl = builder.build()

        val expectedUrl = "$RAW_PRISM_URL?width=150"

        assert(expectedUrl == builtUrl)
    }

    @Test
    fun ensureAddingHeightWorks() {
        val height = 150
        val builder = PrismUrlBuilder.create(RAW_PRISM_URL)
        builder.addHeight(height)

        val builtUrl = builder.build()

        val expectedUrl = "$RAW_PRISM_URL?height=150"

        assert(expectedUrl == builtUrl)
    }

    @Test
    fun ensureAddingHeightAndWidthWorks() {
        val width = 150
        val height = 200
        val builder = PrismUrlBuilder.create(RAW_PRISM_URL)
        builder.addWidth(width)
        builder.addHeight(height)

        val builtUrl = builder.build()

        val expectedUrl = "$RAW_PRISM_URL?width=150&height=200"

        assert(expectedUrl == builtUrl)
    }

    @Test
    fun ensureEmptyStringNotCausesCrash() {
        val width = 150
        val builder = PrismUrlBuilder.create("")
        builder.addWidth(width)

        val builtUrl = builder.build()

        val expectedUrl = "?width=150"

        assert(expectedUrl == builtUrl)
    }

    @Test
    fun ensureBlankStringNotCausesCrash() {
        val width = 150
        val builder = PrismUrlBuilder.create(" ")
        builder.addWidth(width)

        val builtUrl = builder.build()

        val expectedUrl = "?width=150"

        assert(expectedUrl == builtUrl)
    }

    companion object {
        private const val RAW_PRISM_URL = "https://perawallet-staging-testnet.tryprism.com/media/collectible_primary_images/2022/02/22/c26d701574f2449da962fc0bbe5528e2.jpeg"
    }
}
