#!/usr/bin/env python3
import argparse, json, re, subprocess, sys
from pathlib import Path

HEX64 = re.compile(r"^[0-9a-f]{64}$")
B64URL_SHA256 = re.compile(r"^[A-Za-z0-9_-]{43}=$")

def fail(msg):
    print("PROMOTION BLOCKED: " + msg, file=sys.stderr)
    raise SystemExit(1)

def load_json(path):
    try:
        return json.loads(Path(path).read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"cannot read JSON {path}: {exc}")

def load_env(path):
    out={}
    try:
        for raw in Path(path).read_text(encoding="utf-8").splitlines():
            raw=raw.strip()
            if not raw or raw.startswith("#"): continue
            if "=" not in raw: fail(f"malformed metadata line: {raw}")
            k,v=raw.split("=",1)
            out[k]=v
    except SystemExit:
        raise
    except Exception as exc:
        fail(f"cannot read metadata {path}: {exc}")
    return out

def norm_fp(value):
    return re.sub(r"[^0-9A-Fa-f]","",str(value or "")).lower()

p=argparse.ArgumentParser()
p.add_argument("--identity", required=True)
p.add_argument("--metadata", required=True)
p.add_argument("--evidence", required=True)
p.add_argument("--apk", required=True)
p.add_argument("--apksigner", default="apksigner")
p.add_argument("--expected-package", default="com.blazesystems.blazerental")
args=p.parse_args()

identity=load_json(args.identity)
meta=load_env(args.metadata)
evidence=load_json(args.evidence)

if identity.get("locked") is not True:
    fail("production signing identity is not locked")
if identity.get("package_id") != args.expected_package:
    fail("locked production identity package_id mismatch")
if identity.get("certificate_lineage") != "BlazeRental-production-lineage2":
    fail("unexpected production certificate lineage")
locked_fp=norm_fp(identity.get("sha256_fingerprint"))
if not HEX64.fullmatch(locked_fp):
    fail("locked production fingerprint is invalid")

required_meta={
    "READY":"1",
    "PACKAGE_NAME":args.expected_package,
    "APK_CHANNEL":"production",
    "PRODUCTION_READY":"1",
}
for k,v in required_meta.items():
    if meta.get(k) != v:
        fail(f"{k} must equal {v!r}, got {meta.get(k)!r}")

gms_approved=meta.get("GMS_DPC_APPROVED")
target_scope=meta.get("TARGET_SCOPE")
if gms_approved not in {"0","1"}:
    fail("GMS_DPC_APPROVED must be 0 or 1")
if target_scope not in {"aosp_non_gms_or_explicit_oem_only","gms_and_supported_aosp"}:
    fail("TARGET_SCOPE is missing or invalid")
if gms_approved == "0" and target_scope != "aosp_non_gms_or_explicit_oem_only":
    fail("non-approved custom DPC must use restricted AOSP/non-GMS target scope")
if gms_approved == "1" and target_scope != "gms_and_supported_aosp":
    fail("GMS-approved DPC must use the GMS-and-supported-AOSP target scope")

apk_sha=meta.get("APK_SHA256","").lower()
checksum=meta.get("APK_CHECKSUM","")
signer=norm_fp(meta.get("SIGNER_CERT_SHA256",""))
if not HEX64.fullmatch(apk_sha):
    fail("APK_SHA256 missing/invalid")
if not B64URL_SHA256.fullmatch(checksum):
    fail("APK_CHECKSUM must be canonical padded Base64URL SHA-256")
if signer != locked_fp:
    fail("APK signer certificate does not match locked Lineage-2 identity")

import hashlib, base64
apk=Path(args.apk)
if not apk.is_file():
    fail("production APK file missing")
raw=apk.read_bytes()
actual_sha=hashlib.sha256(raw).hexdigest()
actual_checksum=base64.urlsafe_b64encode(hashlib.sha256(raw).digest()).decode()
if actual_sha != apk_sha:
    fail("production APK bytes do not match APK_SHA256")
if actual_checksum != checksum:
    fail("production APK bytes do not match APK_CHECKSUM")

try:
    proc=subprocess.run(
        [args.apksigner,"verify","--print-certs",str(apk)],
        check=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, timeout=60,
    )
except Exception as exc:
    fail(f"cannot execute apksigner verification: {exc}")
if proc.returncode != 0:
    fail("production APK signature verification failed")
certs=[]
for line in proc.stdout.splitlines():
    m=re.match(r"^Signer #\d+ certificate SHA-256 digest:\s*([0-9A-Fa-f:]+)\s*$", line.strip())
    if m:
        certs.append(norm_fp(m.group(1)))
if len(certs) != 1:
    fail(f"expected exactly one APK signer certificate, found {len(certs)}")
if certs[0] != locked_fp:
    fail("actual APK signer certificate does not match locked Lineage-2 identity")
if signer != certs[0]:
    fail("metadata signer certificate does not match actual APK signer certificate")

if evidence.get("passed") is not True:
    fail("physical Setup Wizard validation evidence is not marked passed")
if evidence.get("package_id") != args.expected_package:
    fail("physical evidence package_id mismatch")
if evidence.get("apk_sha256","").lower() != apk_sha:
    fail("physical evidence APK SHA-256 does not match production APK")
if norm_fp(evidence.get("signer_certificate_sha256")) != locked_fp:
    fail("physical evidence signer fingerprint mismatch")
if evidence.get("target_scope") != target_scope:
    fail("physical evidence target_scope does not match release metadata")
if evidence.get("gms_dpc_approved") is not (gms_approved == "1"):
    fail("physical evidence GMS DPC approval state does not match release metadata")
if gms_approved == "0" and evidence.get("universal_gms_compatibility_claimed") is not False:
    fail("non-approved custom DPC must explicitly record no universal GMS compatibility claim")
if gms_approved == "1" and evidence.get("universal_gms_compatibility_claimed") not in {False, True}:
    fail("physical evidence must explicitly record universal_gms_compatibility_claimed")

required_true=[
    "factory_reset_setup_wizard_completed",
    "device_owner_confirmed",
    "https_certificate_pin_verified",
    "v2_enrollment_completed",
    "device_visible_on_intended_server",
    "response_loss_retry_same_identity",
    "protocol1_downgrade_rejected",
    "redemption_record_retired_after_authenticated_sync",
    "standard_scanner_rejected_device_provisioning_qr",
    "android_12_plus_path_tested",
]
for key in required_true:
    if evidence.get(key) is not True:
        fail(f"physical validation requirement not satisfied: {key}")

tested=evidence.get("tested_android_versions")
if not isinstance(tested,list) or not tested:
    fail("tested_android_versions must be a non-empty list")

print("PROMOTION GATE: PASS")
