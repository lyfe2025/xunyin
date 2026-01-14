<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getPublicDownloadConfig, type DownloadConfig } from '@/api/public/config'

const loading = ref(true)
const config = ref<DownloadConfig>({})


// 背景样式
const backgroundStyle = computed(() => {
  const data = config.value
  if (data.backgroundType === 'image' && data.backgroundImage) {
    return {
      backgroundImage: `url(${data.backgroundImage})`,
      backgroundSize: 'cover',
      backgroundPosition: 'center',
    }
  } else if (data.backgroundType === 'gradient') {
    const start = data.gradientStart || '#8B4513'
    const end = data.gradientEnd || '#2C2C2C'
    const direction = data.gradientDirection || '135deg'
    return {
      background: `linear-gradient(${direction}, ${start}, ${end})`,
    }
  }
  return {
    backgroundColor: data.backgroundColor || '#2C2C2C',
  }
})

// 按钮圆角
const buttonRadiusClass = computed(() => {
  const radiusMap: Record<string, string> = {
    none: 'rounded-none',
    sm: 'rounded',
    md: 'rounded-lg',
    lg: 'rounded-xl',
    full: 'rounded-full',
  }
  return radiusMap[config.value.buttonRadius || 'full'] || 'rounded-full'
})

// 主按钮样式
const primaryButtonStyle = computed(() => {
  const style = config.value.buttonStyle || 'filled'
  const color = config.value.buttonPrimaryColor || '#C53D43'

  if (style === 'outlined') {
    return {
      backgroundColor: 'transparent',
      border: `2px solid ${color}`,
      color: color,
    }
  } else if (style === 'glass') {
    return {
      backgroundColor: 'rgba(255,255,255,0.15)',
      backdropFilter: 'blur(10px)',
      border: `1px solid ${color}`,
      color: color,
    }
  }
  // filled (default) - 白底彩字
  return {
    backgroundColor: '#ffffff',
    color: color,
  }
})

// 次要按钮样式
const secondaryButtonStyle = computed(() => {
  const style = config.value.buttonStyle || 'filled'
  const color = config.value.buttonSecondaryColor || 'rgba(255,255,255,0.2)'

  if (style === 'outlined') {
    return {
      backgroundColor: 'transparent',
      border: `2px solid rgba(255,255,255,0.5)`,
      color: '#ffffff',
    }
  } else if (style === 'glass') {
    return {
      backgroundColor: 'rgba(255,255,255,0.1)',
      backdropFilter: 'blur(10px)',
      border: `1px solid rgba(255,255,255,0.2)`,
      color: '#ffffff',
    }
  }
  // filled (default)
  return {
    backgroundColor: color,
    color: '#ffffff',
  }
})

// 检测设备类型
const isIOS = computed(() => {
  return /iPad|iPhone|iPod/.test(navigator.userAgent)
})

const isAndroid = computed(() => {
  return /Android/.test(navigator.userAgent)
})

// 下载处理
function handleIOSDownload() {
  const url = config.value.iosStoreUrl
  if (url && typeof url === 'string') {
    window.location.href = url
  }
}

function handleAndroidDownload() {
  const url = config.value.androidApkUrl || config.value.androidStoreUrl
  if (url && typeof url === 'string') {
    window.location.href = url
  }
}

