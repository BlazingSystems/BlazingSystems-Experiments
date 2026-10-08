// Node-only DOM stub validates REAL admin/rental.js async QR handling.
// No browser DOM, source mapping, network, account records or private tokens.
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const js=fs.readFileSync(path.join(__dirname,'../openwrt/rootfs/www/blazepwifi/admin/rental.js'),'utf8');
class FakeClassList{
 constructor(){this.set=new Set(['hidden']);}
 add(s){this.set.add(s);}
 remove(s){this.set.delete(s);}
 contains(s){return this.set.has(s);}
}
const nodes=new Map();
for(const name of ['addRentalModal','addRentalServer','addRentalLabel','qrResult','qrBox','qrNotice','qrMeta','qrToken','qrReveal']){
 nodes.set('#'+name,{value:'',textContent:'',innerHTML:'',classList:new FakeClassList(),hidden:true,onclick:null});
}
let rendererCount=0, calls=0, resolveApi, responses=[], alerts=[];
const fake={
 window:{BlazeCore:{
   api:()=>{calls++;return new Promise(resolve=>{resolveApi=resolve;});},
   toast:(msg,bad)=>alerts.push({msg,bad})
 }},
 location:{origin:'https://192.168.1.1:8443'},
 document:{querySelector:(sel)=>nodes.get(sel)||null},
 CSS:{escape:s=>s},
 qrcode:()=>({
   addData:(v)=>assert.equal(typeof v,'string'),
   make:()=>{},
   createSvgTag:()=>{rendererCount++;return '<svg data-test="QR"></svg>';}
 }),
 setTimeout:()=>{},
 confirm:()=>true,
 console
};
vm.runInNewContext(js,fake,{timeout:3000});
const get=n=>nodes.get('#'+n);
const qr=fake.window.BlazeRental;
const unmanaged={ok:true,qr_type:'binding',qr_payload:JSON.stringify({
 server_url:fake.location.origin, enrollment_token:'one-time-bind',
 device_name:'Fixture phone',server_cert_sha256:''}),
 enrollment_token:'one-time-bind',expires_seconds:600,server_url:fake.location.origin};
const managedPayload=pin=>JSON.stringify({
 'android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM':'base64-checksum',
 'android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION':'https://updates.example/BlazeRental.apk',
 'android.app.extra.PROVISIONING_ADMIN_EXTRAS_BUNDLE':{
   server_url:fake.location.origin,enrollment_token:'one-time-managed',
   device_name:'Fixture',server_cert_sha256:pin
 }
});
const managed=pin=>({ok:true,qr_type:'device_owner',qr_payload:managedPayload(pin),
 enrollment_token:'one-time-managed',expires_seconds:600,apk_version:'0.6-rc',apk_version_code:60000,
 apk_url:'https://updates.example/BlazeRental.apk'});
(async()=>{
 // An HTTP reply from a CLOSED modal must never resurrect its QR.
 qr.openAdd();
 const stale=qr.generateBindingQr();
 assert.equal(calls,1);
 qr.closeAdd();
 resolveApi(unmanaged);
 await stale;
 assert.equal(rendererCount,0,'stale QR must not render');
 assert.equal(get('qrResult').classList.contains('hidden'),true);
 // Reject server claiming "managed" mode but omitting local TLS pin.
 qr.openAdd();
 let pending=qr.generateProvisioningQr();
 resolveApi(managed(''));
 await pending;
 assert.equal(rendererCount,0,'unpinned Device Owner QR rendered');
 assert(alerts.some(x=>/missing certificate pin/i.test(x.msg)));
 assert.equal(get('qrResult').classList.contains('hidden'),true);
 // Valid managed QR displays encoded QR but NEVER puts secret in text until
 // operator explicitly clicks Reveal. This is display hygiene, not vaulting.
 const validPin='a'.repeat(64);
 pending=qr.generateProvisioningQr();
 resolveApi(managed(validPin));
 await pending;
 assert.equal(rendererCount,1);
 assert(!get('qrToken').textContent.includes('one-time-managed'),'secret shown without consent');
 assert.equal(get('qrReveal').hidden,false);
 assert(get('qrMeta').textContent.includes('included'));
 get('qrReveal').onclick();
 assert(get('qrToken').textContent.includes('one-time-managed'),'reveal action does not work');
 qr.closeAdd();
 assert.equal(get('qrToken').textContent,'','secret remained visible after close');
 // Error on wrong QR route: no accidental privilege confusion.
 qr.openAdd();
 pending=qr.generateProvisioningQr();
 resolveApi(unmanaged);
 await pending;
 assert.equal(rendererCount,1);
 assert(alerts.some(x=>/mode mismatch/i.test(x.msg)));
 console.log('PASS: rental QR browser model rejects stale responses, unpinned managed setup, reveals token only on request and distinguishes setup modes');
})().catch(error=>{console.error(error.stack||error);process.exitCode=1});
