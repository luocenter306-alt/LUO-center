import {MonitorCog} from 'lucide-react';
import BrandGlyph from './brand-glyph';
export function Mark({type='gpt',className=''}:{type?:string,className?:string}){const names:Record<string,string>={gpt:'openai',sail:'midjourney',claude:'claude',notion:'notion',cube:'cursor',adobe:'adobe'};return <div className={'mark '+className} aria-hidden="true">{names[type]?<BrandGlyph name={names[type]}/>:<MonitorCog size={56}/>}</div>}
