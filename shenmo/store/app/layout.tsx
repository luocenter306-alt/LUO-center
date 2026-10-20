import type { Metadata } from 'next';
import './globals.css';
export const metadata:Metadata={title:'神墨 AI STORE · 让 AI，更简单',description:'AI 数字商品、精选工具与专业远程安装服务。'};
export default function Layout({children}:{children:React.ReactNode}){return <html lang="zh-CN"><body>{children}</body></html>}
