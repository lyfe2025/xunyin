import * as XLSX from 'xlsx'

/**
 * 下载 Blob 文件
 */
export function downloadBlob(blob: Blob, filename: string) {
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(url)
}

/**
 * 导出数据为 Excel (.xlsx)
 */
export function exportToExcel<T extends Record<string, any>>(
  data: T[],
  columns: { key: keyof T; label: string }[],
  filename: string,
  sheetName = 'Sheet1'
) {
  // 构建表头和数据
  const headers = columns.map((c) => c.label)
  const rows = data.map((row) =>
    columns.map((c) => {
      const value = row[c.key]
      return value ?? ''
    })
  )

  // 创建工作表
  const worksheet = XLSX.utils.aoa_to_sheet([headers, ...rows])

  // 设置列宽（自动适应）
  const colWidths = columns.map((col, index) => {
    const maxLength = Math.max(
      col.label.length * 2, // 中文字符宽度
      ...rows.map((row) => String(row[index] ?? '').length)
    )
    return { wch: Math.min(maxLength + 2, 50) }
  })
  worksheet['!cols'] = colWidths

  // 创建工作簿
  const workbook = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(workbook, worksheet, sheetName)

  // 导出文件
  XLSX.writeFile(workbook, `${filename}.xlsx`)
}

/**
 * 导出数据为 CSV
 */
export function exportToCsv<T extends Record<string, any>>(
  data: T[],
  columns: { key: keyof T; label: string }[],
  filename: string
) {
  const headers = columns.map((c) => c.label).join(',')
  const rows = data.map((row) =>
    columns
      .map((c) => {
        const value = row[c.key]
        // 处理包含逗号或换行的值
        if (typeof value === 'string' && (value.includes(',') || value.includes('\n'))) {
          return `"${value.replace(/"/g, '""')}"`
        }
        return value ?? ''
      })
      .join(',')
  )
  const csv = [headers, ...rows].join('\n')
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' })
  downloadBlob(blob, `${filename}.csv`)
}

/**
 * 导出数据为 JSON
 */
export function exportToJson<T>(data: T[], filename: string) {
  const json = JSON.stringify(data, null, 2)
  const blob = new Blob([json], { type: 'application/json' })
  downloadBlob(blob, `${filename}.json`)
}

/**
 * 格式化日期用于文件名
 */
export function getExportFilename(prefix: string) {
  const now = new Date()
  const date = now.toISOString().slice(0, 10).replace(/-/g, '')
  return `${prefix}_${date}`
}
