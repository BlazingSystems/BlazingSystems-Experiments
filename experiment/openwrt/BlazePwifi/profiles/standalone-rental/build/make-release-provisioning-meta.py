#!/usr/bin/env python3
import argparse
import base64
import hashlib
import pathlib
import re
import sys

p = argparse.ArgumentParser(description="Build exact BlazeRental provisioning metadata for one release APK")
p.add_argument("--apk", required=True)
p.add_argument("--metadata", required=True)
p.add_argument("--tag", required=True)
p.add_argument("--repository", required=True)
p.add_argument("--out", required=True)
a = p.parse_args()

apk = pathlib.Path(a.apk)
meta_path = pathlib.Path(a.metadata)
if not apk.is_file() or apk.stat().st_size <= 0:
    raise SystemExit("APK is missing or empty")
if not meta_path.is_file():
    raise SystemExit("APK metadata is missing")
if not re.fullmatch(r"v0\.5\.2-rental\.2-rc\.\d+", a.tag):
    raise SystemExit("unexpected release tag")
if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", a.repository):
    raise SystemExit("invalid GitHub repository")

meta = {}
for raw in meta_path.read_text(encoding="utf-8").splitlines():
    raw = raw.strip()
    if not raw or raw.startswith("#"):
        continue
    if "=" not in raw:
        raise SystemExit(f"invalid metadata line: {raw!r}")
    k, v = raw.split("=", 1)
    meta[k] = v

required = [
    "PACKAGE_NAME", "APK_VERSION", "APK_VERSION_CODE", "APK_CHANNEL",
    "PRODUCTION_READY", "GMS_DPC_APPROVED", "TARGET_SCOPE", "APK_SHA256",
    "APK_CHECKSUM", "SIGNER_CERT_SHA256",
]
missing = [k for k in required if k not in meta]
if missing:
    raise SystemExit("missing metadata keys: " + ",".join(missing))

if meta["PACKAGE_NAME"] != "com.blazesystems.blazerental":
    raise SystemExit("unexpected BlazeRental package name")
if meta["APK_CHANNEL"] not in {"test", "production"}:
    raise SystemExit("invalid APK channel")
if meta["PRODUCTION_READY"] not in {"0", "1"}:
    raise SystemExit("invalid production flag")
if meta["GMS_DPC_APPROVED"] not in {"0", "1"}:
    raise SystemExit("invalid GMS DPC approval flag")
if meta["TARGET_SCOPE"] not in {
    "aosp_non_gms_or_explicit_oem_only",
    "gms_and_supported_aosp",
}:
    raise SystemExit("invalid provisioning target scope")
if meta["GMS_DPC_APPROVED"] == "0" and meta["TARGET_SCOPE"] != "aosp_non_gms_or_explicit_oem_only":
    raise SystemExit("non-approved custom DPC must use the restricted AOSP/non-GMS target scope")
if meta["GMS_DPC_APPROVED"] == "1" and meta["TARGET_SCOPE"] != "gms_and_supported_aosp":
    raise SystemExit("GMS-approved DPC must use the GMS-and-supported-AOSP target scope")
if not re.fullmatch(r"[0-9]+", meta["APK_VERSION_CODE"]):
    raise SystemExit("invalid version code")
if not re.fullmatch(r"[a-f0-9]{64}", meta["SIGNER_CERT_SHA256"]):
    raise SystemExit("invalid signer certificate digest")

blob = apk.read_bytes()
apk_sha256 = hashlib.sha256(blob).hexdigest()
apk_checksum = base64.urlsafe_b64encode(hashlib.sha256(blob).digest()).decode("ascii")
if apk_sha256 != meta["APK_SHA256"]:
    raise SystemExit("APK SHA-256 does not match Android build metadata")
if apk_checksum != meta["APK_CHECKSUM"]:
    raise SystemExit("APK provisioning checksum does not match Android build metadata")
if not re.fullmatch(r"[A-Za-z0-9_-]{43}=", apk_checksum):
    raise SystemExit("APK checksum is not canonical padded Base64URL SHA-256")

asset = apk.name
url = f"https://github.com/{a.repository}/releases/download/{a.tag}/{asset}"
out = pathlib.Path(a.out)
out.write_text(
    "\n".join([
        "READY=1",
        f"APK_URL={url}",
        f"APK_CHECKSUM={apk_checksum}",
        f"APK_SHA256={apk_sha256}",
        f"APK_VERSION={meta['APK_VERSION']}",
        f"APK_VERSION_CODE={meta['APK_VERSION_CODE']}",
        f"APK_CHANNEL={meta['APK_CHANNEL']}",
        f"PRODUCTION_READY={meta['PRODUCTION_READY']}",
        f"GMS_DPC_APPROVED={meta['GMS_DPC_APPROVED']}",
        f"TARGET_SCOPE={meta['TARGET_SCOPE']}",
        "",
    ]),
    encoding="utf-8",
)
print(out)
