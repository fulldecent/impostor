# Impostor

This is the Impostor iOS game.

Available on the App Store: <https://apps.apple.com/us/app/whos-the-impostor/id784258202?uo=4>

## Releasing a new version

This project uses fastlane and App Store Connect API key authentication for release automation.

### One-time setup

1. Install the Ruby version from `.ruby-version` and install dependencies:

```sh
bundle install
```

1. Create `fastlane/api_key.json`:

```json
{
  "key_id": "ABCD123456",
  "issuer_id": "00000000-0000-0000-0000-000000000000",
  "key_filepath": "/absolute/path/to/AuthKey_ABCD123456.p8"
}
```

### Recommended release flow

Run a complete non-interactive release:

```sh
bundle exec fastlane ios full_release notes:"Bug fixes and performance improvements."
```

Or run each stage separately:

```sh
bundle exec fastlane bump_version                # bump:patch (default), bump:minor, bump:major
bundle exec fastlane ios beta                    # builds and uploads to TestFlight
bundle exec fastlane ios screenshots             # capture screenshots
bundle exec fastlane ios upload_screenshots      # upload screenshots only
bundle exec fastlane ios release notes:"Bug fixes and performance improvements."
```

Useful options:

- Pin a build number during beta or release: `build_number:123`
- Skip screenshot recapture during release: `screenshots:false`
