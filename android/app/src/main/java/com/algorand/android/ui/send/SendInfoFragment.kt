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
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.AccountAssetSelector
import com.algorand.android.customviews.AddressInfoView
import com.algorand.android.databinding.FragmentSendInfoBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TargetUser
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.models.User
import com.algorand.android.ui.common.AssetActionBottomSheet
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet
import com.algorand.android.ui.common.accountselector.AccountSelectionBottomSheet.Companion.ACCOUNT_SELECTION_KEY
import com.algorand.android.ui.common.assetselector.AssetSelectionBottomSheet
import com.algorand.android.ui.common.assetselector.AssetSelectionBottomSheet.Companion.ASSET_SELECTION_KEY
import com.algorand.android.ui.common.warningconfirmation.BaseMaximumBalanceWarningBottomSheet.Companion.MAX_BALANCE_WARNING_RESULT
import com.algorand.android.ui.contacts.selection.ContactSelectionBottomSheet.Companion.CONTACT_SELECTION_KEY
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment.Companion.QR_SCAN_RESULT_KEY
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToAccountSelectionBottomSheet
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToAssetSelectionBottomSheet
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToContactSelectionBottomSheet
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToRekeyedMaximumBalanceWarningBottomSheet
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToSendActionFragment
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToTransactionMaximumBalanceWarningBottomSheet
import com.algorand.android.ui.send.SendInfoFragmentDirections.Companion.actionSendInfoFragmentToTransactionTipsBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.Resource
import com.algorand.android.utils.addByteLimiter
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.calculateMinBalance
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger
import javax.inject.Inject

@AndroidEntryPoint
class SendInfoFragment : TransactionBaseFragment(R.layout.fragment_send_info) {

    @Inject
    lateinit var accountManager: AccountManager

    // asset needs to given before the this page opens.
    private lateinit var selectedAssetInformation: AssetInformation

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBackHidingKeyboard,
        showNodeStatus = true
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val toAccountInfoObserver = Observer<Event<Resource<AccountInformation>>> { event ->
        event.consume()?.use(
            onSuccess = ::checkToAccountTransactionRequirements,
            onFailed = ::handleSendError,
            onLoading = ::showLoading
        )
    }

    private val fromAccountObserver = Observer<Event<Resource<AccountInformation>>> { event ->
        event.consume()?.use(
            onSuccess = ::checkFromAccountTransactionRequirements,
            onFailed = ::handleSendError,
            onLoading = ::showLoading
        )
    }

    // </editor-fold>

    private val sendInfoViewModel: SendInfoViewModel by viewModels()

    private val binding by viewBinding(FragmentSendInfoBinding::bind)

    private val args: SendInfoFragmentArgs by navArgs()

    private var viewStatesBundle: Bundle? = null

    private val assetBalance: BigInteger
        get() = binding.accountAssetSelector.getAssetBalance() ?: BigInteger.ZERO

