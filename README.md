# Impostor

This is the Impostor iOS game.

Available on the App Store: <https://apps.apple.com/us/app/whos-the-impostor/id784258202?uo=4>

## Releasing

Use `fix:`, `feat:` or `BREAKING CHANGE:` in commit messages. Release Please opens a pull request from those. `ci:` and `chore:` do not. Merging that pull request submits the iOS app for App Store review. Do not edit [VERSION](VERSION) or the marketing version by hand. Impostor does not ship a Mac build.

Every push to `main` runs the tests and uploads an iOS build to TestFlight. It goes to the internal group App Store Connect Users for this app. The Apple ID has to accept the invitation before the build appears. The marketing version comes from [VERSION](VERSION). When that version is already on sale, the upload uses the next patch and does not commit it. The review submission uses the version that was uploaded. The build number is chosen at upload time and is not committed.

Store text lives in [fastlane/metadata](fastlane/metadata). Screenshots are generated at release time and are not committed. What's New is the newest section of [CHANGELOG.md](CHANGELOG.md).

Release Please opens its pull request as `github-actions`. GitHub holds those checks until a person approves the workflow run.

This follows [swift-app-template](https://github.com/fulldecent/swift-app-template) release 1.1.0 and the release workflow used by [8 Ball Answer](https://github.com/fulldecent/8-ball-answer).

### Setup

1. GitHub repo > Settings > Actions > General > Workflow permissions: Read and write permissions. Check "Allow GitHub Actions to create and approve pull requests".
1. Sign the Apple Developer Program agreement.
1. Repository secrets:

   * `APP_STORE_CONNECT_KEY_ID`
   * `APP_STORE_CONNECT_ISSUER_ID`
   * `APP_STORE_CONNECT_KEY`
   * `APP_STORE_DISTRIBUTION_P12`
   * `APP_STORE_DISTRIBUTION_P12_PASSWORD`

The workflow creates the iOS provisioning profile at build time.

App Privacy, and whether the app uses the Advertising Identifier, stay in App Store Connect. fastlane sends the encryption answer and the third-party content answer.
