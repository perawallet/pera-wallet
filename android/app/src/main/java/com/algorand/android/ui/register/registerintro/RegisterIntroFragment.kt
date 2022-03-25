package com.algorand.android.ui.register.registerintro

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRegisterTypeSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RegisterIntroPreview
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openPrivacyPolicyUrl
import com.algorand.android.utils.openTermsAndServicesUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.launch

// TODO: 16.02.2022 login_navigation graph should be separated into multiple graphs
@AndroidEntryPoint
class RegisterIntroFragment : DaggerBaseFragment(R.layout.fragment_register_type_selection) {

    private val registerIntroViewModel: RegisterIntroViewModel by viewModels()

    private val binding by viewBinding(FragmentRegisterTypeSelectionBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.primaryBackground)

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        statusBarConfiguration = statusBarConfiguration
    )

    private val registerIntroPreviewCollector: suspend (RegisterIntroPreview) -> Unit = {
        binding.titleTextView.setText(it.titleRes)
        configureToolbar(it.isCloseButtonVisible, it.isSkipButtonVisible)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        checkIfNavigateToRegisterWatchAccount()
        initUi()
        initObservers()
    }

    private fun checkIfNavigateToRegisterWatchAccount() {
        if (registerIntroViewModel.getShouldNavToRegisterWatchAccount()) {
            nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToRegisterWatchAccountFragment())
        }
    }

    private fun initUi() {
        with(binding) {
            createAccountSelectionItem.setOnClickListener { navToAddAccountTypeSelectionFragment() }
            recoveryAccountSelectionItem.setOnClickListener { navToAccountRecoveryTypeSelectionFragment() }
        }
        setupPolicyText()
    }

    fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            registerIntroViewModel.registerIntroPreviewFlow.filterNotNull().collectLatest(registerIntroPreviewCollector)
        }
    }

    private fun navToAddAccountTypeSelectionFragment() {
        nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToAddAccountTypeSelectionFragment())
    }

    private fun navToAccountRecoveryTypeSelectionFragment() {
        nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToAccountRecoveryTypeSelectionFragment())
    }

    private fun configureToolbar(isCloseButtonVisible: Boolean, isSkipButtonVisible: Boolean) {
        getAppToolbar()?.let { toolbar ->
            if (isCloseButtonVisible) {
                toolbar.configureStartButton(R.drawable.ic_close, ::navBack)
            }
            if (isSkipButtonVisible) {
                toolbar.addButtonToEnd(TextButton(R.string.skip, onClick = ::onSkipClick))
            }
        }
    }

    private fun setupPolicyText() {
        binding.policyTextView.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.linkPrimary)
            val termAndConditionsString = AnnotatedString(
                stringResId = R.string.by_creating_account,
                customAnnotationList = listOf(
                    "terms_click" to getCustomClickableSpan(linkTextColor) { context?.openTermsAndServicesUrl() },
                    "privacy_click" to getCustomClickableSpan(linkTextColor) { context?.openPrivacyPolicyUrl() }
                )
            )
            highlightColor = ContextCompat.getColor(context, R.color.transparent)
            movementMethod = LinkMovementMethod.getInstance()
            text = context.getXmlStyledString(termAndConditionsString)
        }
    }

    private fun onSkipClick() {
        registerIntroViewModel.setRegisterSkip()
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }
}
