# VeilidChat

VeilidChat is a chat application written for the Veilid (https://www.veilid.com) distributed application platform. It has a familiar and simple interface and is designed for private, and secure person-to-person communications.

For more information about VeilidChat: https://veilid.chat

For more information about the Veilid network protocol and app development platform: https://veilid.com

## Setup

While this is still in development, you must have a clone of the Veilid source checked out at `../veilid` relative to the working directory of this repository.

### For Linux Systems:
```
./setup_linux.sh
```

### For Mac Systems:
```
./setup_macos.sh
```

## Updating Code

### To update the WASM binary from `veilid-wasm`:
* Debug WASM: run `./wasm_update.sh`
* Release WASM: run `/wasm_update.sh release`

