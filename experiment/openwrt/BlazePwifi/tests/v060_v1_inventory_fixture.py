#!/usr/bin/env python3
"""MIG-0645: negative tests for the actual redacted synthetic v1 preflight.

Every test creates a fresh /tmp fixture. It does not open production accounts,
signing keys, live routers, uploads or connected business resources.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

SCRIPT = Path(__file__).resolve().parents[1] / "tools/v060_v1_inventory_fixture.py"
ACCOUNT = "a" * 32
DEVICE = "b" * 32
SECRET = "PRIVATE-SYNTHETIC-HASH-MUST-NEVER-LEAK"
SENSITIVE = (ACCOUNT, DEVICE, SECRET, "alice", "bob", "TRUSTED-FAKE-CODE")


def write(p: Path, data: str) -> None:
    p.write_text(data, encoding="utf-8")
    p.chmod(0o600)


def create(root: Path) -> None:
    write(root / ".blaze-v1-fixture-only", "BLAZE-V1-SYNTHETIC-INVENTORY-ONLY\n")
    write(root / "accounts.tsv",
          f"{ACCOUNT}\t100\t0\t0\t0\t0\taa:bb:cc:dd:ee:ff\t10.0.0.2\tc:synthetic\n")
    write(root / "members.tsv",
          f"alice\tSynthetic\t1\tsha256i\tsalt\t{SECRET}\t4096\t300\t2\t1000\tfixture\n"
          "bob\tSynthetic\t1\tsha256i\tsalt\thash\t4096\t50\t1\t1000\tfixture\n")
    write(root / "member-events.tsv",
          "evt-a\t1000\talice\tadd\t120\t300\tsofttimer:test\t300\n")
    write(root / "member-revision", "2\n")
    write(root / "rental-devices.tsv",
          f"{DEVICE}\t{SECRET}\t1700001000\tSynthetic\t1000\n")
    write(root / "rental-events.tsv", f"r:synthetic\t{DEVICE}\t1700001000\t1000\n")
    write(root / "vouchers.tsv", "TRUSTED-FAKE-CODE\t100\n")
    targets = root / "targets"
    targets.mkdir(mode=0o700)
    write(targets / "vendo-01.tsv",
          f"{ACCOUNT}\taa:bb:cc:dd:ee:ff\t1122334455667788\t1700001200\tvendo-01\thotspot\n")


def run(root: Path, expected: str, reason: str | None = None) -> dict:
    proc = subprocess.run([sys.executable, str(SCRIPT), "--root", str(root)],
                          capture_output=True, text=True, timeout=10)
    assert proc.returncode == (0 if expected == "SCHEMA_READABLE_UNQUIESCED" else 4), (
        f"Unexpected exit: {proc.returncode} / {proc.stdout} / {proc.stderr}"
    )
    assert not proc.stderr, "Preflight leaked low-level error trace"
    assert len(proc.stdout.splitlines()) == 1, "Preflight emitted raw file contents"
    for value in SENSITIVE:
        assert value not in proc.stdout, "Sensitive identity/key leaked into redacted audit"
    info = json.loads(proc.stdout)
    assert info["status"] == expected, info
    assert info["migration_authorized"] is False
    assert info["quiesced"] is False
    assert info["fixture_only"] is True
    if reason:
        assert info.get("reason_code") == reason, info
    return info


def isolated(test):
    with tempfile.TemporaryDirectory(prefix="blaze-v1-audit-", dir="/tmp") as d:
        root = Path(d)
        create(root)
        test(root)


def check_clean(root):
    before = {p.relative_to(root): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in root.rglob("*") if p.is_file()}
    result = run(root, "SCHEMA_READABLE_UNQUIESCED")
    assert result["accounts"] == 1 and result["wifi_credit_cents"] == 100
    assert result["members"] == 2 and result["member_banked_seconds"] == 350
    assert result["member_events"] == 1 and result["member_revision"] == 2
    assert result["rental_devices"] == 1 and result["vouchers"] == 1
    assert result["controller_targets"] == 1
    after = {p.relative_to(root): hashlib.sha256(p.read_bytes()).hexdigest()
             for p in root.rglob("*") if p.is_file()}
    assert before == after, "Read-only preflight mutated financial files"


def mutated(test):
    def action(root):
        test(root)
        before = {p.relative_to(root): hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in root.rglob("*") if p.is_file() and not p.is_symlink()}
        info = run(root, "BLOCKED")
        after = {p.relative_to(root): hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in root.rglob("*") if p.is_file() and not p.is_symlink()}
        assert before == after, "A blocked audit mutated source balances or credentials"
        return info
    isolated(action)


isolated(check_clean)
mutated(lambda p: write(p / "accounts.tsv",
                        (p / "accounts.tsv").read_text() * 2))
mutated(lambda p: write(p / "members.tsv",
                        (p / "members.tsv").read_text() +
                        "bob\tDuplicate\t1\tsha256i\tsalt\thash\t4096\t1\t3\t1000\tfixture\n"))
mutated(lambda p: write(p / "accounts.tsv",
                        (p / "accounts.tsv").read_text().replace("\t100\t", "\tBAD\t")))
mutated(lambda p: write(p / "accounts.tsv",
                        (p / "accounts.tsv").read_text().replace("\t100\t", "\t9999999999999999999999999\t")))
mutated(lambda p: write(p / "members.tsv", "not-even-a-full-row\n"))
mutated(lambda p: write(p / "member-revision", "1\n"))
mutated(lambda p: write(p / "rental-events.tsv",
                        (p / "rental-events.tsv").read_text() * 2))
mutated(lambda p: write(p / "vouchers.tsv",
                        (p / "vouchers.tsv").read_text() * 2))
mutated(lambda p: write(p / "credits.tsv",
                        "aa:bb:cc:dd:ee:ff\t500\n"
                        "aa:bb:cc:dd:ee:ff\t100\n"))
mutated(lambda p: write(p / "paid-state-uncertain", "PENDING\t1000\n"))
mutated(lambda p: (p / "members.tsv").chmod(0o644))
mutated(lambda p: (p / ".blaze-v1-fixture-only").unlink())
mutated(lambda p: (p / "rental-devices.tsv").unlink())
def replace_with_symlink(p):
    (p / "accounts.tsv").rename(p / "saved")
    (p / "accounts.tsv").symlink_to(p / "saved")


mutated(replace_with_symlink)
mutated(lambda p: os.link(p / "members.tsv", p / "member-hardlink.tsv"))
mutated(lambda p: write(p / "targets" / "vendo-01.tsv",
                        "bad-target\n"))

with tempfile.TemporaryDirectory(prefix="not-blaze-v1-") as invalid:
    result = run(Path(invalid), "BLOCKED", "NONFIXTURE_ROOT")
with tempfile.TemporaryDirectory(prefix="blaze-v1-audit-", dir="/tmp") as root:
    r = Path(root)
    create(r)
    (r / "targets").chmod(0o777)
    run(r, "BLOCKED", "TARGETS_DIR_NOT_PRIVATE")
    (r / "targets").chmod(0o700)

print("MIG-0645 PASS: redacted read-only inventory, clean balances and schema, "
      "reject corrupt/duplicate/private-source/uncertain paid state, no filesystem mutations")
print("NOT PRODUCTION: fixture-only, not an operator quiescence/signed recovery or customer data migration")
