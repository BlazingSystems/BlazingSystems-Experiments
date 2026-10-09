# Diskless deployment guide

For a shared application share such as Z:\\Games\\Portable, generate a package locally, test it, then deploy it to a share with read-only permissions for client accounts. Keep DataMode as PerClientWritable. Each package config includes a random PackageId and writes under %LOCALAPPDATA%\\BlazeGen2\\Packages\\<PackageId>. If that location is nonpersistent after reboot, settings and saves will be lost. Configure a persistent writable data location in PortableConfig.json on each client if needed. Use FullyLocal only on writable persistent package storage. TemporarySession deletes its data on normal target exit but can leave remnants after forced termination.

No driver/service installation, anti-cheat support, or simultaneous-session locking is provided. Test with multiple accounts and multiple clients before wider use. UNC path compatibility is intended, but not validated by CI.

