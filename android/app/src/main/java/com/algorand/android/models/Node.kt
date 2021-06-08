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
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity
data class Node(
    @ColumnInfo(name = "name")
    var name: String,

    @ColumnInfo(name = "indexer_address")
    var indexerAddress: String,

    @ColumnInfo(name = "indexer_api_key")
    var indexerApiKey: String,

    @ColumnInfo(name = "algod_address")
    var algodAddress: String,

    @ColumnInfo(name = "algod_api_key")
    val algodApiKey: String,

    @ColumnInfo(name = "is_active")
    var isActive: Boolean,

    @ColumnInfo(name = "is_added_default")
    val isAddedDefault: Boolean,

    @ColumnInfo(name = "network_slug")
    var networkSlug: String = "",

    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "id")
    var nodeDatabaseId: Int = 0
) : Parcelable {

    fun activate(
        indexerInterceptor: IndexerInterceptor,
        mobileHeaderInterceptor: MobileHeaderInterceptor,
        algodInterceptor: AlgodInterceptor
    ) {
        algodInterceptor.currentActiveNode = this
        indexerInterceptor.currentActiveNode = this
        mobileHeaderInterceptor.currentActiveNode = this
    }
}
