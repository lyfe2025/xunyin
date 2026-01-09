<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getPublicDownloadConfig } from '@/api/public/config'

const loading = ref(true)
const config = ref<Record<string, unknown>>({})


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
  return {
    backgroundColor: '#ffffff',
    color: config.value.buttonPrimaryColor || '#C53D43',
  }
})

// 次要按钮样式
const secondaryButtonStyle = computed(() => {
  return {
    backgroundColor: config.value.buttonSecondaryColor || 'rgba(255,255,255,0.2)',
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
  if (config.value.iosStoreUrl) {
    window.location.href = config.value.iosStoreUrl
  }
}

function handleAndroidDownload() {
  const url = config.value.androidApkUrl || config.value.androidStoreUrl
  if (url) {
    window.location.href = url
  }
}

onMounted(async () => {
  try {
    const res = await getPublicDownloadConfig()
    config.value = res.data || {}
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

  <div v-else class="min-h-screen" :style="backgroundStyle">
    <!-- 内容容器 -->
    <div class="min-h-screen flex flex-col lg:flex-row lg:items-center lg:justify-center">
      <!-- 左侧/上方：App 信息 -->
      <div class="flex-1 flex flex-col items-center justify-center px-6 py-12 lg:py-20">
        <!-- App 图标 -->
        <img
          v-if="config.appIcon"
          :src="config.appIcon"
          class="w-24 h-24 lg:w-32 lg:h-32 rounded-3xl mb-6 shadow-xl"
          alt="App Icon"
        />
        <div
          v-else
          class="w-24 h-24 lg:w-32 lg:h-32 rounded-3xl mb-6 bg-white/10 flex items-center justify-center text-white text-3xl lg:text-4xl font-bold shadow-xl"
        >
          {{ config.appName?.charAt(0) || '寻' }}
        </div>

        <!-- App 名称和标语 -->
        <h1 class="text-white text-2xl lg:text-4xl font-bold mb-3 text-center">
          {{ config.appName || '寻印' }}
        </h1>
        <p class="text-white/70 text-base lg:text-lg text-center max-w-md mb-8">
          {{ config.appSlogan || '城市文化探索与数字印记收藏' }}
        </p>

        <!-- 功能特点 - PC 端横向排列 -->
        <div v-if="config.featureList?.length" class="w-full max-w-2xl">
          <div class="flex flex-col lg:flex-row lg:flex-wrap lg:justify-center gap-4">
            <div
              v-for="(feature, index) in config.featureList"
              :key="index"
              class="flex items-center gap-3 text-white/80 lg:bg-white/5 lg:px-4 lg:py-2 lg:rounded-full"
            >
              <div class="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-sm shrink-0 lg:w-6 lg:h-6 lg:text-xs">
                {{ Number(index) + 1 }}
              </div>
              <span class="text-sm lg:text-base">{{ feature }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧/下方：下载按钮 -->
      <div class="px-6 pb-12 lg:pb-0 lg:pr-20 lg:pl-0">
        <div class="flex flex-col gap-4 lg:min-w-[280px]">
          <!-- iOS 下载按钮 -->
          <button
            v-if="!isAndroid"
            :class="[
              'w-full h-14 lg:h-16 text-base lg:text-lg font-semibold flex items-center justify-center gap-3 shadow-lg transition-all hover:scale-105 active:scale-95',
              buttonRadiusClass
            ]"
            :style="primaryButtonStyle"
            @click="handleIOSDownload"
          >
            <svg class="w-6 h-6 lg:w-7 lg:h-7" viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"
              />
            </svg>
            App Store
          </button>

          <!-- Android 下载按钮 -->
          <button
            v-if="!isIOS"
            :class="[
              'w-full h-14 lg:h-16 text-base lg:text-lg font-medium flex items-center justify-center gap-3 transition-all hover:scale-105 active:scale-95',
              buttonRadiusClass
            ]"
            :style="isAndroid ? primaryButtonStyle : secondaryButtonStyle"
            @click="handleAndroidDownload"
          >
            <svg class="w-6 h-6 lg:w-7 lg:h-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <rect x="6" y="2" width="12" height="20" rx="2" />
              <circle cx="12" cy="18" r="1" fill="currentColor" />
            </svg>
            Android 下载
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
