fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### bump_version

```sh
[bundle exec] fastlane bump_version
```

Bump the marketing version. Pass bump:patch (default), bump:minor, or bump:major

### bump_build

```sh
[bundle exec] fastlane bump_build
```

Bump only the build number (used before each beta upload)

----


## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture App Store screenshots

### ios make_screenshots

```sh
[bundle exec] fastlane ios make_screenshots
```

Generate new localized screenshots

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

### ios update_screenshots

```sh
[bundle exec] fastlane ios update_screenshots
```

Delete and upload new localized screenshots

### ios screenshots_and_upload

```sh
[bundle exec] fastlane ios screenshots_and_upload
```

Generate screenshots and upload them to App Store Connect

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build a signed release .ipa and upload it to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Capture screenshots, attach a TestFlight build, and submit for review

### ios release_submit_only

```sh
[bundle exec] fastlane ios release_submit_only
```

Submit existing metadata with explicit build (skip metadata upload)

### ios full_release

```sh
[bundle exec] fastlane ios full_release
```

Run patch bump, TestFlight upload, then App Store submission

### ios delete_all_screenshots

```sh
[bundle exec] fastlane ios delete_all_screenshots
```

Delete all screenshots from App Store Connect

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
