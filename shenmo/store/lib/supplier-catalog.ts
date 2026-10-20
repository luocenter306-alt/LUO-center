export const PROVIDER='prome666';
const ORIGIN='https://prome666.com';
const reject=(message:string,status=502)=>{throw Object.assign(new Error(message),{status})};
const statement=(e:any,sql:string,...args:any[])=>e.DB.prepare(sql).bind(...args);
export type SupplierSnapshot={categories:any[],products:any[]};
function text(v:unknown,max=500){return typeof v==='string'?v.replace(/<[^>]*>/g,'').replace(/[\u0000-\u001f]/g,' ').trim().slice(0,max):''}
function cents(v:unknown){const s=String(v);if(!/^\d{1,7}(\.\d{1,2})?$/.test(s))return null;const [a,b='']=s.split('.');let n=Number(a)*100+Number(b.padEnd(2,'0'));return Number.isSafeInteger(n)&&n>0?n:null}
function coverUrl(v:unknown){try{const u=new URL(String(v));return u.protocol==='https:'&&u.hostname==='imgurloss.xqd.cn'?u.href:null}catch{return null}}
function categoryFor(name:string){if(/flow|绘画|生图|生视频/i.test(name))return 'AI 绘画';if(/邮箱|gmail/i.test(name))return '办公效率';if(/gpt|claude|gemini|grok/i.test(name))return 'AI 对话';return '数字商品'}
function iconFor(name:string){if(/gpt/i.test(name))return 'gpt';if(/claude/i.test(name))return 'claude';if(/gemini|谷歌/i.test(name))return 'gemini';if(/grok/i.test(name))return 'grok';return 'nodes'}
export function normalizeSnapshot(snapshot:SupplierSnapshot){
 if(!snapshot||!Array.isArray(snapshot.categories)||!Array.isArray(snapshot.products)||snapshot.categories.length>100||snapshot.products.length>2000)reject('商品目录格式无效',400);
 const categories=new Map(snapshot.categories.filter(c=>Number.isSafeInteger(c.id)&&c.id>0&&Number(c.status)===1&&!Number(c.hide)).map(c=>[c.id,text(c.name,100)]));
 if(!categories.size)reject('来源没有可见分类，保留现有目录',409);
 const products=new Map<string,any>();let skipped=0;
 for(const p of snapshot.products){const name=text(p?.name,200),price=cents(p?.price),sourceCategory=categories.get(p?.category_id)||text(p?.category?.name,100);
  if(!Number.isSafeInteger(p?.id)||p.id<=0||!name||price===null||Number(p.status)!==1||Number(p.hide)||!categories.has(p.category_id)||/代理权限|升级代理|分站/.test(name)){skipped++;continue}
  const rawStock=String(p.stock??'未知').slice(0,100),stockQuantity=!Number(p.inventory_hidden)&&/^\d+$/.test(rawStock)?Number(rawStock):null;
  products.set(String(p.id),{id:`prome-${p.id}`,upstreamId:String(p.id),name,price,sourceCategory,category:categoryFor(name),icon:iconFor(name),cover:coverUrl(p.cover),stockLabel:rawStock,stockQuantity:Number.isSafeInteger(stockQuantity)?stockQuantity:null,upstreamStatus:1,distribution:Number(p.allow_distribution)===1?1:0,sourceUrl:ORIGIN,description:`${name}。交付内容和售后条款待审核确认。`});
 }
 if(!products.size)reject('未读取到有效商品，保留现有目录',409);
 return {products:[...products.values()],skipped};
}
export async function fetchSupplierCatalog(fetcher:typeof fetch=fetch):Promise<SupplierSnapshot>{
 const deadline=Date.now()+50000;
 async function read(path:string){const remaining=deadline-Date.now();if(remaining<=0)reject('供货站请求超时，请稍后再试',504);let r:Response;try{r=await fetcher(ORIGIN+path,{redirect:'error',signal:AbortSignal.timeout(Math.min(12000,remaining)),headers:{Accept:'application/json'}})}catch{reject('无法读取供货站目录，请稍后再试',502)}if(!r!.ok)reject(`供货站返回 ${r!.status}，现有数据未更改`);const raw=await r!.text();if(raw.length>2500000)reject('供货站响应过大');let j:any;try{j=JSON.parse(raw)}catch{reject('供货站未返回有效 JSON，现有数据未更改')}if(j.code!==200||!Array.isArray(j.data))reject('供货站目录接口返回异常');return j}
 const categories=(await read('/user/api/index/data')).data.filter((c:any)=>Number(c.status)===1&&!Number(c.hide));if(!categories.length||categories.length>50)reject('供货站分类返回异常');
 const products:any[]=[];
 for(const category of categories){if(!Number.isSafeInteger(category.id)||category.id<=0)reject('分类编号无效');let seen=new Set<string>();for(let page=1;page<=20;page++){const result=await read(`/user/api/index/commodity?categoryId=${category.id}&limit=100&page=${page}`);if(!result.data.length)break;const fingerprint=result.data.map((p:any)=>p.id).join(',');if(seen.has(fingerprint))reject('供货站分页异常，未更新目录');seen.add(fingerprint);products.push(...result.data);if(products.length>2000)reject('供货站商品超过单次同步上限');if(Number.isFinite(result.total)&&page*100>=result.total)break;if(result.total===undefined&&result.data.length<100)break;if(page===20)reject('供货站分页超过同步上限')}}
 return {categories,products};
}
export async function syncSupplierCatalog(e:any,actorId:string,snapshot?:SupplierSnapshot){
 const start=Date.now(),runId=crypto.randomUUID(),at=new Date(start).toISOString(),leaseKey='supplier-sync-lease-'+PROVIDER,leaseValue=String(start+120000)+':'+runId;
 await statement(e,'INSERT INTO settings (id,value) VALUES (?,?) ON CONFLICT(id) DO UPDATE SET value=excluded.value WHERE CAST(settings.value AS INTEGER)<?',leaseKey,leaseValue,start).run();const lease=await statement(e,'SELECT value FROM settings WHERE id=?',leaseKey).first();if(lease?.value!==leaseValue)reject('已有同步任务正在执行，请稍后刷新',409);
 try{
  await statement(e,'INSERT INTO supplier_sync_runs VALUES (?,?,?,?,0,0,0,?,?,NULL)',runId,PROVIDER,actorId,'RUNNING',snapshot?'目录文件导入':'读取公开商品目录',at).run();
  const normalized=normalizeSnapshot(snapshot||await fetchSupplierCatalog()),existing=new Map<string,any>((await statement(e,'SELECT * FROM supplier_products WHERE provider=?',PROVIDER).all()).results.map((p:any)=>[p.upstream_id,p]));let created=0,updated=0;
  const queries:any[]=[];
  for(const p of normalized.products){const old=existing.get(p.upstreamId),productId=old?.product_id||p.id;if(!old){created++;queries.push(statement(e,"INSERT INTO products (id,name,description,category,kind,icon,price,original_price,agent_price,state,reservable,source,supplier,evidence,sales_basis,review_note) VALUES (?,?,?,?,'DIGITAL',?,?,?,?,'DRAFT',0,?,?,?,?,?)",productId,p.name,p.description,p.category,p.icon,p.price,p.price,p.price,ORIGIN,'Prome 店铺',`公开目录商品编号 ${p.upstreamId}；同步时间 ${at}`,'','仅导入商品目录；来源与销售依据待人工核实，未接通上游采购。'))}else updated++;
   queries.push(statement(e,'INSERT INTO supplier_products (id,provider,upstream_id,product_id,upstream_name,upstream_category,upstream_price,cover_url,stock_label,stock_quantity,upstream_status,distribution,catalog_only,seen_at,source_url) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,1,?,?) ON CONFLICT(id) DO UPDATE SET upstream_name=excluded.upstream_name,upstream_category=excluded.upstream_category,upstream_price=excluded.upstream_price,cover_url=excluded.cover_url,stock_label=excluded.stock_label,stock_quantity=excluded.stock_quantity,upstream_status=excluded.upstream_status,distribution=excluded.distribution,seen_at=excluded.seen_at',`${PROVIDER}:${p.upstreamId}`,PROVIDER,p.upstreamId,productId,p.name,p.sourceCategory,p.price,p.cover,p.stockLabel,p.stockQuantity,p.upstreamStatus,p.distribution,at,p.sourceUrl));
  }
  // Mark missing items only after a complete successful network snapshot; partial/file imports are non-destructive.
  if(!snapshot)queries.push(statement(e,'UPDATE supplier_products SET upstream_status=0 WHERE provider=? AND seen_at<>?',PROVIDER,at));
  queries.push(statement(e,"UPDATE supplier_sync_runs SET status='SUCCEEDED',created_count=?,updated_count=?,skipped_count=?,message=?,completed_at=? WHERE id=?",created,updated,normalized.skipped,'仅同步目录，售价及审核结果保留，未修改本地库存',new Date().toISOString(),runId));
  queries.push(statement(e,'INSERT INTO admin_audit_logs VALUES (?,?,?,?,?)',crypto.randomUUID(),actorId,'supplier-catalog-sync',runId,at));
  // One atomic batch prevents partly applied catalog updates.
  await e.DB.batch(queries);return {created,updated,skipped:normalized.skipped,total:normalized.products.length,runId};
 }catch(error:any){await statement(e,"UPDATE supplier_sync_runs SET status='FAILED',message=?,completed_at=? WHERE id=?",String(error.message||'同步失败').slice(0,300),new Date().toISOString(),runId).run();throw error}
 finally{await statement(e,'DELETE FROM settings WHERE id=? AND value=?',leaseKey,leaseValue).run()}
}
