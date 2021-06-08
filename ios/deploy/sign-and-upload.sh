#!/bin/bash --login

die() {
    echo "$*" >&2
    exit 1
}

if [[ $BINARY_NAME == "" ]]; then
	BINARY_NAME="$APP_NAME"
fi

if [[ $SIM_BINARY_NAME == "" ]]; then
	SIM_BINARY_NAME="$APP_NAME"
fi

OUTPUT_PATH="$PWD/build/Release-iphoneos"
APP_PATH="$OUTPUT_PATH/$BINARY_NAME.app"
IPA_PATH="$OUTPUT_PATH/$BINARY_NAME.ipa"
APP_ARCHIVE_PATH="$OUTPUT_PATH/$BINARY_NAME.xcarchive"
PROVISION_PATH="$PWD/build/$PROFILE_NAME.mobileprovision"

rm -rf "$OUTPUT_PATH"
mkdir -p "$OUTPUT_PATH"


if [ $ENFORCE_RELEASE == true ] ; then
  echo "***************************"
  echo "*    ENFORCE RELEASE      *"
  echo "***************************"

  git checkout -f $RELEASE_BRANCH
  
  RELEASE_TAG=`git describe --exact-match --abbrev=0 --tags`

  if [[ $RELEASE_TAG == "" ]]; then
    RELEASE_TAG=`git describe HEAD^1 --abbrev=0 --tags`
  fi

  if [[ $RELEASE_TAG == "" ]]; then
    echo "No tags found, cannot enforce release"
    exit 0
  fi

  git checkout -f $RELEASE_TAG
fi

RELEASE_MODE=true

CURRENT_TAG=`git describe --exact-match --abbrev=0 --tags`

if [[ $CURRENT_TAG == "" ]]; then
  RELEASE_MODE=false
fi


echo "***************************"
echo "*  Updating Dependencies  *"
echo "***************************"

/usr/local/bin/pod repo update
/usr/local/bin/pod install --project-directory="$PROJECT_DIRECTORY"


echo "***************************"
echo "*         Cleaning        *"
echo "***************************"

if [ ! -z "$XCODE_WORKSPACE_PATH" ] ; then
  /usr/bin/xcodebuild \
    -workspace "$XCODE_WORKSPACE_PATH" \
    -scheme "$XCODE_SCHEME" \
    -configuration "$XCODE_CONFIG" \
    -UseModernBuildSystem=NO \
    -quiet \
    clean || die "Clean failed"
else
  /usr/bin/xcodebuild \
    -project "$XCODE_PROJECT_PATH" \
    -scheme "$XCODE_SCHEME" \
    -configuration "$XCODE_CONFIG" \
    -UseModernBuildSystem=NO \
    -quiet \
    clean || die "Clean failed"
fi


echo "***************************"
echo "*    Generating Profile   *"
echo "***************************"

./deploy/resign_with_device.rb \
  tryouts-app-id="$TRYOUTS_APP_ID" \
  tryouts-token="$TRYOUTS_APP_TOKEN" \
  itunes-token="$ITUNES_TOKEN" \
  team-id="$TEAM_ID" \
  app-name="$APP_NAME" \
  profile-name="$PROFILE_NAME" \
  bundle-identifier="$APP_BUNDLE_IDENTIFIER" \
  provision-output-path="$PROVISION_PATH"

PROVISIONING_UUID=`cat "$PROVISION_PATH"_uuid`
PROVISION_INSTALL_PATH="$HOME/Library/MobileDevice/Provisioning Profiles/$PROVISIONING_UUID.mobileprovision"

cp "$PROVISION_PATH" "$PROVISION_INSTALL_PATH"

if [ ! -z "$NOTIFICATIONS_BUNDLE_IDENTIFIER" ] ; then
  echo "*****************************************"
  echo "*    Generating Notification Profile    *"
  echo "*****************************************"
  
  NOTIFICATIONS_PROVISION_PATH="$PWD/build/$NOTIFICATIONS_PROFILE_NAME.mobileprovision"
  
  ./deploy/resign_with_device.rb \
    tryouts-app-id="$TRYOUTS_APP_ID" \
    tryouts-token="$TRYOUTS_APP_TOKEN" \
    itunes-token="$ITUNES_TOKEN" \
    team-id="$TEAM_ID" \
    app-name="$APP_NAME Notifications" \
    profile-name="$NOTIFICATIONS_PROFILE_NAME" \
    bundle-identifier="$NOTIFICATIONS_BUNDLE_IDENTIFIER" \
    provision-output-path="$NOTIFICATIONS_PROVISION_PATH"

  NOTIFICATIONS_PROVISIONING_UUID=`cat "$NOTIFICATIONS_PROVISION_PATH"_uuid`
  NOTIFICATIONS_PROVISION_INSTALL_PATH="$HOME/Library/MobileDevice/Provisioning Profiles/$NOTIFICATIONS_PROVISIONING_UUID.mobileprovision"

  cp "$NOTIFICATIONS_PROVISION_PATH" "$NOTIFICATIONS_PROVISION_INSTALL_PATH"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
rvm use system

