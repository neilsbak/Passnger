#  Passnger

Passnger is an iOS and macOS app where you can use a single master password to generate unique passwords for all your accounts.  All your passwords are stored using the Secure Enclave and synced to all your devices using iCloud Keychain.  


## Why?

Managing your passwords is a pain.  Many of us reuse the same password, or slight variations, for various accounts across multiple websites and services. This leaves our accounts vulnerable. You could use a password manager service, but since your passwords are so sensitive, you really have to trust these services.

## Approach

Just remember one password (and never write it down).  Then when you want a new password for an account, enter some info about the account and the App will combine the master password with the account info and derive a password from a cryptographic hash.

## Secure Storage

This app closely guards you passwords - besides iCloud Keychain, your passwords always remain on your device and are stored encryped by the app and by the Keychain.  The app considers your master password(s) as too senstitive to be synced across devices, so it is excluded from iCloud keychain and you will need to reenter you master password for any new devices that you use.  This App has no 3rd party dependencies and there is absolutely no tracking of any kind.

## Tech

SwiftUI.
