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

package com.algorand.android.ui.contacts

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import androidx.core.net.toUri
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentContactInfoBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet.Companion.ACCOUNT_SELECTION_KEY
import com.algorand.android.ui.contacts.ContactInfoFragmentDirections.Companion.actionAddEditContactFragmentToSendInfoFragment
import com.algorand.android.ui.contacts.ContactInfoFragmentDirections.Companion.actionContactInfoFragmentToAccountSelectionBottomSheet
import com.algorand.android.ui.contacts.ContactInfoFragmentDirections.Companion.actionContactInfoFragmentToAddEditContactFragment
import com.algorand.android.ui.contacts.ContactInfoFragmentDirections.Companion.actionContactInfoFragmentToShowQrBottomSheet
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.loadContactProfileImage
import com.algorand.android.utils.openTextShareBottomMenuChooser
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class ContactInfoFragment : DaggerBaseFragment(R.layout.fragment_contact_info) {

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private val contactInfoViewModel: ContactInfoViewModel by viewModels()

    private val args: ContactInfoFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentContactInfoBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.contact_info,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val contactAssetsAdapter = ContactAssetsAdapter(::onSendButtonClick)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        customizeToolbar()
        initViewModelObservers()
        setupAssetsRecyclerView()
        contactInfoViewModel.getAccountInformation(args.contact.publicKey)
        setupInputs()
        setupButtons()
        initDialogSavedStateListener()
    }

    private fun customizeToolbar() {
        getAppToolbar()?.apply {
            val editButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_text_tab_button, this, false) as MaterialButton

            editButton.apply {
                setText(R.string.edit)
                setOnClickListener { onEditClick() }
                addViewToEndSide(this)
            }
        }
    }

    private fun setupInputs() {
        with(args.contact) {
            binding.contactImageView.loadContactProfileImage(imageUriAsString?.toUri(), true)
            binding.nameTextView.text = name
            binding.addressEditText.text = publicKey
        }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.contactInfoFragment) {
            useSavedStateValue<AccountSelectionBottomSheet.Result>(ACCOUNT_SELECTION_KEY) { (cache, assetInformation) ->
                nav(
                    actionAddEditContactFragmentToSendInfoFragment(
                        assetInformation = assetInformation,
                        contact = args.contact,
                        account = cache.account
                    )
                )
            }
        }
    }

    private fun setupButtons() {
        binding.showQrButton.setOnClickListener { onShowQrClick() }
        binding.shareButton.setOnClickListener { onShareClick() }
    }

    private fun onShowQrClick() {
        binding.showQrButton.hideKeyboard()
        nav(actionContactInfoFragmentToShowQrBottomSheet(args.contact.name, args.contact.publicKey))
    }

    private fun onShareClick() {
        context?.openTextShareBottomMenuChooser(args.contact.publicKey, getString(R.string.share_via))
    }

    private fun onEditClick() {
        nav(
            actionContactInfoFragmentToAddEditContactFragment(
                contactName = args.contact.name,
                contactPublicKey = args.contact.publicKey,
                contactDatabaseId = args.contact.contactDatabaseId,
                contactProfileImageUri = args.contact.imageUriAsString
            )
        )
    }

    private fun onSendButtonClick(assetInformation: AssetInformation) {
        val filteredAccountCache = accountCacheManager.getAccountCacheWithSpecificAsset(
            assetInformation.assetId, listOf(Account.Type.WATCH)
        )
        if (filteredAccountCache.isEmpty()) {
            showSnackbar(getString(R.string.you_dont_have_any), binding.contactsRoot)
            return
        }
        nav(
            actionContactInfoFragmentToAccountSelectionBottomSheet(
                assetInformation.assetId,
                R.string.select_sending_account
            )
        )
    }

    private fun setupAssetsRecyclerView() {
        binding.assetsList.apply {
            setHasFixedSize(true)
            adapter = contactAssetsAdapter
        }
    }

    private fun initViewModelObservers() {
        contactInfoViewModel.accountInformationLiveData.observe(viewLifecycleOwner, {
            contactAssetsAdapter.setAssets(it.getAssetInformationList(accountCacheManager))
        })
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_contact_detail"
    }
}
