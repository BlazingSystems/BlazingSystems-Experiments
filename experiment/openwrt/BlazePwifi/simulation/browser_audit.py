#!/usr/bin/env python3
import os, ssl, json, threading, urllib.parse
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

ROOT=os.path.abspath('experiment/openwrt/BlazePwifi/openwrt/rootfs/www/blazepwifi')
OUT='simulation-results/browser'
os.makedirs(OUT,exist_ok=True)
report={'steps':[],'links':[]}
logged=False

class Handler(SimpleHTTPRequestHandler):
    def translate_path(self,path):
        clean=urllib.parse.urlparse(path).path.lstrip('/') or 'index.html'
        return os.path.join(ROOT,clean)
    def log_message(self,*args):
        pass
    def do_HEAD(self):
        if self.path.startswith('/vendor/tabler/'):
            self.send_response(404); self.end_headers(); return
        super().do_HEAD()
    def send_json(self,obj):
        data=json.dumps(obj).encode()
        self.send_response(200)
        self.send_header('Content-Type','application/json')
        self.send_header('Content-Length',str(len(data)))
        self.end_headers()
        self.wfile.write(data)
    def do_GET(self):
        global logged
        if self.path.startswith('/cgi-bin/admin-session'):
            self.send_json({'ok':True,'csrf':'csrf123','username':'admin','role':'admin','must_change':0} if logged else {'ok':False,'error':'unauthorized'})
            return
        super().do_GET()
    def do_POST(self):
        global logged
        size=int(self.headers.get('Content-Length','0'))
        params=urllib.parse.parse_qs(self.rfile.read(size).decode())
        endpoint=urllib.parse.urlparse(self.path).path
        if endpoint.endswith('admin-login'):
            logged=True
            return self.send_json({'ok':True,'csrf':'csrf123','username':'admin','role':'admin','must_change':0})
        if endpoint.endswith('admin-logout'):
            logged=False
            return self.send_json({'ok':True})
        if endpoint.endswith('/admin'):
            action=params.get('action',[''])[0]
            replies={
              'status':{'ok':True,'active_sessions':2,'paused_sessions':1,'online_vendos':1,'mem_available_kb':32100,'load1':'0.08','must_change':0},
              'voucher_create':{'ok':True,'code':'SIM12345','cents':100},
              'config_get':{'ok':True,'key':'rental_seconds_per_pulse','value':'600'},
              'config_set':{'ok':True},
              'rental_enroll_create':{'ok':True,'enrollment_token':'abcdef123456.1234567890abcdef1234567890abcdef'},
              'rental_list':{'ok':True,'devices':[{'device_id':'0123456789abcdef01234567','label':'Phone 01','lease_until':4102444800,'last_seen':2000000000,'allowed_packages':'*','preferred_vendo':'vendo-01','admin_password_set':True,'inventory':'com.android.chrome,com.example.game'}]},
              'rental_policy_set':{'ok':True},'rental_lease_set':{'ok':True},'rental_admin_password_set':{'ok':True},
              'controller_list':{'ok':True,'controllers':[{'id':'vendo-01','last_seen':4102444800,'ip':'192.168.1.55','enabled':1,'coin_enabled':1,'relay_enabled':1,'led_enabled':1,'coin_pin':-1,'relay_pin':-1,'led_pin':-1,'coin_active_low':1,'relay_active_high':1,'led_active_high':1,'coin_debounce_ms':40,'pulse_group_ms':400,'max_wifi_retries':6,'config_revision':2}]},
              'controller_set':{'ok':True},
            }
            return self.send_json(replies.get(action,{'ok':True}))
        self.send_json({'ok':True})

def step(name,fn):
    try:
        fn()
        report['steps'].append({'name':name,'status':'PASS'})
    except Exception as exc:
        report['steps'].append({'name':name,'status':'FAIL','error':str(exc)})
        raise

server=ThreadingHTTPServer(('127.0.0.1',8443),Handler)
ctx=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain('/tmp/blaze-cert.pem','/tmp/blaze-key.pem')
server.socket=ctx.wrap_socket(server.socket,server_side=True)
threading.Thread(target=server.serve_forever,daemon=True).start()

opts=Options()
for arg in ['--headless=new','--no-sandbox','--ignore-certificate-errors','--window-size=1280,900']:
    opts.add_argument(arg)
driver=webdriver.Chrome(options=opts)
wait=WebDriverWait(driver,10)

def click_button(name):
    wait.until(EC.element_to_be_clickable((By.XPATH,"//button[normalize-space()='"+name+"']"))).click()

step('Portal home',lambda:(driver.get('https://127.0.0.1:8443/index.html?preview=1'),wait.until(EC.presence_of_element_located((By.ID,'coinHero')))))
driver.save_screenshot(OUT+'/01-portal.png')
step('Insert Coin',lambda:driver.find_element(By.ID,'coinHero').click())
step('Open coin slot',lambda:click_button('Open coin slot'))
step('Done inserting coins',lambda:click_button('Done inserting coins'))
step('Buy Time',lambda:driver.find_element(By.ID,'buyHero').click())
step('Rate buttons',lambda:[driver.execute_script('arguments[0].scrollIntoView({block:\"center\"}); arguments[0].click();',b) for b in driver.find_elements(By.CSS_SELECTOR,'#rates button')])
step('Voucher',lambda:(driver.find_element(By.ID,'voucherHero').click(),driver.find_element(By.ID,'voucher').send_keys('SIM-VOUCHER'),click_button('Redeem')))
step('Pause Resume End',lambda:[click_button(x) for x in ['Pause time','Resume time','End session']])
driver.save_screenshot(OUT+'/02-portal-details.png')

step('Admin login',lambda:(driver.get('https://127.0.0.1:8443/admin.html'),wait.until(EC.visibility_of_element_located((By.ID,'username'))),driver.find_element(By.ID,'username').send_keys('admin'),driver.find_element(By.ID,'password').send_keys('SimulationPass123!'),click_button('Sign in'),wait.until(EC.visibility_of_element_located((By.ID,'app')))))
step('Voucher create',lambda:click_button('Create'))
step('Rental seconds',lambda:(driver.find_element(By.ID,'rentalPulseSeconds').clear(),driver.find_element(By.ID,'rentalPulseSeconds').send_keys('777'),click_button('Save seconds per pulse')))
step('Rental enrollment',lambda:click_button('Create enrollment'))
step('Rental policy/time/password',lambda:(wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR,'[data-act=policy]'))).click(),driver.find_element(By.CSS_SELECTOR,'[data-act=lease]').click(),driver.find_element(By.CSS_SELECTOR,'[id^=phonepass_]').send_keys('PhoneAdmin123!'),driver.find_element(By.CSS_SELECTOR,'[data-act=pass]').click()))
step('Controller policy',lambda:wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR,'[data-save]'))).click())
href=driver.find_element(By.LINK_TEXT,'Open PC QR Setup tool').get_attribute('href')
report['links'].append(href)
if 'BlazeRental-QR-Setup.html' not in href:
    raise RuntimeError('QR setup link invalid')
driver.save_screenshot(OUT+'/03-admin.png')
step('Sign out',lambda:click_button('Sign out'))

json.dump(report,open(OUT+'/browser-audit.json','w'),indent=2)
driver.quit()
server.shutdown()
