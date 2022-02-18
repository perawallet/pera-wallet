
# Building the Pera Wallet Apps

Some modifications are needed in order to build the applications from this repo. This document
explains all of the steps needed to build the applications and run them in a simulator.

## Common Steps

1. **Clone this repo:** Clone or download this repo to your computer.

2. **Obtain network access:** The apps need access to instances of [Algod](https://github.com/algorand/go-algorand) and
[Indexer](https://github.com/algorand/indexer) in order to run. The official app supports MainNet
and TestNet, however any networks can be used if you supply your own node. For a private network,
the quickest way to get started is by using the [Algorand sandbox](https://github.com/algorand/sandbox).
[This page from the Algorand developer docs](https://developer.algorand.org/docs/build-apps/setup/#how-do-i-obtain-an-algod-address-and-token)
contains more options. Regardless of how you obtain access to instances of Algod and Indexer, you
will need their addresses and API keys to continue.

3. **Create a Firebase project:** Because the apps use Firebase, you will need to create your own
Firebase project for them to run. See [the Firebase docs](https://firebase.google.com/docs/projects/learn-more#setting_up_a_firebase_project_and_registering_apps)
for further instructions.

After these steps are complete, you are ready to move on to specific steps for iOS or Android.

## iOS Steps

> Note: these steps must be ran from a macOS machine.

1. **Install dependencies:** First, install Cocoapods if you do not already have it. See https://guides.cocoapods.org/using/getting-started.html
for more information. Once you have Cocoapods installed, navigate to the `ios` folder and run the
following command to install build dependencies:

```bash
pod install
```

2. **Open in Xcode:** At this point you may now open the `ios/algorand.xcworkspace` workspace file in Xcode.

3. **Download the iOS Firebase config file:** The Firebase config file for iOS is called `GoogleService-Info.plist`.
See this link for how to obtain the config file: https://support.google.com/firebase/answer/7015592.
Once you've downloaded it, place it in the location `ios/Support/GoogleService-Info.plist`.

4. **Specify network access tokens:** In order to tell the app how to access Algod and Indexer, create
the file `ios/Support/Config.xcconfig`. This file needs to define two values, `ALGOD_TOKEN` and
`INDEXER_TOKEN`, which are the API tokens for Algod and Indexer respectively. For example, this is
how to create a config file from the command line where the Algod token is `aaa` and the Indexer
token is `bbb`:

```bash
echo "ALGOD_TOKEN = aaa\nINDEXER_TOKEN = bbb" > ios/Support/Config.xcconfig
```

5. **Specify network addresses:** You will need to change the default addresses for Algod and Indexer
in the file `ios/Classes/Core/Environment/Environment.swift`. The variables to change are
`testNetAlgodApi`, `testNetIndexerApi`, `mainNetAlgodApi`, and `mainNetIndexerApi`. For example, if
your Algod address is `http://localhost:4001` and your Indexer address is `http://localhost:8980`,
the following changes need to be made for the MainNet variables (the TestNet variables can be
similarly changed):

```diff
-    lazy var mainNetAlgodHost = "node-mainnet.aws.algodev.network"
-    lazy var mainNetIndexerHost = "indexer-mainnet.aws.algodev.network"
-    lazy var mainNetAlgodApi = "\(schema)://\(mainNetAlgodHost)"
-    lazy var mainNetIndexerApi = "\(schema)://\(mainNetIndexerHost)"
+    lazy var mainNetAlgodHost = "localhost:4001"
+    lazy var mainNetIndexerHost = "localhost:8980"
+    lazy var mainNetAlgodApi = "http://\(mainNetAlgodHost)"
+    lazy var mainNetIndexerApi = "http://\(mainNetIndexerHost)"
```

> Note: it's ok to use a localhost address in the simulator, but that address will not work if you deploy to an actual device.

6. **Build the app:** Once all the above steps are complete, you are ready to build and deploy the
iOS app in Xcode.

## Android Steps

1. **Download the Android Firebase config file:** The Firebase config file for Android is called `google-services.json`.
See this link for how to obtain the config file: https://support.google.com/firebase/answer/7015592.
Once you've downloaded it, place it in the location `android/app/google-services.json`.

2. **Define network access tokens:** In order to tell the app how to access Algod and Indexer, you
will need to create an `api-key.properties` file. This file must be placed in two places:
`android/app/src/prod/api-key.properties` and `android/app/src/staging/api-key.properties`. This
file needs to define two values, `ALGORAND_API_KEY` and `INDEXER_API_KEY`, which are the API tokens
for Algod and Indexer respectively. For example, this is how to create the config files from the
command line where the Algod token is `aaa` and the Indexer token is `bbb`:

```bash
echo "ALGORAND_API_KEY=\"aaa\"\nINDEXER_API_KEY=\"bbb\"" > android/app/src/prod/api-key.properties
cp android/app/src/prod/api-key.properties android/app/src/staging/api-key.properties
```

3. **Specify network addresses:** You will need to change the default addresses for Algod and Indexer
in two files: `android/app/src/staging/java/com/algorand/android/utils/NodeList.kt` and `android/app/src/prod/java/com.algorand.android/utils/NodeList.kt`. The variables to change are `algodAddress` and `indexerAddress` for the MainNet and TestNet objects.
For example, if your Algod address is `http://localhost:4001` and your Indexer address is `http://localhost:8980`,
the following changes need to be made for the MainNet variables (the TestNet variables can be
similarly changed):

> Remember to make this change in both of the `NodeList.kt` files!

```diff
     Node(
         name = "MainNet",
-        algodAddress = "https://node-mainnet.aws.algodev.network/",
+        algodAddress = "http://localhost:4001",
         algodApiKey = BuildConfig.ALGORAND_API_KEY,
-        indexerAddress = "https://indexer-mainnet.aws.algodev.network/",
+        indexerAddress = "http://localhost:8980",
         indexerApiKey = BuildConfig.INDEXER_API_KEY,
         isActive = true,
         isAddedDefault = true,
         networkSlug = MAINNET_NETWORK_SLUG
     ),
```

> Note: it's ok to use a localhost address in the simulator, but that address will not work if you deploy to an actual device.

4. **Build the app:** Once all the above steps are complete, you are ready to build and deploy the
Android app.
