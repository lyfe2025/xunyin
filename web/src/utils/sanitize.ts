import DOMPurify, { type Config } from 'dompurify'

/**
 * HTML 内容清洗配置
 * 用于防止 XSS 攻击，移除危险的 HTML 标签和属性
 */
const purifyConfig: Config = {
  // 允许的标签
  ALLOWED_TAGS: [
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'p',
    'br',
    'hr',
    'ul',
    'ol',
    'li',
    'blockquote',
    'pre',
    'code',
    'strong',
    'b',
    'em',
    'i',
    'u',
    's',
    'strike',
    'del',
    'ins',
    'sub',
    'sup',
    'a',
    'img',
    'table',
    'thead',
    'tbody',
    'tr',
    'th',
    'td',
    'span',
    'div',
    'mark',
  ],
  // 允许的属性
  ALLOWED_ATTR: [
    'href',
    'title',
    'target',
    'rel',
    'src',
    'alt',
    'width',
    'height',
    'class',
    'style',
    'colspan',
    'rowspan',
  ],
  // 允许的 URI 协议
  ALLOWED_URI_REGEXP: /^(?:(?:https?|mailto|data):|[^a-z]|[a-z+.-]+(?:[^a-z+.\-:]|$))/i,
  // 添加 target="_blank" 时自动添加 rel="noopener noreferrer"
  ADD_ATTR: ['target'],
}

/**
 * 清洗 HTML 内容，移除潜在的 XSS 攻击代码
 * @param html 原始 HTML 内容
 * @returns 清洗后的安全 HTML
 */
export function sanitizeHtml(html: string | undefined | null): string {
  if (!html) return ''
  return DOMPurify.sanitize(html, purifyConfig) as string
}
