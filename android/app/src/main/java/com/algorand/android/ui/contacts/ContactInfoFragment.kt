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

package com.algorand.android.ui.contacts

import android.os.Bundle
import android.view.View
import androidx.core.net.toUri
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentContactInfoBinding
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelection
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet.Companion.ACCOUNT_SELECTION_KEY
import com.algorand.android.utils.Resource
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.openTextShareBottomMenuChooser
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class ContactInfoFragment : DaggerBaseFragment(R.layout.fragment_contact_info) {

    private val contactInfoViewModel: ContactInfoViewModel by viewModels()

    private val args: ContactInfoFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentContactInfoBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    // TODO: 31.08.2021 onFailed case did not handle before and loading cases will be updated when shimmer implement
    private val accountInformationCollector: suspend (Resource<AccountInformation>?) -> Unit = {
        it?.use(
            onSuccess = { contactAssetsAdapter.setAssets(contactInfoViewModel.getAccountAssets(it)) },
            onLoadingFinished = null,
            onLoading = null,
            onFailed = { showSnackbar(it.parse(binding.contactsRoot.context).toString(), binding.contactsRoot) }
        )
    }

    private val contactAssetsAdapter = ContactAssetsAdapter(::onSendButtonClick)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        customizeToolbar()
        initObservers()
        setupAssetsRecyclerView()
        setupInputs()
        setupButtons()
        initDialogSavedStateListener()
    }

    private fun customizeToolbar() {
        getAppToolbar()?.apply {
            addButtonToEnd(IconButton(R.drawable.ic_share, onClick = ::onShareClick))
            addButtonToEnd(IconButton(R.drawable.ic_pen, onClick = ::onEditClick))
        }
    }

    private fun setupInputs() {
        with(args.contact) {
            with(binding) {
                contactImageView.loadAccountImage(
                    uri = imageUriAsString?.toUri(),
                    padding = R.dimen.spacing_normal
                )
                nameTextView.text = name
                addressBelowNameTextView.text = publicKey.toShortenedAddress()
                addressTextView.text = publicKey
            }
        }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.contactInfoFragment) {
            useSavedStateValue<AccountSelection>(ACCOUNT_SELECTION_KEY) { accountSelection ->
                val assetTransaction = AssetTransaction(
                    assetId = accountSelection.assetInformation.assetId,
                    receiverUser = args.contact,
                    senderAddress = accountSelection.accountCacheData.account.address
                )
                nav(
                    HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction)
                )
            }
        }
    }

    private fun setupButtons() {
        binding.showQrButton.setOnClickListener { onShowQrClick() }
    }

    private fun onShowQrClick() {
        binding.showQrButton.hideKeyboard()
        nav(
            ContactInfoFragmentDirections.actionContactInfoFragmentToShowQrBottomSheet(
                args.contact.name,
                args.contact.publicKey
            )
        )
    }

    private fun onShareClick() {
        context?.openTextShareBottomMenuChooser(args.contact.publicKey, getString(R.string.share_via))
    }

    private fun onEditClick() {
        nav(
            ContactInfoFragmentDirections.actionContactInfoFragmentToEditContactFragment(
                contactName = args.contact.name,
                contactPublicKey = args.contact.publicKey,
                contactDatabaseId = args.contact.contactDatabaseId,
                contactProfileImageUri = args.contact.imageUriAsString
            )
        )
    }

    private fun onSendButtonClick(assetInformation: AssetInformation) {
        val filteredAccountCache = contactInfoViewModel.filterCachedAccountByAssetId(assetInformation.assetId)
        if (filteredAccountCache.isEmpty()) {
            showSnackbar(getString(R.string.you_dont_have_any), binding.contactsRoot)
            return
        }
        nav(
            ContactInfoFragmentDirections.actionContactInfoFragmentToAccountSelectionBottomSheet(
                assetId = assetInformation.assetId,
                titleResId = R.string.select_sending_account
            )
        )
    }

    private fun setupAssetsRecyclerView() {
        binding.assetsList.adapter = contactAssetsAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            contactInfoViewModel.accountInformationFlow.collectLatest(accountInformationCollector)
        }
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_contact_detail"
    }
}
