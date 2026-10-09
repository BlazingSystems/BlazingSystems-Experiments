# EasyMode 7.0 validation record

## 2026-10-10 checkpoint
- 17 pure accounting/attribution assertions PASS on the R281 OpenWrt 24.10.8 ucode runtime, using only `/tmp/emti-test` files.
- 5 executable Node tests PASS: aggregation, date filters, billing boundaries, escaping/CSV injection, unavailable values.
- Collector, DNS controller and rpcd plugin compile on that runtime.
- Isolated read-only collector detected 2 deduplicated upstream devices, 4 wireless interfaces and 2 observed clients. No installed application, network configuration or firmware changed. Initial CPU conversion defect was found and corrected.
- Generated observer rules pass `nft --check` on R281; rules were NOT installed there.
- Deterministic package builder produced core plus six edition IPKs and six offline archives. These await clean-install validation.
- GitHub Linux validation environment established successfully at de0189ddd58e609b525c03eb0b3aa46f982a87b4.

## Pending acceptance evidence
GitHub VM installation/upgrade/uninstall; private RPC/CSRF tests; real forwarded counters; DNS lifecycle; corruption recovery; BIOS/UEFI boot; UI mobile/live/error behavior; uploaded checksum verification. Physical hardware deployment remains NOT HARDWARE VERIFIED. No v7 release is published at this checkpoint.