    private val accountAssetSelectorListener = object : AccountAssetSelector.Listener {
        override fun onChooseAssetClick() {
            nav(
                actionSendInfoFragmentToAssetSelectionBottomSheet(
                    selectedAssetInformation, AssetSelectionBottomSheet.FlowType.RESULT
                )
            )
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.accountAssetSelector.setupView(accountAssetSelectorListener, accountCacheManager)
        initArgs()
        restoreViewsStateIfPresent()

        initObservers()
        initNoteFieldObserver()

        initSavedStateListeners()

        configureToolbar()
        binding.addressInfoView.setListener(addressInfoViewListener)
        binding.previewButton.setOnClickListener { onPreviewButtonClick() }

        val selectedAccountCacheData = binding.accountAssetSelector.getSelectedAccountCacheData()
        if (selectedAccountCacheData != null) {
            updatePreviewButtonText(selectedAccountCacheData)
        } else {
            nav(
                actionSendInfoFragmentToAssetSelectionBottomSheet(
                    selectedAssetInformation,
                    AssetSelectionBottomSheet.FlowType.RESULT
                )
            )
        }
        showTransactionTips(forceShow = false) // this should be shown automatically at the first time.
    }

    private fun initSavedStateListeners() {
        startSavedStateListener(R.id.sendInfoFragment) {
            useSavedStateValue<User>(CONTACT_SELECTION_KEY) {
                binding.addressInfoView.setSelectedContact(it)
            }
            useSavedStateValue<AssetSelectionBottomSheet.Result>(ASSET_SELECTION_KEY) { (accountCacheData, _) ->
                onNewAccountSelected(accountCacheData, selectedAssetInformation, false)
            }
            useSavedStateValue<AccountSelectionBottomSheet.Result>(ACCOUNT_SELECTION_KEY) { (accountCacheData, _) ->
                binding.addressInfoView.setAddress(accountCacheData.account.address)
            }
            useSavedStateValue<DecodedQrCode>(QR_SCAN_RESULT_KEY) { decodedQrCode ->
                with(decodedQrCode) {
                    if (!address.isNullOrBlank()) {
                        binding.addressInfoView.setAddress(address)
                    }
                }
            }
            useSavedStateValue<Boolean>(MAX_BALANCE_WARNING_RESULT) { isConfirmed ->
                if (isConfirmed) {
                    val selectedAccount = binding.accountAssetSelector.getSelectedAccountCacheData()
                    val selectedAddress = selectedAccount?.account?.address ?: return@useSavedStateValue
                    showLoading()
                    sendInfoViewModel.fetchFromAccountInformation(selectedAddress)
                }
            }
        }
    }

    private fun initArgs() {
        with(args) {
            selectedAssetInformation = assetInformation

            binding.amountInput.setupAsset(selectedAssetInformation)

            if (contact != null) {
                binding.addressInfoView.setSelectedContact(contact)
            } else {
                binding.addressInfoView.setAddress(toAccountAddress)
            }

            val accountCacheData: AccountCacheData? = accountCacheManager.getCacheData(fromAccountAddress)

            if (accountCacheData != null) {
                onNewAccountSelected(accountCacheData, assetInformation, isLocked)
            }

            if (xnote != null) {
                setNodeUI(xnote, isNoteLocked = true)
            } else {
                if (note != null) {
                    setNodeUI(note, isNoteLocked = false)
                }
            }

            if (viewStatesBundle?.getString(AMOUNT_VIEW_KEY) == null) {
                binding.amountInput.setBalance(amount)
            }
        }
    }

    private fun initObservers() {
        sendInfoViewModel.toAccountInformationLiveData.observe(viewLifecycleOwner, toAccountInfoObserver)

        sendInfoViewModel.fromAccountInformationLiveData.observe(viewLifecycleOwner, fromAccountObserver)
    }

    private fun configureToolbar() {
        getAppToolbar()?.apply {
            val selectedAsset = binding.accountAssetSelector.getSelectedAsset()
            if (selectedAsset != null) {
                val assetName =
                    selectedAsset.fullName ?: (selectedAsset.shortName ?: resources.getString(R.string.unnamed))
                getAppToolbar()?.changeTitle(getString(R.string.send_format, assetName))
            }

            val marginEnd = resources.getDimensionPixelSize(R.dimen.keyline_1_minus_8dp)

            val infoButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_icon_tab_button, this, false) as ImageButton

            infoButton.apply {
                setImageResource(R.drawable.ic_info)
                setOnClickListener { showTransactionTips(forceShow = true) }
                addViewToEndSide(this, marginEnd)
            }
        }
    }

    private fun onNewAccountSelected(
        accountCacheData: AccountCacheData,
        assetInformation: AssetInformation,
        isLocked: Boolean
    ) {
        binding.accountAssetSelector.setAccountAndAsset(accountCacheData, assetInformation, isLocked)
        binding.amountInput.apply {
            binding.accountAssetSelector.getAssetBalance()?.run {
                maximumAssetAmountInAccount = this
            }
        }
    }

