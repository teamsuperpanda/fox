# Android release signing

Release builds fail unless the upload keystore is configured. There is no
debug-key fallback: an AAB signed with the debug key is rejected by Play, and
silently building one wastes a release cycle.

## Local setup

1. Create or obtain the upload keystore.
2. Create `android/key.properties` (gitignored):

   ```properties
   storeFile=../upload-keystore.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```

   `storeFile` is resolved relative to `android/app/`, so `../upload-keystore.jks`
   means `android/upload-keystore.jks`.
3. Run `flutter build appbundle --release`.

`android/keystore.properties` and `android/local.properties` are also read, and
the same values can come from `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`
and `KEY_PASSWORD` (or `storeFile`, `storePassword`, `keyAlias`, `keyPassword`)
environment variables for CI.

## CI

The release workflow restores the keystore from the `KEYSTORE_BASE64` secret.

## Shrinking

Release builds enable `minifyEnabled` and `shrinkResources` (R8). If a release
build crashes after shrinking, add a keep rule to `android/app/proguard-rules.pro`
and verify the build again.
