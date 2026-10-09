import {cursor} from 'uci';
import {unlink,mkdir,chmod} from 'fs';
import {settings,readJSON,atomic,command} from './runtime.uc';
let cfg=settings(),u=cursor(),saved=readJSON('/etc/easymode-traffic/dns-owner.json',{}),sections=[];u.foreach('dhcp','dnsmasq',s=>push(sections,s));
let enabled=cfg.enabled&&cfg.domains&&ARGV[0]!='stop',changed=false;
if(enabled){
 mkdir('/tmp/easymode-traffic',0700);chmod('/tmp/easymode-traffic',0700);
 // Multiple dnsmasq instances may run with different permissions. Require an explicit integration.
 if(length(sections)!=1)exit(0);
 let s=sections[0],name=s['.name'];if(!saved.section){saved={section:name,logqueries:s.logqueries,logfacility:s.logfacility};atomic('/etc/easymode-traffic/dns-owner.json',saved);}
 if(u.get('dhcp',name,'logqueries')!='1'||u.get('dhcp',name,'logfacility')!='/tmp/easymode-traffic/dns.log'){u.set('dhcp',name,'logqueries','1');u.set('dhcp',name,'logfacility','/tmp/easymode-traffic/dns.log');changed=true;}
}else if(saved.section){
 // Restore only values still owned by this module, preserving subsequent admin edits.
 if(u.get('dhcp',saved.section,'logfacility')=='/tmp/easymode-traffic/dns.log')for(let k in ['logqueries','logfacility']){if(saved[k]!=null)u.set('dhcp',saved.section,k,saved[k]);else u.delete('dhcp',saved.section,k);changed=true;}
 unlink('/etc/easymode-traffic/dns-owner.json');unlink('/tmp/easymode-traffic/dns.log');
}
if(changed){u.commit('dhcp');command('/etc/init.d/dnsmasq restart >/dev/null 2>&1');}
