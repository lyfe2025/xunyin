import type { App } from 'vue'
import { hasPermi, hasRole } from './permission'

export default function directive(app: App) {
  app.directive('hasPermi', hasPermi)
  app.directive('hasRole', hasRole)
}
