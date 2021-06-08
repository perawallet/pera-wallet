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

package com.algorand.android.ui.send

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentSendActionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SendTransactionResponse
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class SendActionFragment : DaggerBaseFragment(R.layout.fragment_send_action) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.preview_send_asset,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
        showNodeStatus = true
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val sendTransactionObserver = Observer<Event<Resource<SendTransactionResponse>>> { event ->
        event.consume()?.use(
            onSuccess = { findNavController().popBackStack(R.id.sendInfoFragment, true) },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoading = { binding.loadingLayout.appLoadingBar.visibility = View.VISIBLE },
            onLoadingFinished = { binding.loadingLayout.appLoadingBar.visibility = View.GONE }
        )
    }

    // </editor-fold>

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private val binding by viewBinding(FragmentSendActionBinding::bind)

    private val sendActionViewModel: SendActionViewModel by viewModels()

    private val args: SendActionFragmentArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        setAssetNameUi()
        setAccountTypeUi()
        setAccountNameUi()
        setAmountUI()
        setFeeAmountUI()
        setAddressUI()
        setNoteUI()
        setSendUI()
    }

    private fun initObservers() {
        sendActionViewModel.sendAlgoResponseLiveData.observe(viewLifecycleOwner, sendTransactionObserver)
    }

    private fun setAssetNameUi() {
        binding.assetNameTextView.setupUI(args.signedTransactionDetail.assetInformation)
    }

    private fun setAccountTypeUi() {
        binding.accountTypeImageView.setImageResource(
            args.signedTransactionDetail.accountCacheData.getImageResource()
        )
    }

    private fun setAccountNameUi() {
        binding.accountNameTextView.text = args.signedTransactionDetail.accountCacheData.account.name
    }

    private fun setAmountUI() {
        binding.amountTextView.setAmount(
            args.signedTransactionDetail.amount,
            args.signedTransactionDetail.assetInformation.decimals,
            false
        )
    }

    private fun setFeeAmountUI() {
        val fee = args.signedTransactionDetail.fee
        binding.feeAmountTextView.setAmount(fee, ALGO_DECIMALS, true)
    }

    private fun setAddressUI() {
        val targetUser = args.signedTransactionDetail.targetUser
        if (targetUser.contact != null) {
            binding.toTargetUser.setUser(targetUser.contact, false)
        } else {
            binding.toTargetUser.setAddress(targetUser.publicKey, false)
        }
    }

    private fun setNoteUI() {
        val note = args.signedTransactionDetail.note
        if (note != null) {
            binding.noteTextView.text = note
            binding.noteGroup.visibility = View.VISIBLE
        }
    }

    private fun setSendUI() {
        val signedTransactionDetail = args.signedTransactionDetail
        binding.sendButton.apply {
            text = getString(R.string.send_format, signedTransactionDetail.assetInformation.getTickerText(resources))
            setOnClickListener { onSendClick(signedTransactionDetail) }
        }
    }

    private fun onSendClick(signedTransactionDetail: SignedTransactionDetail.Send) {
        sendActionViewModel.sendSignedTransaction(signedTransactionDetail)
    }
}
