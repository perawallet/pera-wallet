fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios staging
```
fastlane ios staging
```
Upload Staging Application To Tryouts
### ios staging_dev
```
fastlane ios staging_dev
```
Sign Staging Development Application
### ios preprod
```
fastlane ios preprod
```
Upload Preprod Application To Tryouts
### ios preprod_dev
```
fastlane ios preprod_dev
```
Sign Preprod Development Application
### ios prod
```
fastlane ios prod
```
Upload Production Application To Tryouts
### ios prod_dev
```
fastlane ios prod_dev
```
Sign Production Development Application
### ios beta_in_house
```
fastlane ios beta_in_house
```
Upload Staging&Prod Applications To Tryouts
### ios beta
```
fastlane ios beta
```
Upload Beta To TestFlight
### ios release
```
fastlane ios release
```
Upload Release to AppStore

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
