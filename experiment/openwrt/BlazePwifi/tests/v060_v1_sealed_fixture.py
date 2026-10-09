#!/usr/bin/env python3
"""EBACK-0677: synthetic sealed financial backup/restore negative regressions.

All contents are fake under /tmp/blaze-v1-audit-* and /tmp/blaze-v1-seal-*.
Never connects to /etc, OpenWrt, an account, or payment/lease authority.
"""
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile

SCRIPT = Path(__file__).resolve().parents[1] / "tools/v060_v1_sealed_fixture.py"
FAKE_SECRET = "PRIVATE-SYNTHETIC-BACKUP-DO-NOT-PRINT"
FAKE_ACCOUNT = "a" * 32
FAKE_DEVICE = "b" * 32
OUTPUTS = []

def put(path: Path, value: str) -> None:
    path.write_text(value, encoding="utf-8")
    path.chmod(0o600)

def make_fixture(root: Path) -> None:
    put(root / ".blaze-v1-fixture-only", "BLAZE-V1-SYNTHETIC-INVENTORY-ONLY\n")
    put(root / "accounts.tsv", f"{FAKE_ACCOUNT}\t100\t0\t0\t0\t0\taa:bb:cc:dd:ee:ff\t10.0.0.2\tc:synthetic\n")
    put(root / "members.tsv", f"alice\tSynthetic\t1\tsha256i\tsalt\t{FAKE_SECRET}\t4096\t300\t2\t1000\tfixture\n"
                              "bob\tSynthetic\t1\tsha256i\tsalt\thash\t4096\t50\t1\t1000\tfixture\n")
    put(root / "member-events.tsv", "evt-a\t1000\talice\tadd\t120\t300\tsofttimer:test\t300\n")
    put(root / "member-revision", "2\n")
    put(root / "rental-devices.tsv", f"{FAKE_DEVICE}\t{FAKE_SECRET}\t1700001000\tSynthetic\t1000\n")
    put(root / "rental-events.tsv", f"r:synthetic\t{FAKE_DEVICE}\t1700001000\t1000\n")
    put(root / "vouchers.tsv", "TRUSTED-FAKE-CODE\t100\n")
    (root / "targets").mkdir(mode=0o700)
    put(root / "targets" / "vendo-01.tsv",
        f"{FAKE_ACCOUNT}\taa:bb:cc:dd:ee:ff\t1122334455667788\t1700001200\tvendo-01\thotspot\n")

def invoke(action: str, *args: str, expected: int) -> None:
    command = [sys.executable, str(SCRIPT), action, *map(str, args)]
    r = subprocess.run(command, capture_output=True, text=True, timeout=20)
    assert r.returncode == expected, f"{action}: unexpected return {r.returncode}: {r.stdout} / {r.stderr}"
    all_text = r.stdout + r.stderr
    for secret in (FAKE_ACCOUNT, FAKE_DEVICE, FAKE_SECRET, "alice", "bob", "TRUSTED-FAKE-CODE"):
        assert secret not in all_text, "TEST FAILURE: synthetic identity leaked into public diagnostic"
    if expected:
        assert not r.stdout and "EBACK-0677 BLOCKED" in r.stderr
    else:
        assert "EBACK-0677" in r.stdout and not r.stderr

def tree(root: Path) -> dict:
    return {str(p.relative_to(root)): (hashlib.sha256(p.read_bytes()).hexdigest(), p.stat().st_mode & 0o777)
            for p in root.rglob("*") if p.is_file()}