onMounted(async () => {
  try {
    const res = await getPublicDownloadConfig()
    if (res.data) {
      config.value = res.data

      // 动态设置页面标题
      if (res.data.pageTitle) {
        document.title = res.data.pageTitle
      }

      // 动态设置 Favicon
      if (res.data.favicon) {
        // 移除现有的 favicon
        const existingFavicon = document.querySelector("link[rel*='icon']")
        if (existingFavicon) {
          existingFavicon.remove()
        }

        // 添加新的 favicon
        const link = document.createElement('link')
        link.rel = 'icon'
        link.type = res.data.favicon.endsWith('.ico') ? 'image/x-icon' : 'image/png'
        link.href = res.data.favicon
        document.head.appendChild(link)
      }
    }
  } catch (error) {
    console.error('获取下载页配置失败', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div v-if="loading" class="min-h-screen flex items-center justify-center bg-gray-900">
    <div class="text-white">加载中...</div>
  </div>

  <div v-else class="min-h-screen flex flex-col" :style="backgroundStyle">
    <!-- 移动端布局：垂直居中 -->
    <div class="flex-1 flex flex-col items-center justify-center px-6 lg:hidden">
      <!-- Logo + 名称 + 标语整体（带浮动动画） -->
      <div
        class="flex flex-col items-center"
        :class="{ 'logo-float': config.logoAnimationEnabled !== false }"
      >
        <!-- App 图标 -->
        <img
          v-if="config.appIcon"
          :src="config.appIcon"
          class="w-20 h-20 rounded-[18px] mb-4 shadow-xl"
          alt="App Icon"
        />
        <div
          v-else
          class="w-20 h-20 rounded-[18px] mb-4 bg-white/10 flex items-center justify-center text-white text-3xl font-bold shadow-xl"
        >
          {{ config.appName?.charAt(0) || '寻' }}
        </div>

        <!-- App 名称 -->
        <h1 class="text-white text-2xl font-bold mb-1.5 text-center" style="letter-spacing: 3px">
          {{ config.appName || '寻印' }}
        </h1>

        <!-- App 标语 -->
        <p
          class="text-xs text-center max-w-md mb-8"
          style="letter-spacing: 0.5px"
          :style="{ color: config.sloganColor || 'rgba(255,255,255,0.7)' }"
        >
          {{ config.appSlogan || '城市文化探索与数字印记收藏' }}
        </p>
      </div>

      <!-- 功能特点 -->
      <div v-if="config.featureList?.length" class="w-full max-w-2xl mb-8">
        <div class="flex flex-col gap-4">
          <div
            v-for="(feature, index) in config.featureList"
            :key="index"
            class="flex items-center gap-3 text-white/80 bg-white/5 backdrop-blur-sm px-4 py-3 rounded-xl"
          >
            <div class="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-sm shrink-0">
              {{ Number(index) + 1 }}
            </div>
            <span class="text-sm">{{ typeof feature === 'object' ? feature.title : feature }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 移动端下载按钮 -->
    <div class="px-6 pb-6 lg:hidden">
      <div class="flex flex-col gap-4">
        <!-- iOS 下载按钮 - iOS设备优先显示 -->
        <button
          v-if="!isAndroid"
          :class="[
            'w-full h-14 text-base font-semibold flex items-center justify-center gap-3 shadow-lg transition-all hover:scale-105 active:scale-95',
            buttonRadiusClass
          ]"
          :style="primaryButtonStyle"
          @click="handleIOSDownload"
        >
          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
            <path
              d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"
            />
          </svg>
          {{ config.iosButtonText || 'App Store' }}
        </button>

        <!-- Android 下载按钮 - Android设备优先显示 -->
        <button
          v-if="!isIOS"
          :class="[
            'w-full h-14 text-base font-medium flex items-center justify-center gap-3 transition-all hover:scale-105 active:scale-95',
            buttonRadiusClass,
            isAndroid ? 'shadow-lg' : ''
          ]"
          :style="isAndroid ? primaryButtonStyle : secondaryButtonStyle"
          @click="handleAndroidDownload"
        >
          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <rect x="6" y="2" width="12" height="20" rx="2" />
            <circle cx="12" cy="18" r="1" fill="currentColor" />
          </svg>
          {{ config.androidButtonText || 'Android 下载' }}
        </button>
      </div>
    </div>

    <!-- 桌面端布局 -->
    <div class="hidden lg:flex min-h-screen flex-row items-center justify-center">
      <!-- 左侧：App 信息 -->
      <div class="flex-1 flex flex-col items-center justify-center px-6 py-20">
        <!-- Logo + 名称 + 标语整体（带浮动动画） -->
        <div
          class="flex flex-col items-center"
          :class="{ 'logo-float': config.logoAnimationEnabled !== false }"
        >
          <!-- App 图标 -->
          <img
            v-if="config.appIcon"
            :src="config.appIcon"
            class="w-32 h-32 rounded-3xl mb-6 shadow-xl"
            alt="App Icon"
          />
          <div
            v-else
            class="w-32 h-32 rounded-3xl mb-6 bg-white/10 flex items-center justify-center text-white text-4xl font-bold shadow-xl"
          >
            {{ config.appName?.charAt(0) || '寻' }}
          </div>

          <!-- App 名称 -->
          <h1 class="text-white text-4xl font-bold mb-3 text-center" style="letter-spacing: 4px">
            {{ config.appName || '寻印' }}
          </h1>

          <!-- App 标语 -->
          <p
            class="text-lg text-center max-w-md mb-8"
            style="letter-spacing: 1px"
            :style="{ color: config.sloganColor || 'rgba(255,255,255,0.7)' }"
          >
            {{ config.appSlogan || '城市文化探索与数字印记收藏' }}
          </p>
        </div>

        <!-- 功能特点 - PC 端横向排列 -->
        <div v-if="config.featureList?.length" class="w-full max-w-2xl">
          <div class="flex flex-row flex-wrap justify-center gap-4">
            <div
              v-for="(feature, index) in config.featureList"
              :key="index"
              class="flex items-center gap-3 text-white/80 bg-white/5 backdrop-blur-sm px-4 py-3 rounded-full"
            >
              <div class="w-6 h-6 rounded-full bg-white/10 flex items-center justify-center text-xs shrink-0">
                {{ Number(index) + 1 }}
              </div>
              <span class="text-base">{{ typeof feature === 'object' ? feature.title : feature }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：下载按钮 -->
      <div class="pr-20 pl-0">
        <div class="flex flex-col gap-4 min-w-[280px]">
          <!-- iOS 下载按钮 -->
          <button
            :class="[
              'w-full h-16 text-lg font-semibold flex items-center justify-center gap-3 shadow-lg transition-all hover:scale-105 active:scale-95',
              buttonRadiusClass
            ]"
            :style="primaryButtonStyle"
            @click="handleIOSDownload"
          >
            <svg class="w-7 h-7" viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"
              />
            </svg>
            {{ config.iosButtonText || 'App Store' }}
          </button>

          <!-- Android 下载按钮 -->
          <button
            :class="[
              'w-full h-16 text-lg font-medium flex items-center justify-center gap-3 transition-all hover:scale-105 active:scale-95',
              buttonRadiusClass
            ]"
            :style="secondaryButtonStyle"
            @click="handleAndroidDownload"
          >
            <svg class="w-7 h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <rect x="6" y="2" width="12" height="20" rx="2" />
              <circle cx="12" cy="18" r="1" fill="currentColor" />
            </svg>
            {{ config.androidButtonText || 'Android 下载' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Logo 浮动动画 */
@keyframes logo-float {
  0%,
  100% {
    transform: translateY(-4px);
  }
  50% {
    transform: translateY(4px);
  }
}

.logo-float {
  animation: logo-float 2s ease-in-out infinite;
}
</style>
