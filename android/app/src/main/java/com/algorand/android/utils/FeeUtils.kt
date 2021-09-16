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

package com.algorand.android.utils

import com.algorand.android.models.AccountInformation

private const val MIN_BALANCE_TO_KEEP_PER_OPTED_IN_ASSET = 100000
private const val MIN_BALANCE_TO_KEEP_PER_CREATED_APPS = 100000
private const val MIN_BALANCE_TO_KEEP_PER_OPTED_IN_APPS = 100000
private const val MIN_BALANCE_TO_KEEP_PER_APP_TOTAL_SCHEMA_INT = 28500
private const val MIN_BALANCE_TO_KEEP_PER_APP_TOTAL_SCHEMA_BYTE_SLICE = 50000
private const val MIN_BALANCE_TO_KEEP_PER_APP_EXTRA_PAGES = 100000
private const val MIN_BALANCE = 100000

fun calculateMinBalance(accountInformation: AccountInformation, includeMinBalance: Boolean): Long {
    with(accountInformation) {
        val optedAssets = getOptedInAssetsCount()
        val createdApps = createdApps?.size ?: 0
        val optedApps = appsLocalState?.size ?: 0
        val intSchemeValue = appsTotalSchema?.numUint ?: 0
        val byteSchemeValue = appsTotalSchema?.numByteSlice ?: 0
        val extraAppPages = appsTotalExtraPages ?: 0
        return MIN_BALANCE_TO_KEEP_PER_OPTED_IN_ASSET * optedAssets +
            MIN_BALANCE_TO_KEEP_PER_CREATED_APPS * createdApps +
            MIN_BALANCE_TO_KEEP_PER_OPTED_IN_APPS * optedApps +
            MIN_BALANCE_TO_KEEP_PER_APP_TOTAL_SCHEMA_INT * intSchemeValue +
            MIN_BALANCE_TO_KEEP_PER_APP_TOTAL_SCHEMA_BYTE_SLICE * byteSchemeValue +
            MIN_BALANCE_TO_KEEP_PER_APP_EXTRA_PAGES * extraAppPages +
            if (includeMinBalance) MIN_BALANCE else 0
    }
}
