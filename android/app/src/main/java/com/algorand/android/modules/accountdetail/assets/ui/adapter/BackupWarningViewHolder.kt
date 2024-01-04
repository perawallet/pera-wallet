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

package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemBackupWarningBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem

class BackupWarningViewHolder(
    private val binding: ItemBackupWarningBinding,
    private val listener: Listener,
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    override fun bind(item: AccountDetailAssetsItem) {
        binding.backupNowButton.setOnClickListener { listener.onBackupNowClick() }
    }

    interface Listener {
        fun onBackupNowClick()
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: Listener
        ): BackupWarningViewHolder {
            val binding = ItemBackupWarningBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return BackupWarningViewHolder(binding, listener)
        }
    }
}
