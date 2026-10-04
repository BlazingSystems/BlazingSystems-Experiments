#!/usr/bin/env python3
import hashlib, json, pathlib, shutil, sys

src=pathlib.Path(sys.argv[1])
dst=pathlib.Path(sys.argv[2])
stage=pathlib.Path(sys.argv[3])
dst.mkdir(parents=True,exist_ok=True)
stage.mkdir(parents=True,exist_ok=True)

items=[]
for p in sorted(src.rglob('*')):
    if not p.is_file():
        continue
    rel=p.relative_to(src)
    sha=hashlib.sha256(p.read_bytes()).hexdigest()
    kind='audit'
    if p.name.endswith('.img.gz'): kind='disk-image'
    elif p.name.endswith('.bin'): kind='firmware'
    elif p.name.endswith('.tar.gz'): kind='config-backup'
    elif p.name.endswith('.png'): kind='screenshot'
    release_name='simulation-'+p.name
    entry={'source':str(rel),'name':p.name,'release_asset':release_name,'size':p.stat().st_size,'sha256':sha,'kind':kind}
    items.append(entry)
    if kind in {'disk-image','firmware','config-backup','audit'}:
        shutil.copy2(p,stage/release_name)
    if kind in {'disk-image','firmware','config-backup'} and p.stat().st_size < 95*1024*1024:
        target=dst/p.name
        if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest()!=sha:
            target=dst/(p.parent.name+'-'+p.name)
        shutil.copy2(p,target)

levels={
 'x86_64':'full QEMU BIOS/UEFI boot plus runtime service/HTTP checks',
 'android':'signed APK installed as Device Owner in Android emulator plus reboot check',
 'orangepi':'production image partition + real ARM/AArch64 userspace execution; exact board peripherals not emulated',
 'esp':'compiled binary parse plus controller protocol/state simulation; no ESP8266 CPU-accurate VM claim',
 'ruijie':'production firmware structure/config audit; MT7621 board peripherals not emulated',
 'browser':'headless Chrome click-through audit with mocked CGI responses plus separate real backend tests'
}
manifest={'version':'0.3.0','generated_from':'GitHub environment simulation','levels':levels,'files':items}
(dst/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
with (dst/'SHA256SUMS').open('w') as f:
    for p in sorted(dst.iterdir()):
        if p.is_file() and p.name not in {'SHA256SUMS','manifest.json','README.md'}:
            f.write(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.name+'\n')
