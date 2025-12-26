<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import { ExternalLink } from 'lucide-vue-next'

const swaggerUrl = computed(() => {
  const apiUrl = import.meta.env.VITE_API_URL
  // 如果没有配置 API URL，使用当前域名的 /api-docs 路径（通过 nginx 代理）
  return apiUrl ? `${apiUrl}/api-docs` : '/api-docs'
})

function openSwagger() {
  window.open(swaggerUrl.value, '_blank')
}
</script>

<template>
  <div class="flex flex-col" style="height: calc(100vh - 64px)">
    <!-- Header -->
    <div class="flex items-center justify-between p-4 border-b shrink-0">
      <div>
        <h2 class="text-xl font-bold tracking-tight">系统接口</h2>
        <p class="text-sm text-muted-foreground">Swagger API 接口文档</p>
      </div>
      <Button variant="outline" size="sm" @click="openSwagger">
        <ExternalLink class="mr-2 h-4 w-4" />
        新窗口打开
      </Button>
    </div>

    <!-- Swagger iframe -->
    <div class="flex-1 min-h-0">
      <iframe
        :src="swaggerUrl"
        class="w-full h-full border-0"
        title="Swagger API 文档"
      />
    </div>
  </div>
</template>
