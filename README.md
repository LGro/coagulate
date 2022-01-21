# coagulate

A privacy friendly way to keep your address book up to date.

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

## Technical Considerations

### Design Properties

- per connection shared secret
- exchange shared secret via probably secure existing channel (e.g. crypto messenger)
- update shared secret at every direct interaction to not be vulnerable against compromised key exchange medium
- provide future shared secrets at every direct interaction for forward secrecy in async communication
- encrypt profile with individual shared secret from own address book individually and announce as a whole for replication
- replicate full addressbook with encrypted profile information for other people
- announce replication confirmation
- replicate for contacts as well as unknown peers to obfuscate social graph
- replicate to all connected peers
- maintain central servers for rendevouz and as replication cache
- on re-join a node asks the rendevouz servers of choice for all their known peers, and from that list - locally - the known peers as well as random unknown peers are selected for replication
- only most recent version of address books from peers are kept; others are discarded
- replicated address books from unknown peers are discarded after a random storage time
- also everything that a peer - known or unknown - replicates is replicated
- servers (randomly?) discard what they replicate after a while

### Secret Restoration

- https://anastasis.lu/

- https://darkcrystal.pw/

## Threats Risks

- compromised device -> current shared secret and agreed future shared secrets are comromised ->impersonation
- meta data leakage? -> social graph reconstruction; identity demasking
- (D)DOS potential? -> vulnerability of rendevouz server; mitigate via alternative backup rendevouz channels (e.g. webrtc, DHT), might not be applicable due to then reduced privacy guarantees; resiliency
