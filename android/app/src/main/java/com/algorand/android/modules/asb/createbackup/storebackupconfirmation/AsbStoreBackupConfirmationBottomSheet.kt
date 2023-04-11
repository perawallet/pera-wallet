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

package com.algorand.android.modules.asb.createbackup.storebackupconfirmation

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton

class AsbStoreBackupConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {
    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.have_you_stored_your)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(R.string.if_you_lose_your_algorand)
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.yes_i_stored_my_file)
            setOnClickListener {
                navBack()
                setFragmentNavigationResult(ASB_STORE_BACKUP_CONFIRMATION_KEY, true)
            }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.show_backup_file_again)
            setOnClickListener { navBack() }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(R.drawable.ic_info)
            imageTintList = ContextCompat.getColorStateList(context, R.color.positive)
        }
    }

    companion object {
        const val ASB_STORE_BACKUP_CONFIRMATION_KEY = "asbStoreBackupConfirmation"
    }
}
