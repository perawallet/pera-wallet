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

package com.algorand.android.ui.contacts.addcontact

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.ContactDao
import com.algorand.android.models.User
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class AddEditContactViewModel @ViewModelInject constructor(
    private val contactDao: ContactDao
) : BaseViewModel() {

    val isContactOperationFinished = MutableLiveData<User?>()
    val isContractSearchingFinished = MutableLiveData<User?>()

    fun insertContactToDatabase(contact: User) {
        viewModelScope.launch(Dispatchers.IO) {
            contactDao.insertContact(contact)
            isContactOperationFinished.postValue(contact)
        }
    }

    fun updateContactInDatabase(contact: User) {
        viewModelScope.launch(Dispatchers.IO) {
            contactDao.updateContact(contact)
            isContactOperationFinished.postValue(contact)
        }
    }

    fun removeContactInDatabase(contactDatabaseId: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            contactDao.deleteContact(contactDatabaseId)
            isContactOperationFinished.postValue(null)
        }
    }

    fun checkIsContactExist(contactDatabaseAddress: String) {
        viewModelScope.launch(Dispatchers.IO) {
            val contact = contactDao.getContactByAddress(contactDatabaseAddress)
            isContractSearchingFinished.postValue(contact)
        }
    }
}
