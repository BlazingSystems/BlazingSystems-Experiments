# BlazePwifi Standalone Rental Server v0.5.2-rental.2-rc.9

RC9 is an immutable prerelease for further physical Android Device Owner provisioning validation.

## Security delta from RC8

RC9 pins the first accepted pending Device Provisioning identity on the phone. The
identity consists of the exact Rental Server origin, one-time enrollment token, and
server certificate SHA-256 pin.

Android Setup Wizard may redeliver the exact same provisioning extras; that replay is
idempotent. A callback with a different token, server, or pin is rejected rather than
silently replacing the pending enrollment state. Pending manual enrollment and partial
or permanent device identities also fail closed.

The guard is implemented as pure Java policy logic and is covered by JUnit in the APK
build.

## Existing audited safeguards retained

- Standard Enrollment QR and Device Provisioning QR remain separate schemas and actions.
- Secure enrollment protocol v2 remains downgrade-resistant and retry-safe.
- Device secret is derived independently and never returned in the v2 enrollment response.
- HTTPS server certificate pinning and strict origin-only URL validation remain enforced.
- Device Provisioning remains OpenWrt-only in this RC.
- Custom DPC / GMS compatibility remains explicitly scoped.
- Stable promotion still requires the locked production signer plus physical Setup Wizard evidence.

## Signing and validation status

The RC9 provisioning APK is TEST-signed for physical validation only. It is not the
stable production signing identity. Physical factory-reset Setup Wizard validation is
still required, and the stable-promotion gate remains fail-closed.
