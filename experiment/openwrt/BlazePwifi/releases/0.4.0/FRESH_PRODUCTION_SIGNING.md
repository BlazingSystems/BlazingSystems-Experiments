# BlazeRental v0.4 transfer key

This public key encrypts the one-time v0.4 production signing-keystore backup.

Public-key SHA-256 (DER):

`2a6a19de7b07ad756afd1f60c40a58776aa20f2e2daeb2e8e980219891b54a3e`

The matching private transfer key is intentionally **not committed**. It must be
kept offline by the owner. Losing it means the encrypted recovery backup cannot
be opened later.

The v0.4 fresh production signing identity is intended for factory-reset /
fresh Device Owner provisioning. It does not replace the separate recovery path
for in-place upgrades from the v0.3 production certificate.
