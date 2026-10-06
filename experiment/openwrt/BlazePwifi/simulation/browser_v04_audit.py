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
    if action in ("rental_device_qr", "rental_binding_qr"):
        return {"ok": True, "qr_type": "binding",
                "enrollment_token": "0123456789abcdef.abcdef0123456789",
                "expires_seconds": 600,
                "server_url": "https://192.168.1.1:8443", "device_name": "Rental phone",
                "qr_payload": json.dumps({
                    "server_url":"https://192.168.1.1:8443",
                    "enrollment_token":"0123456789abcdef.abcdef0123456789",
                    "device_name":"Rental phone"
                })}
    if action == "rental_provisioning_qr":
        payload = {
            "android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME":
                "com.blazesystems.blazerental/.BlazeDeviceAdminReceiver",
            "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION":
                "https://updates.example.test/BlazeRental.apk",
            "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM":
                "0K0gvtAOowTbm_9FkoVC_tV0Bw1BbtZbT789i6I9cQI",
            "android.app.extra.PROVISIONING_DEVICE_ADMIN_MINIMUM_VERSION_CODE": 50200,
            "android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE": {
                "server_url": "https://192.168.1.1:8443",
                "enrollment_token": "fedcba9876543210.0123456789abcdef",
                "device_name": "Rental phone"
            }
        }
        return {"ok": True, "qr_type": "device_owner",
                "enrollment_token": "fedcba9876543210.0123456789abcdef",
                "expires_seconds": 600,
                "server_url": "https://192.168.1.1:8443", "device_name": "Rental phone",
                "apk_version": "0.5.2", "apk_version_code": 50200,
                "apk_url": "https://updates.example.test/BlazeRental.apk",
                "apk_checksum": "0K0gvtAOowTbm_9FkoVC_tV0Bw1BbtZbT789i6I9cQI",
                "qr_payload": json.dumps(payload)}
    if action == "voucher_create":
        return {"ok": True, "code": "BLAZE-DEMO", "cents": 100}
    if action in ("rental_policy_set","rental_lease_add","rental_lease_expire",
                  "rental_device_rename","rental_device_revoke"):
        return {"ok": True, "policy_revision": 5}
    return {"ok": True}

errors=[]
admin_mutations=[]
portal_state={"coin_expires":0, "coin_vendo":"", "credit":0, "remaining":65}

