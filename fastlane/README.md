fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios make_screenshots

```sh
[bundle exec] fastlane ios make_screenshots
```

Generate new localized screenshots

### ios update_screenshots

```sh
[bundle exec] fastlane ios update_screenshots
```

Delete and upload new localized screenshots

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit a new app version to the App Store

### ios delete_all_screenshots

```sh
[bundle exec] fastlane ios delete_all_screenshots
```

Delete all screenshots from App Store Connect

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
