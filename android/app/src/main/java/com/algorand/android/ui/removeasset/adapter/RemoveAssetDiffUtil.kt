/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.removeasset.adapter

import androidx.recyclerview.widget.DiffUtil
import com.algorand.android.ui.removeasset.RemoveAssetItem

class RemoveAssetDiffUtil : DiffUtil.ItemCallback<RemoveAssetItem>() {
    override fun areItemsTheSame(oldItem: RemoveAssetItem, newItem: RemoveAssetItem): Boolean {
        return oldItem.accountAssetData.id == newItem.accountAssetData.id
    }

    override fun areContentsTheSame(oldItem: RemoveAssetItem, newItem: RemoveAssetItem): Boolean {
        return oldItem.accountAssetData.shortName == newItem.accountAssetData.shortName &&
            oldItem.accountAssetData.name == newItem.accountAssetData.name
    }
}