if [ $RELEASE_MODE == false ] ; then
  
  echo "***************************"
  echo "*        Compiling        *"
  echo "***************************"

  if [ ! -z "$XCODE_WORKSPACE_PATH" ] ; then
    /usr/bin/xcodebuild \
      -workspace "$XCODE_WORKSPACE_PATH" \
      -scheme "$XCODE_SCHEME" \
      -configuration "$XCODE_CONFIG" \
      -UseModernBuildSystem=NO \
      -sdk iphoneos \
      -quiet \
      CODE_SIGN_IDENTITY="$DEVELOPER_NAME" || die "Compiler failed"
  else
    /usr/bin/xcodebuild \
      -project "$XCODE_PROJECT_PATH" \
      -scheme "$XCODE_SCHEME" \
      -configuration "$XCODE_CONFIG" \
      -UseModernBuildSystem=NO \
      -sdk iphoneos \
      -quiet \
      CODE_SIGN_IDENTITY="$DEVELOPER_NAME" || die "Compiler failed"
  fi

else

  echo "***************************"
  echo "*       Archiving         *"
  echo "***************************"

  if [ ! -z "$XCODE_WORKSPACE_PATH" ] ; then
    /usr/bin/xcodebuild \
      -workspace "$XCODE_WORKSPACE_PATH" \
      -scheme "$XCODE_SCHEME" \
      -configuration "$XCODE_CONFIG" \
      -UseModernBuildSystem=NO \
      -sdk iphoneos \
      -quiet \
      ONLY_ACTIVE_ARCH=NO \
      CODE_SIGN_IDENTITY="$DEVELOPER_NAME" \
      PROVISIONING_PROFILE="$PROVISIONING_UUID" \
      archive -archivePath "$APP_ARCHIVE_PATH" || die "Compiler failed"
  else
    /usr/bin/xcodebuild \
      -project "$XCODE_PROJECT_PATH" \
      -scheme "$XCODE_SCHEME" \
      -configuration "$XCODE_CONFIG" \
      -UseModernBuildSystem=NO \
      -sdk iphoneos \
      -quiet \
      ONLY_ACTIVE_ARCH=NO \
      CODE_SIGN_IDENTITY="$DEVELOPER_NAME" \
      PROVISIONING_PROFILE="$PROVISIONING_UUID" \
      archive -archivePath "$APP_ARCHIVE_PATH" || die "Compiler failed"
  fi

  echo "***************************"
  echo "*        Signing          *"
  echo "***************************"
  
  EXPORT_OPTIONS_PATH="$PWD/export_options.plist"
  
  if [ ! -z "$NOTIFICATIONS_BUNDLE_IDENTIFIER" ] ; then
    /usr/bin/awk "{sub(/{$APP_BUNDLE_IDENTIFIER}/,\"$PROVISIONING_UUID\");sub(/{$NOTIFICATIONS_BUNDLE_IDENTIFIER}/,\"$NOTIFICATIONS_PROVISIONING_UUID\")}1" \
      "$PWD/deploy/export_options.plist" > "$EXPORT_OPTIONS_PATH"
  else
    /usr/bin/awk "{sub(/{$APP_BUNDLE_IDENTIFIER}/,\"$PROVISIONING_UUID\")}1" \
      "$PWD/deploy/export_options.plist" > "$EXPORT_OPTIONS_PATH"
  fi

  /usr/bin/xcodebuild -exportArchive \
    -archivePath "$APP_ARCHIVE_PATH" \
    -exportPath "$OUTPUT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PATH" || die "Signing failed"

  rm -f "$PROVISION_INSTALL_PATH"
  rm -f "$EXPORT_OPTIONS_PATH"

  if [ ! -z "$NOTIFICATIONS_BUNDLE_IDENTIFIER" ] ; then
    rm -f "$NOTIFICATIONS_PROVISION_INSTALL_PATH"
  fi


  echo "***************************"
  echo "*    Generating Notes     *"
  echo "***************************"

  PREVIOUS_TAG=`git describe HEAD^1 --abbrev=0 --tags`
  GIT_HISTORY=`git log --no-merges --format="- %s" $PREVIOUS_TAG..HEAD`

  if [[ $PREVIOUS_TAG == "" ]]; then
    GIT_HISTORY=`git log --no-merges --format="- %s"`
  fi

  echo "Current Tag: $CURRENT_TAG"
  echo "Previous Tag: $PREVIOUS_TAG"
  echo "Release Notes:

  $GIT_HISTORY"

  RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
  RELEASE_NOTES="Build: $CURRENT_TAG
  Uploaded: $RELEASE_DATE

  $GIT_HISTORY"


  if [ ! -z "$TRYOUTS_APP_ID" ] && [ ! -z "$TRYOUTS_APP_TOKEN" ]; then
    echo ""
    echo "***************************"
    echo "*   Uploading to Tryouts  *"
    echo "***************************"

    curl https://tryouts.io/applications/$TRYOUTS_APP_ID/upload/ \
      -F status="2" \
      -F notify="0" \
      -F notes="$RELEASE_NOTES" \
      -F build="@$IPA_PATH" \
      -H "Authorization: $TRYOUTS_APP_TOKEN"
  fi
  
  if [ ! -z "$DEPLOY_TEST_AUTOMATION" ]; then
  	echo ""
  	echo "*****************************"
  	echo "* Uploading to device test  *"
  	echo "*****************************"

  	scp -P 21229 "$IPA_PATH" hipotest@1.tcp.eu.ngrok.io:~/Desktop/Releases/$BINARY_NAME.ipa

  	/usr/bin/curl -X POST "http://testrunner.hipolabs.com/job/fieldguide-preprod-ios/build?token=fieldguide-ios" \
  	  --user hipotest:hipohipo
  fi
  
fi

