#!/usr/bin/env python3
import argparse, base64, hashlib, json, pathlib, re

p=argparse.ArgumentParser()
p.add_argument("--apk",required=True)
p.add_argument("--apk-url",required=True)
p.add_argument("--server-url",required=True)
p.add_argument("--enrollment-token",required=True)
p.add_argument("--device-name",default="Rental phone")
p.add_argument("--version-code",required=True,type=int)
p.add_argument("--out",required=True)
a=p.parse_args()

if not a.apk_url.startswith("https://") or re.search(r"\s", a.apk_url):
    raise SystemExit("--apk-url must be a whitespace-free HTTPS URL")
if not (a.server_url.startswith("http://") or a.server_url.startswith("https://")) or re.search(r"\s", a.server_url):
    raise SystemExit("--server-url must be a whitespace-free HTTP(S) URL")
if a.version_code < 1:
    raise SystemExit("--version-code must be positive")
if not re.fullmatch(r"[A-Fa-f0-9]+\.[A-Fa-f0-9]+", a.enrollment_token):
    raise SystemExit("--enrollment-token has an invalid BlazeRental format")

apk=pathlib.Path(a.apk)
if not apk.is_file() or apk.stat().st_size <= 0:
    raise SystemExit("--apk must be a non-empty file")

digest=hashlib.sha256(apk.read_bytes()).digest()
checksum=base64.urlsafe_b64encode(digest).decode("ascii")
if not re.fullmatch(r"[A-Za-z0-9_-]{43}=", checksum):
    raise SystemExit("unexpected canonical Base64URL SHA-256 encoding")

data={
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME":
   "com.blazesystems.blazerental/.BlazeDeviceAdminReceiver",
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION":a.apk_url,
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM":checksum,
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE":a.version_code,
 "android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE":{
   "blaze_schema":"blazerental.provisioning.v2",
   "server_url":a.server_url,
   "enrollment_token":a.enrollment_token,
   "device_name":a.device_name
 }
}
pathlib.Path(a.out).write_text(json.dumps(data,indent=2)+"\n",encoding="utf-8")
print(a.out)