with tempfile.TemporaryDirectory(prefix="blaze-v1-audit-", dir="/tmp") as temp_source, \
     tempfile.TemporaryDirectory(prefix="blaze-v1-seal-", dir="/tmp") as temp_seal:
    src, sealroot = Path(temp_source), Path(temp_seal)
    make_fixture(src)
    baseline = tree(src)
    keyfile, backup = sealroot / "key.bin", sealroot / "backup.blaze"
    dst = Path(tempfile.mkdtemp(prefix="blaze-v1-audit-recovered-", dir="/tmp"))
    dst.rmdir()  # Reserve a valid path without allowing an existing restore destination.
    try:
        invoke("keygen", "--key-file", keyfile, expected=0)
        assert keyfile.stat().st_mode & 0o777 == 0o600
        invoke("keygen", "--key-file", keyfile, expected=4)
        invoke("seal", "--source", src, "--backup", backup, "--key-file", keyfile, expected=0)
        assert backup.stat().st_mode & 0o777 == 0o600
        assert FAKE_SECRET.encode() not in backup.read_bytes()
        assert FAKE_ACCOUNT.encode() not in backup.read_bytes()
        assert tree(src) == baseline, "Seal mutated source financial records"
        invoke("seal", "--source", src, "--backup", backup, "--key-file", keyfile, expected=4)
        invoke("restore", "--backup", backup, "--key-file", keyfile, "--output", dst, expected=0)
        assert tree(dst) == baseline, "Restored fake accounts/leases differ from source"
        assert (dst / "targets").stat().st_mode & 0o777 == 0o700
        invoke("restore", "--backup", backup, "--key-file", keyfile, "--output", dst, expected=4)
        saved_cipher = backup.read_bytes()
        saved_key = keyfile.read_bytes()

        # Tampering, wrong-key, shortened authentication tag all fail closed,
        # with no newly created restore directory and no plaintext exposure.
        for i, kind in enumerate(("wrong-key", "tampered", "truncated")):
            reject_dst = Path("/tmp/blaze-v1-audit-seal-reject-" + str(os.getpid()) + "-" + str(i))
            assert not reject_dst.exists()
            if kind == "wrong-key":
                keyfile.write_bytes(os.urandom(32))
            elif kind == "tampered":
                value = bytearray(saved_cipher)
                value[-6] ^= 1
                backup.write_bytes(value)
            else:
                backup.write_bytes(saved_cipher[:-6])
            invoke("restore", "--backup", backup, "--key-file", keyfile,
                   "--output", reject_dst, expected=4)
            assert not reject_dst.exists(), "Failed authenticated restore created output"
            keyfile.write_bytes(saved_key)
            backup.write_bytes(saved_cipher)
        keyfile.chmod(0o644)
        reject_dst = Path("/tmp/blaze-v1-audit-unsafe-key-" + str(os.getpid()))
        invoke("restore", "--backup", backup, "--key-file", keyfile, "--output", reject_dst, expected=4)
        assert not reject_dst.exists()
        keyfile.chmod(0o600)

        # An unknown paid sidecar or changed marker must prevent new sealing.
        (src / "unknown-money-ledger.tsv").write_text("synthetic-hidden-credit\n")
        (src / "unknown-money-ledger.tsv").chmod(0o600)
        backup.unlink()
        invoke("seal", "--source", src, "--backup", backup, "--key-file", keyfile, expected=4)
        assert not backup.exists()
        (src / "unknown-money-ledger.tsv").unlink()
        put(src / ".blaze-v1-fixture-only", "INVALID-FIXTURE\n")
        invoke("seal", "--source", src, "--backup", backup, "--key-file", keyfile, expected=4)
        assert not backup.exists()
        put(src / ".blaze-v1-fixture-only", "BLAZE-V1-SYNTHETIC-INVENTORY-ONLY\n")
        assert tree(src) == baseline

        # Never read a live /etc source or create a backup with an unsafe key.
        invoke("seal", "--source", "/etc", "--backup", backup, "--key-file", keyfile, expected=4)
        assert not backup.exists()
        keyfile.unlink()
        keyfile.symlink_to("/etc/passwd")
        invoke("seal", "--source", src, "--backup", backup, "--key-file", keyfile, expected=4)
        assert not backup.exists()
        keyfile.unlink()
        assert tree(src) == baseline
    finally:
        if dst.exists():
            import shutil
            shutil.rmtree(dst)

print("EBACK-0677 PASS: AES-256-GCM synthetic sealed backup / exact reversible restore; wrong key, tamper, truncated tag, untrusted source and overwrite blocked")
print("NOT PRODUCTION: no customer funds, live quiescence, off-device custody, or hardware power-cut proof")
