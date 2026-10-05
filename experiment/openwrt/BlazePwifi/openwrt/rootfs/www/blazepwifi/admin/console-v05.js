(function(){
'use strict';
const q=s=>document.querySelector(s), C=()=>window.BlazeCore;
function fmtTemp(v){const n=+v||0;return n?((n>1000?n/1000:n).toFixed(1)+' °C'):'Not reported'}
async function loadSystem(){
  const x=await C().api('system_info');
  if(!x.ok){C().toast(x.error||'Hardware detection failed',true);return}
  const text=[
    x.model||'Unknown device',
    x.cpu||'Unknown CPU',
    x.kernel||'Unknown kernel',
    'Rootfs '+(x.rootfs||'Unknown'),
    'Temperature '+fmtTemp(x.temperature_milli_c),
    'Wi-Fi '+(x.wifi?'detected':'not detected'),
    'USB '+(x.usb?'detected':'not detected')
  ].join(' • ');
  const s=q('#systemSummary'); if(s)s.textContent=text;
  const d=q('#systemDetails'); if(d)d.textContent=text;
  const w=q('#wispBadge'); if(w){w.textContent=x.wifi?'Available':'No Wi-Fi radio detected';w.className='badge '+(x.wifi?'good':'');}
  const wc=q('#wanCapability'); if(wc)wc.textContent=(x.wifi?'Ethernet/WISP capability detected. ':'No Wi-Fi WISP capability currently detected. ')+(x.usb?'USB devices present.':'No USB device currently detected.');
}
async function loadStorage(){
  const o=q('#storageOutput'); if(o)o.textContent='Loading mounts…';
  const x=await C().api('storage_list');
  if(!o)return;
  if(!x.ok){o.textContent=x.error||'Unable to read storage';return}
  o.textContent=String(x.mounts||'No mounts reported').split(';').filter(Boolean).map(v=>{
    const p=v.split('|'); return (p[3]||'?')+'  device '+(p[0]||'?')+'  used '+(p[2]||'?')+'/'+(p[1]||'?')+' KB';
  }).join('\n');
}
async function loadRemote(){
  const x=await C().api('remote_status');
  if(!x.ok){C().toast(x.error||'Remote status unavailable',true);return}
  const wg=q('#wgState'),zt=q('#ztState');
  if(wg){wg.textContent=x.wireguard||'Unavailable';wg.className='badge '+(String(x.wireguard).indexOf('online:')===0?'good':'');}
  if(zt){zt.textContent=x.zerotier||'Unavailable';zt.className='badge '+(String(x.zerotier).indexOf('ONLINE')>=0?'good':'');}
}
async function runTool(){
  const o=q('#toolOutput'),tool=q('#toolName').value,target=q('#toolTarget').value.trim();
  o.textContent='Running '+tool+'…';
  const x=await C().api('tool_run',{tool,target});
  o.textContent=x.ok?((x.output||'(no output)')+'\n\nExit code: '+x.exit_code):(x.error||'Tool failed');
  if(!x.ok)C().toast(x.error||'Tool failed',true);
}
async function loadLan(){
  const keys=['lan_if','management_if','hotspot_if','management_vlan','hotspot_vlan','controller_vlan','rental_vlan'];
  const vals=[];
  for(const key of keys){const x=await C().api('config_get',{key});if(x.ok)vals.push(key+'='+x.value)}
  const n=q('#lanConfig');if(n)n.textContent=vals.join(' • ')||'No network assignment reported.';
}
function onPage(name){
  if(name==='system'||name==='wan')loadSystem();
  if(name==='storage')loadStorage();
  if(name==='remote')loadRemote();
  if(name==='lan')loadLan();
}
window.BlazeConsole={loadSystem,loadStorage,loadRemote,runTool,loadLan,onPage};
setTimeout(()=>{loadSystem();loadRemote();},300);
})();