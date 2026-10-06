(function(){
'use strict';
const q=s=>document.querySelector(s), C=()=>window.BlazeCore;
function mins(sec){sec=Math.max(0,+sec||0);const h=Math.floor(sec/3600),m=Math.floor((sec%3600)/60);return h?h+'h '+m+'m':m+'m'}
function esc(v){return C().esc(v)}
function card(x){
  const user=esc(x.username||'');
  return '<div class="card member-card" data-member="'+user+'"><div class="card-body">'+
    '<div class="device-top"><div><div class="device-name">'+user+'</div><div class="device-meta">'+esc(x.label||'No label')+'</div></div>'+
    '<div class="toolbar"><span class="badge '+((+x.enabled)?'good':'bad')+'">'+((+x.enabled)?'ENABLED':'DISABLED')+'</span><span class="badge">rev '+esc(x.revision||0)+'</span></div></div>'+
    '<div class="switch-row"><span><b>Banked time</b><div class="small muted">Authoritative BlazePwifi balance</div></span><span class="badge good">'+mins(x.banked_seconds)+'</span></div>'+
    '<label><span class="field-label">Label / display name</span><input class="field label" value="'+esc(x.label||'')+'"></label>'+
    '<div class="switch-row"><span>Member enabled</span><input class="toggle enabled" type="checkbox" '+((+x.enabled)?'checked':'')+'></div>'+
    '<div class="toolbar" style="margin-top:12px"><button class="btn primary sm" onclick="BlazeMembers.save(\''+user+'\')">Save member</button><button class="btn sm" onclick="BlazeMembers.loadEvents(\''+user+'\')">Events</button></div>'+
    '<div class="form-grid" style="margin-top:14px"><label><span class="field-label">Minutes</span><input class="field minutes" type="number" min="0" max="525600" value="30"></label>'+
    '<label><span class="field-label">Balance action</span><select class="field balanceMode"><option value="add">Add</option><option value="subtract">Subtract</option><option value="set">Set exact</option></select></label></div>'+
    '<button class="btn sm" style="margin-top:10px" onclick="BlazeMembers.balance(\''+user+'\')">Apply banked time</button>'+
    '<div class="form-grid" style="margin-top:14px"><label class="span2"><span class="field-label">New member password</span><input class="field password" type="password" autocomplete="new-password" placeholder="Admin reset only"></label></div>'+
    '<div class="toolbar" style="margin-top:10px"><button class="btn sm" onclick="BlazeMembers.password(\''+user+'\')">Reset password</button><button class="btn danger sm" onclick="BlazeMembers.remove(\''+user+'\')">Delete member</button></div>'+
    '<div class="small muted" style="margin-top:10px">Updated '+(x.updated?new Date((+x.updated)*1000).toLocaleString():'—')+' · '+esc(x.source||'unknown')+'</div>'+
    '</div></div>';
}
function node(user){return document.querySelector('[data-member="'+CSS.escape(user)+'"]')}
async function load(render=true){
  const x=await C().api('member_list');
  if(!x.ok){if(render)C().toast(x.error||'Member load failed',true);return}
  if(q('#memberRevision'))q('#memberRevision').textContent='Central revision '+(x.revision||0);
  const items=x.members||[];
  if(render)q('#memberCards').innerHTML=items.length?items.map(card).join(''):'<div class="card empty">No Pisonet members yet.</div>';
}
async function create(){
  const username=q('#memberCreateUser').value.trim(),label=q('#memberCreateLabel').value.trim(),password=q('#memberCreatePassword').value;
  if(!username||password.length<4){C().toast('Username and a password of at least 4 characters are required',true);return}
  const x=await C().api('member_create',{username,label,password});
  q('#memberCreatePassword').value='';
  C().toast(x.ok?'Member created':(x.error||'Member creation failed'),!x.ok);
  if(x.ok){q('#memberCreateUser').value='';q('#memberCreateLabel').value='';await load();await loadEvents('')}
}
async function save(user){
  const n=node(user);if(!n)return;
  const x=await C().api('member_update',{username:user,label:n.querySelector('.label').value.trim(),enabled:n.querySelector('.enabled').checked?'1':'0'});
  C().toast(x.ok?'Member updated':(x.error||'Member update failed'),!x.ok);if(x.ok)load();
}
async function balance(user){
  const n=node(user);if(!n)return;
  const minutes=Math.max(0,parseInt(n.querySelector('.minutes').value||'0',10)||0);
  const x=await C().api('member_balance',{username:user,mode:n.querySelector('.balanceMode').value,seconds:String(minutes*60)});
  C().toast(x.ok?'Banked time updated':(x.error||'Balance update failed'),!x.ok);if(x.ok){await load();await loadEvents(user)}
}
async function password(user){
  const n=node(user);if(!n)return;const password=n.querySelector('.password').value;
  if(password.length<4){C().toast('Use at least 4 characters for the member password',true);return}
  const x=await C().api('member_password',{username:user,password});n.querySelector('.password').value='';
  C().toast(x.ok?'Member password reset':(x.error||'Password reset failed'),!x.ok);if(x.ok)loadEvents(user);
}
async function remove(user){
  if(!confirm('Delete Pisonet member '+user+'? Banked time and the account will be removed.'))return;
  const x=await C().api('member_delete',{username:user});
  C().toast(x.ok?'Member deleted':(x.error||'Delete failed'),!x.ok);if(x.ok){await load();await loadEvents('')}
}
async function transfer(){
  const from=q('#memberTransferFrom').value.trim(),to=q('#memberTransferTo').value.trim(),minutes=Math.max(1,parseInt(q('#memberTransferMinutes').value||'0',10)||0);
  const x=await C().api('member_transfer',{from_username:from,to_username:to,seconds:String(minutes*60)});
  C().toast(x.ok?'Member time transferred':(x.error||'Transfer failed'),!x.ok);if(x.ok){await load();await loadEvents(from)}
}
async function loadEvents(user){
  const x=await C().api('member_events',{username:user||'',limit:'64'});
  if(!x.ok){C().toast(x.error||'Member events failed',true);return}
  const e=x.events||[];
  q('#memberEvents').textContent=e.length?e.slice().reverse().map(v=>{
    const dt=v.timestamp?new Date((+v.timestamp)*1000).toLocaleString():'—';
    const delta=(+v.delta_seconds||0);return dt+'  '+(v.username||'')+'  '+(v.kind||'')+'  '+(delta>=0?'+':'')+delta+'s  '+(v.source||'');
  }).join('\n'):'No member events yet.';
}
window.BlazeMembers={load,create,save,balance,password,remove,transfer,loadEvents};
})();