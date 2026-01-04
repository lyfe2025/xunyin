<script setup lang="ts">
import { computed, ref } from 'vue'
import { Button } from '@/components/ui/button'
import { ExternalLink } from 'lucide-vue-next'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'

type DocType = 'swagger' | 'redoc'
const docType = ref<DocType>('redoc')

const apiBaseUrl = computed(() => {
  const apiUrl = import.meta.env.VITE_API_URL
  return apiUrl || ''
})

const docUrl = computed(() => {
  const base = apiBaseUrl.value
  return docType.value === 'swagger'
    ? base
      ? `${base}/api-docs`
      : '/api-docs'
    : base
      ? `${base}/redoc`
      : '/redoc'
})

const docTitle = computed(() => {
  return docType.value === 'swagger' ? 'Swagger UI' : 'Redoc'
})

function openInNewWindow() {
  window.open(docUrl.value, '_blank')
}
</script>

<template>
  <div class="flex flex-col" style="height: calc(100vh - 64px)">
    <!-- Header -->
    <div class="flex items-center justify-between p-4 border-b shrink-0">
      <div>
        <h2 class="text-xl font-bold tracking-tight">系统接口</h2>
        <p class="text-sm text-muted-foreground">{{ docTitle }} API 接口文档</p>
      </div>
      <div class="flex items-center gap-3">
        <ToggleGroup v-model="docType" type="single" variant="outline" size="sm">
          <ToggleGroupItem value="redoc">Redoc</ToggleGroupItem>
          <ToggleGroupItem value="swagger">Swagger</ToggleGroupItem>
        </ToggleGroup>
        <Button variant="outline" size="sm" @click="openInNewWindow">
          <ExternalLink class="mr-2 h-4 w-4" />
          新窗口打开
        </Button>
      </div>
    </div>

    <!-- Doc iframe -->
    <div class="flex-1 min-h-0">
      <iframe :src="docUrl" class="w-full h-full border-0" :title="`${docTitle} API 文档`" />
    </div>
  </div>
</template>
