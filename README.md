#  Passnger

Passnger is an iOS and macOS app where you can use a single master password to generate unique passwords for all your accounts.  All your passwords are stored using the Secure Enclave and synced to all your devices using iCloud Keychain.  

<p float="left">
    <img src="/.github/readme/macos_app.png" alt="macOS Screenshot" width="500">
    <img src="/.github/readme/ios_app.png" alt="iOS Screenshot" width="200">
</p>

[![Get it from the App Store](/.github/readme/badge-download-on-the-app-store.svg)](https://apps.apple.com/us/app/id1531915711)

## Why?

Managing your passwords is a pain.  Many of us reuse the same password, with slight variations, for various accounts across multiple websites and services. This leaves our accounts vulnerable. There are commercial password manager services, but sharing your passwords with a 3rd party seems risky.

## Approach

You will just have to remember one password (and never write it down).  To generate a new password for an account, enter the URL and username of the account, and the App will combine this info with your master password to derive a new password from a cryptographic hash.

## Secure Storage

The app will closely guard your passwords. Your master password is used to encrypt passwords before they are stored in the secure keychain.  Your encrypted passwords are synced  across your devices via iCloud Keychain.  As a security measure, the master passwords are not synced, and you will need to reenter you master password on any new device in order to decrypt a password.  This App has no 3rd party dependencies and there is absolutely no tracking of any kind.

## Tech

SwiftUI.
