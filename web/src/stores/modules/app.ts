import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getSiteConfig, type SiteConfig } from '@/api/system/site'
import { setupLoginRoute } from '@/router'

export const useAppStore = defineStore('app', () => {
  // 网站配置
  const siteConfig = ref<SiteConfig>({
    name: '寻印管理后台',
    description: '城市文化探索与数字印记收藏平台',
    logo: '',
    favicon: '',
    copyright: '© 2025 Xunyin. All rights reserved.',
    icp: '',
    loginPath: '/login',
  })

  const siteConfigLoaded = ref(false)

  /**
   * 加载网站配置
   */
  async function loadSiteConfig() {
    if (siteConfigLoaded.value) return

    try {
      const res = (await getSiteConfig()) as unknown as { data: SiteConfig }
      if (res.data) {
        siteConfig.value = res.data
        // 更新页面标题
        if (res.data.name) {
          document.title = res.data.name
        }
        // 更新 favicon
        if (res.data.favicon) {
          updateFavicon(res.data.favicon)
        }
        // 设置登录路由（根据配置的路径）
        setupLoginRoute(res.data.loginPath || '/login')
      }
      siteConfigLoaded.value = true
    } catch (error) {
      console.error('加载网站配置失败:', error)
      // 加载失败时使用默认登录路径
      setupLoginRoute('/login')
      siteConfigLoaded.value = true
    }
  }

  /**
   * 更新 favicon
   */
  function updateFavicon(url: string) {
    let link = document.querySelector("link[rel*='icon']") as HTMLLinkElement
    if (!link) {
      link = document.createElement('link')
      link.rel = 'icon'
      document.head.appendChild(link)
    }
    link.href = url
  }

  /**
   * 刷新网站配置（设置保存后调用）
   */
  async function refreshSiteConfig() {
    siteConfigLoaded.value = false
    await loadSiteConfig()
  }

  return {
    siteConfig,
    siteConfigLoaded,
    loadSiteConfig,
    refreshSiteConfig,
  }
})
