## Sending an invitation
1. Generate writer keypair to share with new contact
2. Encrypt secret with requested encryption type
3. Create Local Chat DHT record (no content yet, will be encrypted with DH of contact identity key)
4. Create ContactRequestPrivate and encrypt with the writer secret
5. Create ContactRequest and embed encrypted ContactRequestPrivate
6. Create DHT unicast inbox for ContactRequest and store ContactRequest in owner subkey
7. Create ContactInvitation 
8. Create SignedContactInvitation embedding ContactInvitation
9. Create ContactInvitationRecord and add to local table in Account
10. Render SignedContactInvitation to shareable encoding (qr code, text blob, etc)
11. Share SignedContactInvitation out of band to desired contact, along with password somehow if used

## Receiving an invitation
1. Receive SignedContactInvitation from out of band, and the password somehow if used
2. Get the ContactRequest record unicastinbox DHT record owner subkey from the network
3. Decrypt the writer secret with the password if necessary
4. Decrypt the ContactRequestPrivate chunk with the writer secret
5. Get the contact's AccountMaster record key
6. Verify identity signature on the SignedContactInvitation
7. Verify expiration
8. Display the profile and ask if the user wants to accept or reject the invitation

## Accepting an invitation
1. Create a Local Chat DHT record (no content yet, will be encrypted with DH of contact identity key)
2. Create ContactResponse with chat dht record and account master
3. Create SignedContactResponse with accept=true signed with identity
4. Set ContactRequest unicastinbox DHT record writer subkey with SignedContactResponse, encrypted with writer secret
5. Add a local contact with the remote chat dht record, updating from the remote profile in it

## Rejecting an invitation
1. Create ContactResponse with account master
2. Create SignedContactResponse with accept=false signed with identity
3. Set ContactRequest unicastinbox DHT record writer subkey with SignedContactResponse, encrypted with writer secret

## Receiving an accept/reject
1. Open and get SignedContactResponse from ContactRequest unicastinbox DHT record
2. Decrypt with writer secret
3. Get DHT record for contact's AccountMaster
4. Validate the SignedContactResponse signature
   
If accept == false:
   1. Announce rejection
   2. Delete local invitation from table
   3. Overwrite and delete ContactRequest inbox
  
If accept == true:
   1. Add a local contact with the remote chat dht record, updating from the remote profile in it.
   2. Delete local invitation from table
   3. Overwrite and delete ContactRequest inbox
  