    private fun checkFromAccountTransactionRequirements(accountInformation: AccountInformation) {
        if (binding.amountInput.isAmountMax() &&
            binding.accountAssetSelector.getSelectedAsset()?.isAlgorand() == true
        ) {
            val shouldForceUserRemoveAssets = with(accountInformation) {
                getMinAlgoBalance() == binding.amountInput.amount &&
                    (isThereAnyDifferentAsset() || isThereAnOptedInApp())
            }
            if (shouldForceUserRemoveAssets) {
                hideLoading()
                context?.showAlertDialog(getString(R.string.warning), getString(R.string.in_order_to_delete))
                return
            }

            if (accountInformation.doesUserHasParticipationKey()) {
                context?.alertDialog {
                    setTitle(R.string.your_account_is_about)
                    setMessage(R.string.to_keep_an_account_open)
                    setPositiveButton(R.string.proceed) { dialog, _ ->
                        dialog.dismiss()
                        startFetchingToAccount()
                    }
                    setNegativeButton(R.string.cancel) { dialog, _ ->
                        dialog.dismiss()
                        hideLoading()
                    }
                }?.show()
            } else {
                startFetchingToAccount()
            }
        } else {
            startFetchingToAccount()
        }
    }

    private fun showTransactionTips(forceShow: Boolean) {
        if (forceShow || sendInfoViewModel.getFirstTransactionPreference()) {
            nav(actionSendInfoFragmentToTransactionTipsBottomSheet())
        }
    }

    private fun startFetchingToAccount() {
        val address = binding.addressInfoView.getToAddress()
        if (address.isValidAddress()) {
            sendInfoViewModel.fetchToAccountInformation(address)
        } else {
            hideLoading()
            showGlobalError(getString(R.string.the_recipient_address_is_not), getString(R.string.error))
        }
    }

    private fun checkToAccountTransactionRequirements(accountInformation: AccountInformation) {
        val selectedAsset = binding.accountAssetSelector.getSelectedAsset() ?: return
        val selectedAssetBalance = accountInformation.getBalance(selectedAsset.assetId)

        if (accountInformation.isAssetSupported(selectedAsset.assetId).not()) {
            val fromAddress = binding.accountAssetSelector.getSelectedAccountCacheData()?.account?.address
            val toAddress = binding.addressInfoView.getToAddress()
            val isThereAccountWithToAddress = accountManager.isThereAnyAccountWithPublicKey(toAddress)
            if (isThereAccountWithToAddress.not()) {
                sendInfoViewModel.sendAssetSupportRequest(toAddress, fromAddress, selectedAsset.assetId)
            }

            AssetActionBottomSheet.show(
                childFragmentManager,
                selectedAsset.assetId,
                if (isThereAccountWithToAddress) {
                    AssetActionBottomSheet.Type.UNSUPPORTED_ADD_TRY_LATER
                } else {
                    AssetActionBottomSheet.Type.UNSUPPORTED_INFO
                },
                asset = selectedAsset
            )

            hideLoading()
            return
        }

        if (selectedAsset.isAlgorand()) {
            val minBalance = accountInformation.getMinAlgoBalance()
            if (selectedAssetBalance + binding.amountInput.amount < minBalance) {
                context?.showAlertDialog(
                    getString(R.string.warning),
                    getString(R.string.you_re_trying_to_send, (minBalance - selectedAssetBalance).formatAsAlgoString())
                )
                hideLoading()
                return
            }
        }

        startSendingTransaction()
    }

    private fun startSendingTransaction() {
        val note = binding.noteEditText.text.toString().takeIf { it.isNotEmpty() }
        val contact = binding.addressInfoView.getSelectedContact()
        val accountAddressToSent = binding.addressInfoView.getToAddress()
        val selectedAccountCacheData = binding.accountAssetSelector.getSelectedAccountCacheData() ?: return
        val selectedAsset = binding.accountAssetSelector.getSelectedAsset() ?: return
        val minBalanceCalculatedAmount = getMinBalanceCalculatedAmount(selectedAccountCacheData)

        sendTransaction(
            TransactionData.Send(
                selectedAccountCacheData,
                minBalanceCalculatedAmount,
                selectedAsset,
                note,
                TargetUser(contact, accountAddressToSent)
            )
        )
    }

