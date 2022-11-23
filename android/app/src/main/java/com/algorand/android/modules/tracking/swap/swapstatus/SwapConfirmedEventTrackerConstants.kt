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

package com.algorand.android.modules.tracking.swap.swapstatus

internal object SwapConfirmedEventTrackerConstants {

    const val INPUT_ASA_AMOUNT_AS_USD_PAYLOAD_KEY = "input_amount_usd"
    const val INPUT_ASA_AMOUNT_AS_ALGO_PAYLOAD_KEY = "input_amount_algo"
    const val INPUT_ASA_AMOUNT_AS_ASA_PAYLOAD_KEY = "input_amount_asa"
    const val INPUT_ASA_NAME_PAYLOAD_KEY = "input_asa_name"
    const val INPUT_ASA_ID_PAYLOAD_KEY = "input_asa_id"

    const val OUTPUT_ASA_AMOUNT_AS_USD_PAYLOAD_KEY = "output_amount_usd"
    const val OUTPUT_ASA_AMOUNT_AS_ALGO_PAYLOAD_KEY = "output_amount_algo"
    const val OUTPUT_ASA_AMOUNT_AS_ASA_PAYLOAD_KEY = "output_amount_asa"
    const val OUTPUT_ASA_NAME_PAYLOAD_KEY = "output_asa_name"
    const val OUTPUT_ASA_ID_PAYLOAD_KEY = "output_asa_id"

    const val SWAP_DATE_TIMESTAMP_PAYLOAD_KEY = "swap_date_timestamp"
    const val SWAP_DATE_FORMATTED_PAYLOAD_KEY = "swap_date_format"

    const val PERA_FEE_IN_ALGO_PAYLOAD_KEY = "pera_fee_inalgo"
    const val PERA_FEE_IN_USD_PAYLOAD_KEY = "pera_fee_inusd"
    const val EXCHANGE_FEE_IN_ALGO_PAYLOAD_KEY = "exchange_fee_inalgo"
    const val NETWORK_FEE_IN_ALGO_PAYLOAD_KEY = "network_fee_inalgo"

    const val SWAP_WALLET_ADDRESS_PAYLOAD_KEY = "swap_wallet_address"
}
