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

package com.algorand.android.models

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

sealed class WalletConnectTransactionErrorResponse : Parcelable {

    abstract val message: String
    abstract val responseCode: Long

    @Parcelize
    data class Rejected(
        override val message: String,
        override val responseCode: Long = REJECTED_RESPONSE_CODE
    ) : WalletConnectTransactionErrorResponse() {

        companion object {
            private const val REJECTED_RESPONSE_CODE = 4001L
        }
    }

    @Parcelize
    data class Unauthorized(
        override val message: String,
        override val responseCode: Long = UNAUTHORIZED_RESPONSE_CODE
    ) : WalletConnectTransactionErrorResponse() {

        companion object {
            private const val UNAUTHORIZED_RESPONSE_CODE = 4100L
        }
    }

    @Parcelize
    data class Unsupported(
        override val message: String,
        override val responseCode: Long = UNSUPPORTED_RESPONSE_CODE
    ) : WalletConnectTransactionErrorResponse() {

        companion object {
            private const val UNSUPPORTED_RESPONSE_CODE = 4200L
        }
    }

    @Parcelize
    data class InvalidInput(
        override val message: String,
        override val responseCode: Long = INVALID_INPUT_RESPONSE_CODE
    ) : WalletConnectTransactionErrorResponse() {

        companion object {
            private const val INVALID_INPUT_RESPONSE_CODE = 4300L
        }
    }

    @Parcelize
    data class UnknownAsset(
        override val message: String,
        override val responseCode: Long = UNKNOWN_ASSET_RESPONSE_CODE
    ) : WalletConnectTransactionErrorResponse() {

        companion object {
            private const val UNKNOWN_ASSET_RESPONSE_CODE = 4400L
        }
    }
}
