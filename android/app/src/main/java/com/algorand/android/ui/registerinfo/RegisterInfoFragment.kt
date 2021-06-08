package com.algorand.android.ui.registerinfo

import android.os.Bundle
import android.text.style.ForegroundColorSpan
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import androidx.annotation.RawRes
import androidx.annotation.StringRes
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentRegisterInfoBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.registerinfo.RegisterInfoFragmentDirections.Companion.actionRegisterInfoFragmentSelf
import com.algorand.android.ui.registerinfo.RegisterInfoFragmentDirections.Companion.actionRegisterInfoFragmentToBackupPassphraseFragment
import com.algorand.android.ui.registerinfo.RegisterInfoFragmentDirections.Companion.actionRegisterInfoFragmentToRecoverWithPassphraseFragment
import com.algorand.android.ui.registerinfo.RegisterInfoFragmentDirections.Companion.actionRegisterInfoFragmentToRegisterWatchAccountFragment
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.viewbinding.viewBinding

class RegisterInfoFragment : BaseFragment(R.layout.fragment_register_info) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentRegisterInfoBinding::bind)

    private val args by navArgs<RegisterInfoFragmentArgs>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(args.type) {
            binding.titleTextView.setText(titleTextResId)
            setDescription(descriptionTextResId)
        }
        configureToolbar()
        setupNextButton()
        setupLottieAnimationView()
    }

    private fun setDescription(descriptionTextResId: Int) {
        binding.descriptionTextView.apply {
            val warningColor = ContextCompat.getColor(context, R.color.red_E9)
            text = context.getXmlStyledString(
                stringResId = descriptionTextResId,
                customAnnotations = listOf("warning_color" to ForegroundColorSpan(warningColor))
            )
        }
    }

    private fun setupNextButton() {
        binding.nextButton.setText(args.type.buttonTextResId)
        binding.nextButton.setOnClickListener { navigateNext() }
    }

    private fun setupLottieAnimationView() {
        binding.lottieAnimationView.apply {
            setAnimation(args.type.animationResId)
            playAnimation()
        }
    }

    private fun configureToolbar() {
        if (args.type.infoUrl.isNullOrEmpty().not()) {
            getAppToolbar()?.apply {
                val infoButton = LayoutInflater
                    .from(context)
                    .inflate(R.layout.custom_icon_tab_button, this, false) as ImageButton

                infoButton.apply {
                    setImageResource(R.drawable.ic_info)
                    setOnClickListener { onInfoClick() }
                    addViewToEndSide(this)
                }
            }
        }
    }

    private fun onInfoClick() {
        args.type.infoUrl?.let { safeInfoUrl ->
            context?.openUrl(safeInfoUrl)
        }
    }

    private fun navigateNext() {
        nav(
            when (args.type) {
                Type.BACKUP -> actionRegisterInfoFragmentSelf(Type.WRITE_DOWN)
                Type.WRITE_DOWN -> actionRegisterInfoFragmentToBackupPassphraseFragment()
                Type.WATCH -> actionRegisterInfoFragmentToRegisterWatchAccountFragment()
                Type.RECOVERY -> actionRegisterInfoFragmentToRecoverWithPassphraseFragment()
            }
        )
    }

    enum class Type(
        @RawRes val animationResId: Int,
        @StringRes val titleTextResId: Int,
        @StringRes val descriptionTextResId: Int,
        @StringRes val buttonTextResId: Int,
        val infoUrl: String? = null
    ) {
        BACKUP(
            animationResId = R.raw.shield_animation,
            titleTextResId = R.string.back_up_your_account,
            descriptionTextResId = R.string.without_your_recovery,
            buttonTextResId = R.string.i_understand,
            infoUrl = "https://algorandwallet.com/support/security/backing-up-your-recovery-passphrase"
        ),
        WRITE_DOWN(
            animationResId = R.raw.pen_animation,
            titleTextResId = R.string.prepare_to_write,
            descriptionTextResId = R.string.the_only_way_to,
            buttonTextResId = R.string.im_ready_to_begin
        ),
        WATCH(
            animationResId = R.raw.watch_animation,
            titleTextResId = R.string.watch_account,
            descriptionTextResId = R.string.monitor_activity_of,
            buttonTextResId = R.string.create_a_watch,
            infoUrl = "https://algorandwallet.com/support/general/adding-a-watch-account"
        ),
        RECOVERY(
            animationResId = R.raw.recovery_passphrase_animation,
            titleTextResId = R.string.recover_an_algorand,
            descriptionTextResId = R.string.in_the_following,
            buttonTextResId = R.string.recover_an_algorand,
            infoUrl = "https://algorandwallet.com/support/getting-started/recover-an-algorand-account"
        )
    }
}