    private fun getMinBalanceCalculatedAmount(selectedAccountCacheData: AccountCacheData): BigInteger {
        val amountInput = binding.amountInput.amount
        return with(selectedAccountCacheData) {
            val minBalance = calculateMinBalance(accountInformation, true).toBigInteger()
            if (shouldKeepMinimumAlgoBalance()) amountInput - minBalance - MIN_FEE.toBigInteger() else amountInput
        }
    }

    private fun onPreviewButtonClick() {
        showLoading()

        val selectedAsset = binding.accountAssetSelector.getSelectedAsset()
        if (selectedAsset == null) {
            hideLoading()
            showSnackbar(getString(R.string.asset_must_be_selected), binding.rootConstraintLayout)
            return
        }
        val selectedAccount = binding.accountAssetSelector.getSelectedAccountCacheData()
        if (selectedAccount == null) {
            hideLoading()
            showSnackbar(getString(R.string.account_must_be_selected), binding.rootConstraintLayout)
            return
        }
        val publicAddress = binding.addressInfoView.getToAddress()
        if (publicAddress.isBlank()) {
            hideLoading()
            showSnackbar(getString(R.string.please_enter_a_destination), binding.rootConstraintLayout)
            return
        } else if (publicAddress.length < resources.getInteger(R.integer.account_public_key_character_limit)) {
            hideLoading()
            showSnackbar(getString(R.string.account_to_be_sent_must_have_58), binding.rootConstraintLayout)
            return
        }
        if (binding.amountInput.amount > assetBalance) {
            hideLoading()
            showSnackbar(getString(R.string.transaction_amount_cannot), binding.rootConstraintLayout)
            return
        }
        val selectedAddress = selectedAccount.account.address
        if (
            selectedAsset.isAlgorand() &&
            binding.amountInput.amount == assetBalance &&
            accountCacheManager.accountCacheMap.value[selectedAddress]?.isRekeyedToAnotherAccount() == true
        ) {
            hideLoading()
            nav(actionSendInfoFragmentToRekeyedMaximumBalanceWarningBottomSheet(selectedAddress))
            return
        }
        if (shouldKeepMinimumAlgoBalance()) {
            hideLoading()
            nav(actionSendInfoFragmentToTransactionMaximumBalanceWarningBottomSheet(selectedAddress))
            return
        }
        if (isCloseTransactionToSameAccount(selectedAccount, publicAddress, selectedAsset)) {
            hideLoading()
            showGlobalError(getString(R.string.you_can_not_send_your))
            return
        }

        sendInfoViewModel.fetchFromAccountInformation(selectedAccount.account.address)
    }

    private fun isCloseTransactionToSameAccount(
        fromAccount: AccountCacheData,
        toAccount: String,
        selectedAsset: AssetInformation
    ): Boolean {
        val isMax = binding.amountInput.amount == assetBalance
        val hasOnlyAlgo = with(fromAccount.accountInformation) {
            !isThereAnOptedInApp() || !isThereAnyDifferentAsset()
        }
        return fromAccount.account.address == toAccount && selectedAsset.isAlgorand() && isMax && hasOnlyAlgo
    }

    private fun shouldKeepMinimumAlgoBalance(): Boolean {
        val selectedAsset = binding.accountAssetSelector.getSelectedAsset()
        val selectedAccount = binding.accountAssetSelector.getSelectedAccountCacheData()
        val isThereAnotherAsset = selectedAccount?.accountInformation?.isThereAnyDifferentAsset() ?: false
        val isThereAppOptedIn = selectedAccount?.accountInformation?.isThereAnOptedInApp() ?: false
        return selectedAsset?.isAlgorand() == true && binding.amountInput.amount == assetBalance &&
            (isThereAnotherAsset || isThereAppOptedIn)
    }

