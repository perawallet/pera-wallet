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
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentContactInfoBinding
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.extensions.setContactIconDrawable
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.openTextShareBottomMenuChooser
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ContactInfoFragment : DaggerBaseFragment(R.layout.fragment_contact_info) {

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

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        customizeToolbar()
        initUi()
    }

    private fun customizeToolbar() {
        getAppToolbar()?.apply {
            setEndButtons(
                buttons = listOf(
                    IconButton(R.drawable.ic_share, onClick = ::onShareClick),
                    IconButton(R.drawable.ic_pen_solid, onClick = ::onEditClick)
                )
            )
        }
    }

    private fun initUi() {
        with(args.contact) {
            with(binding) {
                contactImageView.setContactIconDrawable(
                    uri = imageUriAsString?.toUri(),
                    iconSize = R.dimen.account_icon_size_xlarge
                )
                nameTextView.text = name
                addressBelowNameTextView.text = publicKey.toShortenedAddress()
                addressTextView.text = publicKey
            }
        }
        binding.showQrButton.setOnClickListener { onShowQrClick() }
        binding.sendAssetButton.setOnClickListener { onSendAssetClick() }
    }

    private fun onShowQrClick() {
        binding.showQrButton.hideKeyboard()
        nav(
            ContactInfoFragmentDirections.actionGlobalShowQrNavigation(
                title = args.contact.name,
                qrText = args.contact.publicKey
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

    private fun onSendAssetClick() {
        val assetTransaction = AssetTransaction(
            receiverUser = args.contact
        )
        nav(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction))
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_contact_detail"
    }
}
