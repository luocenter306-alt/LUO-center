import {pbkdf2} from 'node:crypto';
const encoder=new TextEncoder();
const hex=(a:ArrayBuffer)=>Array.from(new Uint8Array(a),n=>n.toString(16).padStart(2,'0')).join('');
export const digest=async(s:string)=>hex(await crypto.subtle.digest('SHA-256',encoder.encode(s)));
const random=()=>hex(crypto.getRandomValues(new Uint8Array(32)).buffer);
const problem=(message:string,status=400)=>{throw Object.assign(new Error(message),{status})};
const stmt=(e:any,q:string,...a:any[])=>e.DB.prepare(q).bind(...a);
export function normalizeIdentifier(value:unknown){
 if(typeof value!=='string'||value.length>254)problem('请输入有效的邮箱或手机号');
 let v=(value as string).trim().toLowerCase();
 if(v.includes('@')){if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v))problem('邮箱格式不正确');return {identifier:v,kind:'email'}}
 v=v.replace(/[\s()-]/g,'');if(/^1[3-9]\d{9}$/.test(v))v='+86'+v;
 if(!/^\+[1-9]\d{7,14}$/.test(v))problem('请输入 11 位手机号，或带国家区号的号码');
 return {identifier:v,kind:'phone'};
}
async function passwordHash(password:string,salt:string){
 return new Promise<string>((resolve,reject)=>pbkdf2(password,salt,600000,32,'sha256',(error,result)=>error?reject(error):resolve(result.toString('hex'))));
}
function equals(a:string,b:string){let difference=a.length^b.length;for(let i=0;i<Math.max(a.length,b.length);i++)difference|=(a.charCodeAt(i)||0)^(b.charCodeAt(i)||0);return difference===0}
function tokenFrom(r:Request){return r.headers.get('cookie')?.split(';').map(x=>x.trim()).find(x=>x.startsWith('shenmo_session='))?.slice(15)||''}
function cookie(r:Request,token:string,maxAge=604800){return `shenmo_session=${token}; HttpOnly; SameSite=Lax; Path=/; Max-Age=${maxAge}${new URL(r.url).protocol==='https:'?'; Secure':''}`}
export async function sessionUser(r:Request,e:any){const token=tokenFrom(r);if(!/^[a-f0-9]{64}$/.test(token))return null;let user=await stmt(e,'SELECT u.*,c.identifier,c.kind FROM auth_sessions s JOIN users u ON u.id=s.user_id JOIN auth_credentials c ON c.user_id=u.id WHERE s.id=? AND s.expires_at>?',await digest(token),Date.now()).first();if(!user)return null;const roles=(await stmt(e,'SELECT role FROM user_roles WHERE user_id=?',user.id).all()).results.map((x:any)=>x.role);return {...user,roles}}
async function throttle(r:Request,e:any,identifier:string){
 const at=Date.now(),ip=r.headers.get('cf-connecting-ip')||'local';
 for(const [scope,limit] of [[identifier,10],['ip:'+ip,35]] as const){const id=await digest('auth:'+scope);await stmt(e,'INSERT INTO auth_limits (id,attempts,reset_at) VALUES (?,1,?) ON CONFLICT(id) DO UPDATE SET attempts=CASE WHEN reset_at<? THEN 1 ELSE attempts+1 END,reset_at=CASE WHEN reset_at<? THEN ? ELSE reset_at END',id,at+900000,at,at,at+900000).run();let row=await stmt(e,'SELECT attempts FROM auth_limits WHERE id=?',id).first();if(row.attempts>limit)problem('尝试次数过多，请 15 分钟后再试',429)}
}
export async function authAction(r:Request,e:any,action:string){
 if(r.method!=='POST')problem('不支持的方法',405);if(r.headers.get('origin')!==new URL(r.url).origin)problem('来源验证失败',403);if(!r.headers.get('content-type')?.includes('application/json'))problem('请求格式无效',415);
 const raw=await r.text();if(raw.length>4096)problem('请求过大',413);let b:any;try{b=JSON.parse(raw)}catch{problem('请求格式无效')}
 const headers={'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'};
 if(action==='auth-logout'){const token=tokenFrom(r);if(token)await stmt(e,'DELETE FROM auth_sessions WHERE id=?',await digest(token)).run();return Response.json({ok:true},{headers:{...headers,'Set-Cookie':cookie(r,'',0)}})}
 const {identifier,kind}=normalizeIdentifier(b.identifier);if(typeof b.password!=='string'||b.password.length<10||b.password.length>128)problem('密码需要 10–128 位字符');await throttle(r,e,identifier);
 let credentials=await stmt(e,'SELECT * FROM auth_credentials WHERE identifier=?',identifier).first();let id=credentials?.user_id;
 if(action==='auth-register'){
  if(credentials)problem('该账号已注册，请直接登录',409);
  const platformEmail=r.headers.get('oai-authenticated-user-email')?.toLowerCase();
  const adminRequested=kind==='email'&&identifier===e.ADMIN_EMAIL?.toLowerCase();
  const ownerProof=!!e.ADMIN_OWNER_EMAIL&&platformEmail===e.ADMIN_OWNER_EMAIL.toLowerCase();
  if(adminRequested&&!ownerProof)problem('此管理员账号需由站点所有者在私有站点内完成首次注册',403);
  let existing=await stmt(e,'SELECT id FROM users WHERE email=?',identifier).first();
  if(existing&&!ownerProof&&platformEmail!==identifier)problem('此账号已有历史数据，请联系管理员迁移',409);
  id=existing?.id||crypto.randomUUID();const salt=random(),hashed=await passwordHash(b.password,salt),at=new Date().toISOString();
  const queries=[stmt(e,'INSERT OR IGNORE INTO users (id,email,name,created_at) VALUES (?,?,?,?)',id,identifier,kind==='phone'?'用户'+identifier.slice(-4):identifier.split('@')[0],at),stmt(e,'INSERT INTO auth_credentials (id,user_id,identifier,kind,password_hash,salt,created_at) VALUES (?,?,?,?,?,?,?)',crypto.randomUUID(),id,identifier,kind,hashed,salt,at),stmt(e,'INSERT OR IGNORE INTO user_wallets VALUES (?,?)',crypto.randomUUID(),id)];
  if(adminRequested)queries.push(stmt(e,"INSERT INTO user_roles (id,user_id,role) VALUES (?,?,'SUPER_ADMIN')",crypto.randomUUID(),id),stmt(e,'INSERT INTO admin_audit_logs VALUES (?,?,?,?,?)',crypto.randomUUID(),id,'admin-account-activated',id,at));
  try{await e.DB.batch(queries)}catch{problem('账号无法创建，请尝试登录或稍后重试',409)}
 }else if(action==='auth-login'){
  const hashed=await passwordHash(b.password,credentials?.salt||'0000000000000000000000000000000000000000000000000000000000000000');if(!credentials||!equals(hashed,credentials.password_hash))problem('账号或密码不正确',401);
 }else problem('接口不存在',404);
 const token=random(),expires=Date.now()+604800000;await e.DB.batch([stmt(e,'DELETE FROM auth_sessions WHERE expires_at<?',Date.now()),stmt(e,'INSERT INTO auth_sessions (id,user_id,expires_at,created_at) VALUES (?,?,?,?)',await digest(token),id,expires,Date.now())]);
 return Response.json({ok:true},{headers:{...headers,'Set-Cookie':cookie(r,token)}});
}
