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
 */

package com.algorand.android.usecase

import androidx.core.net.toUri
import com.algorand.android.mapper.AccountSelectionListItemMapper
import com.algorand.android.models.BaseAccountSelectionListItem
import javax.inject.Inject

class GetAccountSelectionContactsItemUseCase @Inject constructor(
    private val contactUseCase: ContactUseCase,
    private val accountSelectionListItemMapper: AccountSelectionListItemMapper
) {

    // TODO: 11.03.2022 Use flow here to get realtime updates
    suspend fun getAccountSelectionContacts(): List<BaseAccountSelectionListItem.BaseAccountItem.ContactItem> {
        return contactUseCase.getAllContacts().map { contact ->
            val publicKey = contact.publicKey
            val name = contact.name
            val imageUri = contact.imageUriAsString?.toUri()
            accountSelectionListItemMapper.mapToContactItem(
                publicKey = publicKey,
                name = name,
                imageUri = imageUri
            )
        }
    }
}
