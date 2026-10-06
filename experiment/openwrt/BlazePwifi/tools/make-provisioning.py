#!/usr/bin/env python3
import argparse, base64, hashlib, json, pathlib

p=argparse.ArgumentParser()
p.add_argument("--apk",required=True)
p.add_argument("--apk-url",required=True)
p.add_argument("--server-url",required=True)
p.add_argument("--enrollment-token",required=True)
p.add_argument("--device-name",default="Rental phone")\np.add_argument("--version-code",required=True,type=int)
p.add_argument("--out",required=True)
a=p.parse_args()
digest=hashlib.sha256(pathlib.Path(a.apk).read_bytes()).digest()
checksum=base64.urlsafe_b64encode(digest).decode().rstrip("=")
data={
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME":
   "com.blazesystems.blazerental/.BlazeDeviceAdminReceiver",
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION":a.apk_url,
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM":checksum,
 "android.app.extra.PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE":a.version_code,
 "android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE":{
   "blaze_schema":"blazerental.provisioning.v1",
   "server_url":a.server_url,
   "enrollment_token":a.enrollment_token,
   "device_name":a.device_name
 }
}
pathlib.Path(a.out).write_text(json.dumps(data,indent=2)+"\n",encoding="utf-8")
print(a.out)
