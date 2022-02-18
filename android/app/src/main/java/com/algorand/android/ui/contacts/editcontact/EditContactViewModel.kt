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

package com.algorand.android.ui.contacts.editcontact

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.database.ContactDao
import com.algorand.android.models.OperationState
import com.algorand.android.models.User
import com.algorand.android.utils.Event
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class EditContactViewModel @ViewModelInject constructor(
    private val contactDao: ContactDao
) : ViewModel() {

    private val _contactOperationFlow = MutableStateFlow<Event<OperationState<User>>?>(null)
    val contactOperationFlow: StateFlow<Event<OperationState<User>>?> get() = _contactOperationFlow

    fun removeContactInDatabase(contactDatabaseId: Int) {
        viewModelScope.launch {
            contactDao.deleteContact(contactDatabaseId)
            _contactOperationFlow.emit(Event(OperationState.Delete))
        }
    }

    fun updateContactInDatabase(contact: User) {
        viewModelScope.launch {
            contactDao.updateContact(contact)
            _contactOperationFlow.emit(Event(OperationState.Update(contact)))
        }
    }
}
