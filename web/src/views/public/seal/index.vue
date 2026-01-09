<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { getPublicSealDetail, type PublicSealDetail } from '@/api/public/seal'
import { Award, MapPin, Clock, Link2, Download } from 'lucide-vue-next'

const route = useRoute()
const loading = ref(true)
const error = ref('')
const seal = ref<PublicSealDetail | null>(null)

// 格式化时间
const formattedEarnedTime = computed(() => {
  if (!seal.value?.earnedTime) return ''
  return new Date(seal.value.earnedTime).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
})

// 印记类型标签
const typeLabel = computed(() => {
  const typeMap: Record<string, string> = {
    route: '路线印记',
    city: '城市印记',
    special: '特殊印记',
  }
  return typeMap[seal.value?.type || ''] || '印记'
})

// 跳转下载页
function goToDownload() {
  window.location.href = '/download'
}

onMounted(async () => {
  const id = route.params.id as string
  if (!id) {
    error.value = '无效的分享链接'
    loading.value = false
    return
  }

  try {
    const res = await getPublicSealDetail(id)
    seal.value = res.data
  } catch {
    error.value = '印记不存在或已下架'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-amber-900 via-stone-800 to-stone-900">
    <!-- 加载状态 -->
    <div v-if="loading" class="min-h-screen flex items-center justify-center">
      <div class="text-white/60">加载中...</div>
    </div>

    <!-- 错误状态 -->
    <div v-else-if="error" class="min-h-screen flex flex-col items-center justify-center px-6">
      <Award class="w-16 h-16 text-white/30 mb-4" />
      <p class="text-white/60 text-lg mb-8">{{ error }}</p>
      <button
        class="px-6 py-3 bg-white text-amber-900 rounded-full font-medium hover:bg-white/90 transition-colors"
        @click="goToDownload"
      >
        下载寻印 App
      </button>
    </div>

    <!-- 印记详情 -->
    <div v-else-if="seal" class="min-h-screen flex flex-col">
      <!-- 顶部装饰 -->
      <div class="absolute top-0 left-0 right-0 h-64 bg-gradient-to-b from-amber-800/30 to-transparent pointer-events-none" />

      <!-- 内容区域 -->
      <div class="flex-1 flex flex-col items-center justify-center px-6 py-12 relative z-10">
        <!-- 用户信息 -->
        <div class="flex items-center gap-2 mb-6 text-white/70">
          <img
            v-if="seal.userAvatar"
            :src="seal.userAvatar"
            class="w-8 h-8 rounded-full object-cover"
            alt="avatar"
          />
          <div v-else class="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-sm">
            {{ seal.userNickname?.charAt(0) || '?' }}
          </div>
          <span class="text-sm">{{ seal.userNickname }} 获得了一枚印记</span>
        </div>

        <!-- 印记卡片 -->
        <div class="w-full max-w-sm bg-white/10 backdrop-blur-lg rounded-3xl p-6 border border-white/20 shadow-2xl">
          <!-- 印记图片 -->
          <div class="relative mb-6">
            <div class="aspect-square rounded-2xl overflow-hidden bg-gradient-to-br from-amber-600/20 to-amber-900/20 flex items-center justify-center">
              <img
                v-if="seal.imageAsset"
                :src="seal.imageAsset"
                :alt="seal.name"
                class="w-full h-full object-contain p-4"
              />
              <Award v-else class="w-24 h-24 text-amber-400/50" />
            </div>
            <!-- 类型标签 -->
            <div class="absolute top-3 right-3 px-3 py-1 bg-amber-500/80 text-white text-xs rounded-full">
              {{ typeLabel }}
            </div>
            <!-- 上链标识 -->
            <div
              v-if="seal.isChained"
              class="absolute bottom-3 right-3 flex items-center gap-1 px-2 py-1 bg-green-500/80 text-white text-xs rounded-full"
            >
              <Link2 class="w-3 h-3" />
              已上链
            </div>
          </div>

          <!-- 印记名称 -->
          <h1 class="text-2xl font-bold text-white text-center mb-2">
            {{ seal.name }}
          </h1>

          <!-- 称号 -->
          <div v-if="seal.badgeTitle" class="text-center mb-4">
            <span class="inline-block px-3 py-1 bg-amber-500/30 text-amber-300 text-sm rounded-full">
              {{ seal.badgeTitle }}
            </span>
          </div>

          <!-- 描述 -->
          <p v-if="seal.description" class="text-white/70 text-sm text-center mb-6 line-clamp-3">
            {{ seal.description }}
          </p>

          <!-- 信息列表 -->
          <div class="space-y-3 text-sm">
            <div v-if="seal.cityName || seal.journeyName" class="flex items-center gap-3 text-white/70">
              <MapPin class="w-4 h-4 shrink-0" />
              <span>{{ seal.cityName }}{{ seal.journeyName ? ` · ${seal.journeyName}` : '' }}</span>
            </div>
            <div v-if="formattedEarnedTime" class="flex items-center gap-3 text-white/70">
              <Clock class="w-4 h-4 shrink-0" />
              <span>{{ formattedEarnedTime }} 获得</span>
            </div>
          </div>
        </div>

        <!-- 下载引导 -->
        <div class="mt-8 text-center">
          <p class="text-white/50 text-sm mb-4">下载寻印 App，开启你的文化探索之旅</p>
          <button
            class="inline-flex items-center gap-2 px-8 py-4 bg-white text-amber-900 rounded-full font-semibold shadow-lg hover:bg-white/90 transition-all hover:scale-105 active:scale-95"
            @click="goToDownload"
          >
            <Download class="w-5 h-5" />
            立即下载
          </button>
        </div>
      </div>

      <!-- 底部品牌 -->
      <div class="py-6 text-center">
        <p class="text-white/30 text-xs">寻印 · 城市文化探索与数字印记收藏</p>
      </div>
    </div>
  </div>
</template>
