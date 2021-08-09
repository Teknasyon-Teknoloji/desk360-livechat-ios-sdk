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
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios clean
```
fastlane ios clean
```
Clean any generated Xcode project and pods
### ios generate
```
fastlane ios generate
```
Generate Xcode project and install dependencies
### ios release
```
fastlane ios release
```
Release a new version of LiveChat
### ios increment
```
fastlane ios increment
```
Increment Version
### ios tests
```
fastlane ios tests
```
Runs tests
### ios compatibilityTests
```
fastlane ios compatibilityTests
```
Run Dependency-Manager compatibility tests

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
