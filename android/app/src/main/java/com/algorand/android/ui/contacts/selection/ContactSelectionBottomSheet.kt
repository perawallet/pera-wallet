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

package com.algorand.android.ui.contacts.selection

import android.os.Bundle
import android.view.View
import androidx.core.view.isInvisible
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetContactSelectionBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.ui.common.user.UserAdapter
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ContactSelectionBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_contact_selection,
    fullPageNeeded = true,
    firebaseEventScreenId = null
) {

    private val contactsAdapter = UserAdapter(::onContactClick)

    private val contactSelectionViewModel: ContactSelectionViewModel by viewModels()

    private val binding by viewBinding(BottomSheetContactSelectionBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.contacts,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::onBackPressed
    )

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val contactListObserver = Observer<List<User>> { contactList ->
        contactsAdapter.submitList(contactList)
        binding.emptyLayout.isInvisible = contactList.isEmpty().not()
    }

    // </editor-fold>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        setupRecyclerView()
        initObservers()
        setupSearchQueryEditTextWatcher()
    }

    private fun setupRecyclerView() {
        binding.contactRecyclerView.adapter = contactsAdapter
    }

    private fun onContactClick(selectedContact: User) {
        setNavigationResult(CONTACT_SELECTION_KEY, selectedContact)
        onBackPressed()
    }

    private fun initObservers() {
        contactSelectionViewModel.contactsListLiveData.observe(viewLifecycleOwner, contactListObserver)
    }

    private fun setupSearchQueryEditTextWatcher() {
        binding.searchEditText.doAfterTextChanged {
            contactSelectionViewModel.updateContactsListLiveDataWithSearchQuery(it.toString())
        }
    }

    private fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    companion object {
        const val CONTACT_SELECTION_KEY = "contact_selection_key"
    }
}