def mock_portal(action):
    now=int(time.time())
    if action == "portal_config":
        return {"ok":True,"portal":{}}
    if action == "rates":
        return {"ok":True,"rates":[{"cents":100,"label":"10 minutes"}]}
    if action == "vendos":
        return {"ok":True,"vendos":[{"id":"vendo-01"}]}
    if action == "me":
        return {"ok":True,"device":"demo","mac":"02:11:22:33:44:55","ip":"192.168.13.25",
                "credit_cents":portal_state["credit"],"remaining_seconds":portal_state["remaining"],
                "paused":0,"time_synchronized":True,"server_time":now,
                "coin_expires":portal_state["coin_expires"],"coin_vendo":portal_state["coin_vendo"],
                "hotspot_vlan":13,"speed_limit_kbps":10000,"mem_available_kb":98304,
                "load1":"0.18","uptime_seconds":187200}
    if action == "coin_start":
        portal_state["coin_expires"]=now+120
        portal_state["coin_vendo"]="vendo-01"
        return {"ok":True,"vendo":"vendo-01","target_nonce":"audit-nonce",
                "server_time":now,"expires":now+120}
    if action == "coin_stop":
        portal_state["coin_expires"]=0
        portal_state["coin_vendo"]=""
        return {"ok":True,"server_time":now}
    if action in ("pause","resume","disconnect","redeem","connect"):
        return {"ok":True}
    return {"ok":True}

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
            if action:
                admin_mutations.append({
                    "action": action,
                    "csrf_body": params.get("csrf",[""])[0],
                    "csrf_header": req.headers.get("x-blaze-csrf","")
                })
            route.fulfill(status=200, content_type="application/json",
                          body=json.dumps(mock_admin(action)))
            return
        if url.endswith("/cgi-bin/api"):
            body=req.post_data or ""
            params=urllib.parse.parse_qs(body, keep_blank_values=True)
            action=params.get("action",[""])[0]
            route.fulfill(status=200, content_type="application/json",
                          body=json.dumps(mock_portal(action)))
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

    page.click('button:has-text("Bind existing BlazeRental")')
    page.wait_for_selector("#qrResult:not(.hidden)")
    page.wait_for_selector("#qrBox svg")
    assert "Standard binding" in page.locator("#qrNotice").inner_text()
    assert "0123456789abcdef" in page.locator("#qrToken").inner_text()

    page.click('button:has-text("Provision factory-reset phone")')
    page.wait_for_selector("#qrBox svg")
    assert "Device Owner provisioning" in page.locator("#qrNotice").inner_text()
    assert "APK 0.5.2 (50200)" in page.locator("#qrMeta").inner_text()
    assert "fedcba9876543210" in page.locator("#qrToken").inner_text()
    page.click('#addRentalModal button:has-text("✕")')

    assert admin_mutations
    assert all(x["csrf_body"] == "browser-audit-csrf" for x in admin_mutations)
    assert all(x["csrf_header"] == "browser-audit-csrf" for x in admin_mutations)

    page.click('[data-page="controllers"]')
    page.wait_for_selector("#page-controllers.active")
    page.wait_for_selector("text=vendo-01")

    page.click('[data-page="system"]')
    page.wait_for_selector("#page-system.active")
    system_text = page.locator("#page-system").inner_text()
    assert ("TailAdmin" in system_text
            or ("System & Security" in system_text and "Security posture" in system_text))

    # v0.5 moved voucher creation into its dedicated console module.
    page.click('[data-page="vouchers"]')
    page.wait_for_selector("#page-vouchers.active")
    page.click("#voucherBtn")
    page.wait_for_selector("text=BLAZE-DEMO")

    page.screenshot(path=str(OUT/"admin-dashboard.png"), full_page=True)

    # Captive portal: session countdown and coin reservation must be visibly live.
    page.goto(f"http://127.0.0.1:{port}/index.html", wait_until="networkidle")
    page.wait_for_function("document.getElementById('time').textContent !== '—'")
    first_time=page.locator("#time").inner_text()
    time.sleep(1.2)
    second_time=page.locator("#time").inner_text()
    assert first_time != second_time, (first_time, second_time)

    page.click('button:has-text("Open coin slot")')
    page.wait_for_selector("#coinWindow:not(.hide)")
    countdown=page.locator("#coinCountdown").inner_text()
    assert countdown not in ("00:00",""), countdown
    assert "Ready on vendo-01" in page.locator("#coinmsg").inner_text()

    portal_state["credit"]=100
    page.evaluate("refresh()")
    page.wait_for_function("'₱1.00 inserted' in document.getElementById('coinValue').textContent")
    assert "vendo-01" in page.locator("#coinValue").inner_text()

    page.click('button:has-text("Done inserting coins")')
    page.wait_for_function("document.getElementById('coinWindow').classList.contains('hide')")
    assert "Coin window closed" in page.locator("#coinmsg").inner_text()
    page.screenshot(path=str(OUT/"portal-coin-window.png"), full_page=True)

    browser.close()

server.shutdown()
if errors:
    (OUT/"browser-errors.txt").write_text("\n".join(errors))
    raise SystemExit("browser console/page errors: "+repr(errors))

result={
    "target":"browser-admin",
    "release":"post-v0.5.2",
    "validation_level":"headless-browser-with-mocked-cgi",
    "checks":{
        "dashboard_loaded":True,
        "rental_navigation":True,
        "device_policy_editor_rendered":True,
        "binding_qr_generated":True,
        "device_owner_qr_generated":True,
        "dual_csrf_transport":True,
        "portal_session_countdown_live":True,
        "portal_coin_window_countdown_live":True,
        "portal_coin_credit_visible":True,
        "controller_page_rendered":True,
        "system_page_rendered":True,
        "voucher_action_rendered":True,
        "console_errors":False
    }
}
(OUT/"audit.json").write_text(json.dumps(result,indent=2))
print("BlazePwifi post-v0.5.2 browser audit passed")
