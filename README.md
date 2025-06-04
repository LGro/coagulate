# Coagulate

Coagulate is a smartphone app to synchronize contact details and share current as well as future locations in a privacy preserving manner for everyone who wants to stay in touch with their peers.

When you plan to visit a city, find out immediately who of your old friends you could meet and directly contact them with up-to-date contact details.

**Features:**
- You can connect with existing contacts in an end-to-end encrypted manner to securely and privately keep each others' contact details up-to-date, right in your smartphone's address book.
- As soon as your contacts start sharing their addresses, current or future locations, you can see them on a map to plan your travels and coordinate meeting people you care about.
- You can personalize what you share with whom so that colleagues, friends and lovers each stay up-to-date on what you want them to know and nothing else.

This [Flutter](flutter.dev) based implementation is derived from [VeilidChat](https://gitlab.com/veilid/veilidchat/).
Accordingly, the Copyright to all code files belongs to the Veilid developers unless explicitly stated otherwise.

## Development Setup

While this is still in development, you must have a clone of the [Veilid](https://gitlab.com/veilid/veilid/) source checked out at `../veilid` relative to the working directory of this repository.

Check the CI/CD workflows in `.github/` for a compatible development setup.

For the address search and geocoding to work, you need to provide the environment variable `COAGULATE_MAPTILER_TOKEN` with an API token that can be obtained for free from maptiler.com.
The map itself can also be switched to the OSM foundation's server if no MapTiler token is available.

### Building

```
flutter clean
flutter pub get
flutter run -d <DEVICE-ID>
```

To (re-)generate all code from templates, run
```
dart run build_runner build
```

To (re-)generate app icons for all target platforms, run
```
dart run flutter_launcher_icons
```

### Testing

Using `lcov`, run:
```
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

```

### Fastlane

For Fastlane setup see https://docs.fastlane.tools/

Based on the Gemfile of this repo, you can get fastlane with
```
bundle update
```

### Misc

For iOS when changing e.g. the `IPHONEOS_DEPLOYMENT_TARGET`, cd into `ios/` and run `pod update`.

## Original User Stories

These where the initial user stories written before the development of Coagulate began.
They serve as a reminder and reference to what experience we aim to achieve.

### Open app first time

I'd like to set up my profile with all the contact information I want to publish.
I'd like to define different scopes that can see different subsets of my contact information to shape what is shared with others.

I'd like to see my contacts list with all already securely connected contacts that also have the app.
If that's not possible, see highlighted / at top who has the app - not connected yet.
If that's not possible, can I at least see most of them after I've connected with the first peer?

### Connect

When I click on a contact that I haven't shared with yet, I'd like to see a share menu for all encrypted messengers where I can share the sharing link.

When my contact accepts the invitation and shares with me, I'd like to see that highlighted.

When someone sends me a share code, I'd like to click on it and have the app automatically pick it up. It should then also ask me if I want to share back and if I say yes automatically do so.

After sharing is recognized in the app, I'd like the respective information to be updated.

### See the map

I'd like to see a map where all the locations of my contacts are displayed.
Locations by the same contact should be visually grouped somehow?!

When I click on a pin on the map I'd like to see their name
when I zoom close enough I might also already want to see the initials or name

### Recovery

When I loose my phone, I'd like to be able to tell four of my trusted contacts.
They should then send me a message, which opens in the app. And after I've received all four, everything should be restored.

### My updates

When I update my profile, I'd like all contacts I've shared with to receive the updated information without any unauthorized 3rd party being able to see the update or tie my social network to me / infer the social network.
I'd like to also see which of my contacts already received my update.

### Unshare

When I decide to stop sharing with someone, I'd like them not not be notified and for them to stop receiving any future updates.

### Others updates

When ever someone else updates their profile, I'd like to get all the information, even if I'm not online at the same time and without unauthorized parties seeing the details.

### Higher avail / federation

I would like to set up an always on node that I can configure to replicate everything my mobile node replicates.

### Privacy

I'd like nobody to be able to discover my social graph or the contact details I share if they are not intended for them.
I'd also like to remain anonymous to the peers I do not share my contact details with.

## App links

Scan QR code  
-> `/c/#name~typedRecordKey~psk`

Click/paste profile link  
-> `/p/#name~pubKey`

Click/paste profile based invite offer  
-> `/o/#name~typedRecordKey~pubKey`

Click/paste batch invite  
-> `/b/#label~typedRecordKey~psk~subkeyIndex~subkeyWriter`