    private val addressInfoViewListener = object : AddressInfoView.Listener() {
        override fun onMyAccountsClick() {
            binding.accountAssetSelector.hideKeyboard()
            nav(
                actionSendInfoFragmentToAccountSelectionBottomSheet(
                    selectedAssetInformation.assetId, R.string.select_receiving_account
                )
            )
        }

        override fun onScanQrCodeClick() {
            binding.addressInfoView.hideKeyboard()
            nav(
                SendInfoFragmentDirections.actionSendInfoFragmentToPublicKeyQrScannerFragment(
                    listOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK).toTypedArray()
                )
            )
        }

        override fun onContactsClick() {
            binding.addressInfoView.hideKeyboard()
            nav(actionSendInfoFragmentToContactSelectionBottomSheet())
        }
    }

    override fun onPause() {
        super.onPause()
        saveViewsState()
    }

    private fun restoreViewsStateIfPresent() {
        viewStatesBundle?.run {
            binding.amountInput.setBalance(getString(AMOUNT_VIEW_KEY)?.toBigIntegerOrNull() ?: BigInteger.ZERO)

            getParcelable<User>(CONTACT_INFO_VIEW_KEY).let { restoredContact ->
                if (restoredContact != null) {
                    binding.addressInfoView.setSelectedContact(restoredContact)
                } else {
                    getString(ADDRESS_INFO_VIEW_KEY)?.takeIf { it.isNotBlank() }?.let { restoredAddressInfo ->
                        binding.addressInfoView.setAddress(restoredAddressInfo)
                    }
                }
            }
        }
    }

    private fun saveViewsState() {
        viewStatesBundle = Bundle().apply {
            if (binding.amountInput.amount != BigInteger.ZERO) {
                putString(AMOUNT_VIEW_KEY, binding.amountInput.amount.toString())
            }

            if (binding.addressInfoView.getSelectedContact() != null) {
                putParcelable(CONTACT_INFO_VIEW_KEY, binding.addressInfoView.getSelectedContact())
            } else {
                val toAddress = binding.addressInfoView.getToAddress()
                putString(ADDRESS_INFO_VIEW_KEY, toAddress.takeIf { it.isNotBlank() })
            }
        }
    }

    private fun handleSendError(error: Resource.Error) {
        binding.rootConstraintLayout.hideKeyboard()
        hideLoading()
        showGlobalError(error.parse(requireContext()))
    }

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoadingFinished() {
            hideLoading()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            when (signedTransactionDetail) {
                is SignedTransactionDetail.Send -> {
                    nav(actionSendInfoFragmentToSendActionFragment(signedTransactionDetail))
                }
            }
        }
    }

    private fun showLoading() {
        binding.blockerLoading.root.visibility = View.VISIBLE
    }

    private fun hideLoading() {
        binding.blockerLoading.root.visibility = View.GONE
    }

    private fun updatePreviewButtonText(accountCacheData: AccountCacheData?) {
        val isThereAuthAddress = !accountCacheData?.authAddress.isNullOrBlank()
        val buttonText = if (isThereAuthAddress || accountCacheData?.account?.type == Account.Type.LEDGER) {
            R.string.preview_and_sign_with
        } else {
            R.string.preview
        }
        binding.previewButton.setText(buttonText)
    }

    private fun initNoteFieldObserver() {
        binding.noteEditText.addByteLimiter(NOTE_MAX_SIZE_IN_BYTE)
    }

    private fun setNodeUI(note: String, isNoteLocked: Boolean) {
        if (isNoteLocked) {
            with(binding.noteEditText) {
                isFocusable = false
                isEnabled = false
            }
        }
        binding.noteEditText.setText(note)
    }

    companion object {
        private const val NOTE_MAX_SIZE_IN_BYTE = 1024
        private const val AMOUNT_VIEW_KEY = "amount_view_key"
        private const val ADDRESS_INFO_VIEW_KEY = "address_info_view_key"
        private const val CONTACT_INFO_VIEW_KEY = "contact_info_view_key"
    }
}
