#!/usr/bin/env python3
import argparse, pexpect, os, json, gzip, shutil

p=argparse.ArgumentParser()
p.add_argument('--image',required=True)
p.add_argument('--mode',choices=['bios','uefi'],required=True)
p.add_argument('--out',required=True)
p.add_argument('--ovmf',default='')
a=p.parse_args()
os.makedirs(a.out,exist_ok=True)

cmd=['qemu-system-x86_64','-m','512','-smp','2','-drive',f'file={a.image},format=raw,if=virtio','-nic','user,model=virtio-net-pci','-display','none','-serial','stdio','-monitor','none','-no-reboot']
if a.mode=='uefi':
    if not a.ovmf:
        raise SystemExit('UEFI firmware path required')
    cmd += ['-bios',a.ovmf]

log=open(os.path.join(a.out,f'x86-{a.mode}-serial.log'),'wb')
child=pexpect.spawn(cmd[0],cmd[1:],encoding=None,timeout=240,logfile=log)
prompt=b'root@[^\\r\\n]+:[^\\r\\n]*#'
idx=child.expect([b'Please press Enter to activate this console',prompt,b'login:'],timeout=240)
if idx==0:
    ready=False
    for _ in range(12):
        child.send(b'\\r\\n')
        try:
            child.expect([prompt,b'# '],timeout=15)
            ready=True
            break
        except pexpect.TIMEOUT:
            pass
    if not ready:
        raise RuntimeError('OpenWrt serial console did not activate')
elif idx==2:
    child.send(b'root\\r\\n')
    child.expect([prompt,b'# '],timeout=60)

def run(command,timeout=60):
    marker='__BLAZE_RC__'
    child.sendline((command+'; echo '+marker+'$?').encode())
    child.expect((marker+r'(\d+)').encode(),timeout=timeout)
    rc=int(child.match.group(1))
    if rc:
        raise RuntimeError(f'command failed rc={rc}: {command}')

checks=[
 'test -x /usr/sbin/blazepwifi-core',
 'test -f /www/blazepwifi/index.html',
 'test -f /www/blazepwifi/admin.html',
 "uci -q get blazepwifi.main.portal_port | grep -qx 8080",
 "uci -q get blazepwifi.main.admin_port | grep -qx 8443",
 "uci -q get blazepwifi.main.vendo_port | grep -qx 4455",
 '/etc/init.d/uhttpd restart',
 '/etc/init.d/blazepwifi restart',
 'sleep 2',
 "netstat -lnt | grep -q ':8080'",
 "netstat -lnt | grep -q ':8443'",
 "netstat -lnt | grep -q ':4455'",
 "wget -qO- http://192.168.1.1:8080/index.html | grep -q BlazePwifi",
 "wget --no-check-certificate -qO- https://192.168.1.1:8443/admin.html | grep -q 'BlazePwifi Admin'",
 "BP_LIB=/usr/lib/blazepwifi/common.sh /usr/lib/blazepwifi/auth.sh --set-password admin admin 'VM-Audit-Password-2026!'",
 "uci set blazepwifi.main.rental_seconds_per_pulse='777'",
 'uci commit blazepwifi',
 'mkdir -p /etc/blazepwifi',
 "echo 'GitHub Actions VM functional audit passed' > /etc/blazepwifi/SIMULATION_OK",
 'sync'
]
for check in checks:
    run(check)

child.sendline(b'poweroff -f')
try:
    child.expect(pexpect.EOF,timeout=45)
except Exception:
    child.terminate(force=True)
log.close()

backup=os.path.join(a.out,f'BlazePwifi-x86_64-{a.mode.upper()}-configured-backup.img.gz')
with open(a.image,'rb') as src,gzip.open(backup,'wb',compresslevel=6) as dst:
    shutil.copyfileobj(src,dst,1024*1024)
json.dump({'mode':a.mode,'status':'PASS','backup':os.path.basename(backup),'checks':checks},open(os.path.join(a.out,f'x86-{a.mode}-audit.json'),'w'),indent=2)
