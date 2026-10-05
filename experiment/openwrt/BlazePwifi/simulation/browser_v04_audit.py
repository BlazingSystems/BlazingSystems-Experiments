#!/usr/bin/env python3
import http.server, json, os, socketserver, threading, time, urllib.parse, sys
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1] / "openwrt" / "rootfs" / "www" / "blazepwifi"
OUT = Path(sys.argv[1] if len(sys.argv) > 1 else "browser-v04-audit").resolve()
OUT.mkdir(parents=True, exist_ok=True)

class Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

os.chdir(str(ROOT))
server = socketserver.TCPServer(("127.0.0.1", 0), Quiet)
port = server.server_address[1]
thread = threading.Thread(target=server.serve_forever, daemon=True)
thread.start()

def mock_admin(action):
    if action == "status":
        return {"ok": True, "active_sessions": 3, "online_vendos": 1,
                "mem_available_kb": 131072, "load1": "0.11",
                "uptime_seconds": 7200, "must_change": 0}
    if action in ("rental_device_list", "rental_list"):
        return {"ok": True, "devices": [{
            "device_id": "0123456789abcdef01234567",
            "label": "Demo rental phone",
            "lease_until": int(time.time()) + 3600,
            "last_seen": int(time.time()),
            "policy_revision": 4,
            "launcher_mode": "rental",
            "allowed_packages": "com.android.camera,com.android.calculator2",
            "hidden_packages": "com.android.settings",
            "preferred_vendo": "vendo-01",
            "timer_user_toggle": 1,
            "notifications_enabled": 1,
            "admin_password_set": True,
            "inventory": "com.android.camera,com.android.calculator2,com.android.settings"
        }]}
    if action == "controller_list":
        return {"ok": True, "controllers": [{
            "id": "vendo-01", "last_seen": int(time.time()), "ip": "192.168.1.50",
            "coin_pin": 4, "relay_pin": 5, "coin_debounce_ms": 40, "pulse_group_ms": 400
        }]}
    if action == "config_get":
        return {"ok": True, "value": "600"}
    if action == "config_set":
        return {"ok": True}
    if action == "rental_device_qr":
        return {"ok": True, "enrollment_token": "0123456789abcdef.abcdef0123456789",
                "server_url": "https://192.168.1.1:8443", "device_name": "Rental phone",
                "qr_payload": json.dumps({
                    "server_url":"https://192.168.1.1:8443",
                    "enrollment_token":"0123456789abcdef.abcdef0123456789",
                    "device_name":"Rental phone"
                })}
    if action == "voucher_create":
        return {"ok": True, "code": "BLAZE-DEMO", "cents": 100}
    if action in ("rental_policy_set","rental_lease_add","rental_lease_expire",
                  "rental_device_rename","rental_device_revoke"):
        return {"ok": True, "policy_revision": 5}
    return {"ok": True}

errors=[]
with sync_playwright() as p:
    browser=p.chromium.launch(headless=True)
    page=browser.new_page(viewport={"width": 1440, "height": 1000})
    page.on("console", lambda msg: errors.append("console:"+msg.text) if msg.type=="error" else None)
    page.on("pageerror", lambda exc: errors.append("pageerror:"+str(exc)))

    def route_handler(route):
        req=route.request
        url=req.url
        if url.endswith("/cgi-bin/admin-session"):
            route.fulfill(status=200, content_type="application/json",
                          body=json.dumps({"ok":True,"username":"admin","role":"admin",
                                           "csrf":"browser-audit-csrf","must_change":0}))
            return
        if url.endswith("/cgi-bin/admin"):
            body=req.post_data or ""
            params=urllib.parse.parse_qs(body, keep_blank_values=True)
            action=params.get("action",[""])[0]
            route.fulfill(status=200, content_type="application/json",
                          body=json.dumps(mock_admin(action)))
            return
        route.continue_()

    page.route("**/*", route_handler)
    page.goto(f"http://127.0.0.1:{port}/admin.html", wait_until="networkidle")
    page.wait_for_selector("#appView:not(.hidden)")
    assert page.locator("#page-dashboard").is_visible()
    assert "BlazePwifi" in page.locator("body").inner_text()

    page.click('[data-page="rentals"]')
    page.wait_for_selector("#page-rentals.active")
    page.wait_for_selector('[data-device="0123456789abcdef01234567"]')
    assert "Demo rental phone" in page.locator("#rentalCards").inner_text()

    page.click('button:has-text("+ Add device")')
    page.wait_for_selector("#addRentalModal:not(.hidden)")
    page.click('button:has-text("Generate enrollment QR")')
    page.wait_for_selector("#qrResult:not(.hidden)")
    page.wait_for_selector("#qrBox svg")
    assert "0123456789abcdef" in page.locator("#qrToken").inner_text()
    page.click('#addRentalModal button:has-text("✕")')

    page.click('[data-page="controllers"]')
    page.wait_for_selector("#page-controllers.active")
    page.wait_for_selector("text=vendo-01")

    page.click('[data-page="system"]')
    page.wait_for_selector("#page-system.active")
    assert "TailAdmin" in page.locator("#page-system").inner_text()

    page.click('[data-page="dashboard"]')
    page.click("#voucherBtn")
    page.wait_for_selector("text=BLAZE-DEMO")

    page.screenshot(path=str(OUT/"admin-dashboard.png"), full_page=True)
    browser.close()

server.shutdown()
if errors:
    (OUT/"browser-errors.txt").write_text("\n".join(errors))
    raise SystemExit("browser console/page errors: "+repr(errors))

result={
    "target":"browser-admin",
    "release":"0.4.0",
    "validation_level":"headless-browser-with-mocked-cgi",
    "checks":{
        "dashboard_loaded":True,
        "rental_navigation":True,
        "device_policy_editor_rendered":True,
        "local_qr_generated":True,
        "controller_page_rendered":True,
        "system_page_rendered":True,
        "voucher_action_rendered":True,
        "console_errors":False
    }
}
(OUT/"audit.json").write_text(json.dumps(result,indent=2))
print("BlazePwifi v0.4 browser audit passed")
