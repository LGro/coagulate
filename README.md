# Coagulate

Link your contact profile with others to keep them up to date whenever you move or get a new number, all while respecting everyone's privacy.

This [Flutter](flutter.dev) based implementation is derived from [VeilidChat](https://gitlab.com/veilid/veilidchat/).
Accordingly, the Copyright to all files belongs to the Veilid developers unless explicitly stated otherwise.
Also, you might still find left over things called "veilidchat" that should be called "coagulate".
If you find any, feel free to open a small pull request 😊

## Development Setup

While this is still in development, you must have a clone of the [Veilid](https://gitlab.com/veilid/veilid/) source checked out at `../veilid` relative to the working directory of this repository.

For platform specific development setup, see the scripts in `./dev-setup`.

To enable the Mapbox driven map view, set your secret token in `~/.gradle/gradle.properties`:
```
SDK_REGISTRY_TOKEN={SECRET-API-TOKEN}
```

and set the public token as a build argument
```
--dart-define PUBLIC_ACCESS_TOKEN={PUBLIC-API-TOKEN}
```

Also, add your secret API token to a file `android/app/src/main/res/values/developer-config.xml`:
```xml
<string name="mapbox_access_token">{SECRET-API-TOKEN}</string>
```

For iOS, paste the contents below to `~/.netrc`:
```
machine api.mapbox.com 
login mapbox
password <SecretKey>
```

### Building

To (re-)generate all code from templates, run
```
flutter packages pub run build_runner build
```

### Fastlane

For Fastlane setup see https://docs.fastlane.tools/

Based on the Gemfile of this repo, you can get fastlane with
```
bundle update
```

## User Stories

### Open app first time

I'd like to set up my profile with all the contact information I want to publish.
I'd like to define different scopes that can see different subsets of my contact information to shape what is shared with others.

I'd like to see my contacts list with all already securely connected contacts that also have the app.
If that's not possible, see highlighted / at top who has the app - not connected yet.
If that's not possible, can I at least see most of them after I've connected with the first peer?

### Connect

When I click on a contact that I haven't shared with to yet, I'd like to see a share menu for all encrypted messengers where I can share the sharing link.

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

## Architecture

### Views
- List of all contacts
- Selected Contact
  - Specify which information to share with them (name + numbers, name + emails, all including location, custom profiles...)
  - Send / share initial handshake via all available channels (imessage, encrypted messengers via generic share button?!)
    Hi, you can keep my contact information up-to-date in your contacts app with Coagulate: coag://pubkey (Make sure this message was sent over a trusted channel and not manipulated by a third party, e.g. by comparing whether these emoji match what the sender sees: X X X X)
- Link received
  Congratulations, you will now stay up to date on <NAME>'s <numbers, mails, ...> (system contact sync opt out option for each item). <There is nothing more for you to do.|To ensure that Coagulate can keep your contact information up to date, please activate the location permissions, which is the iOS way of allowing background sync even though your location is never used in the app or sent to anyone unless you explicitly share it.|Do you want to help them stay up to date with your contact details as well?> Should they at some point no longer share want to updates with you, you will still retain the last known details.
- Map of all contact locations
- Privacy & Details
  TODO: Explanation text of how amazingly privacy friendly Coagulate is.

### Actions
On each trigger (app open, background location change, ...?):
- fetch information for all contacts subscribed to
  - find the current value on the DHT given the contact's public key
- publish any updated information for all contacts shared with
  - create/update the current value for each contact in a respective DHT entry

### Open Questions

- What if only part of information is offered for up to date and others not, how to show if I "know more"?
- What if I want to override a contact information locally? -> opt out sync per contact info
