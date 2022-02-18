package com.algorand.android.ui.register.addaccounttypeselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAddAccountTypeSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RegisterFlowType
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.addaccounttypeselection.AddAccountTypeSelectionFragmentDirections.Companion.actionAddAccountTypeSelectionFragmentToBackupInfoFragment
import com.algorand.android.ui.register.addaccounttypeselection.AddAccountTypeSelectionFragmentDirections.Companion.actionAddAccountTypeSelectionFragmentToPairLedgerNavigation
import com.algorand.android.ui.register.addaccounttypeselection.AddAccountTypeSelectionFragmentDirections.Companion.actionAddAccountTypeSelectionFragmentToWatchAccountInfoFragment
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AddAccountTypeSelectionFragment : DaggerBaseFragment(R.layout.fragment_add_account_type_selection) {

    private val binding by viewBinding(FragmentAddAccountTypeSelectionBinding::bind)

    private val addAccountTypeSelectionViewModel: AddAccountTypeSelectionViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
        backgroundColor = R.color.primaryBackground
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        binding.createNewAccountSelectionItem.setOnClickListener {
            onRegisterTypeSelected(RegisterFlowType.CREATE_WITH_PASSPHRASE)
        }
        binding.pairLedgerSelectionItem.setOnClickListener {
            onRegisterTypeSelected(RegisterFlowType.PAIR_LEDGER)
        }
        binding.watchAccountSelectionItem.setOnClickListener {
            onRegisterTypeSelected(RegisterFlowType.WATCH)
        }
    }

    private fun setupToolbar() {
        if (addAccountTypeSelectionViewModel.hasAccount().not()) {
            getAppToolbar()?.addButtonToEnd(TextButton(R.string.skip, onClick = ::onSkipClick))
        }
    }

    private fun onSkipClick() {
        addAccountTypeSelectionViewModel.setRegisterSkip()
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }

    private fun onRegisterTypeSelected(registerFlowType: RegisterFlowType) {
        when (registerFlowType) {
            RegisterFlowType.CREATE_WITH_PASSPHRASE -> {
                nav(actionAddAccountTypeSelectionFragmentToBackupInfoFragment())
            }
            RegisterFlowType.PAIR_LEDGER -> {
                nav(actionAddAccountTypeSelectionFragmentToPairLedgerNavigation())
            }
            RegisterFlowType.WATCH -> {
                nav(actionAddAccountTypeSelectionFragmentToWatchAccountInfoFragment())
            }
        }
    }
}
