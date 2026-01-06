<script setup lang="ts">
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { useToast } from '@/components/ui/toast/use-toast'
import { X, Loader2, Image as ImageIcon, Video } from 'lucide-vue-next'
import { uploadImage } from '@/api/upload'
import { getResourceUrl } from '@/utils/url'

const props = defineProps<{
  modelValue?: string
  accept?: string
  maxSize?: number // MB
  placeholder?: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const { toast } = useToast()
const uploading = ref(false)
const fileInput = ref<HTMLInputElement>()

// 显示用的完整 URL
const displayUrl = computed(() => getResourceUrl(props.modelValue))
// 原始值（用于判断是否有值）
const hasMedia = computed(() => !!props.modelValue)
// 判断是否为视频类型
const isVideo = computed(() => {
  if (!props.modelValue) return false
  const url = props.modelValue.toLowerCase()
  return (
    url.endsWith('.mp4') || url.endsWith('.webm') || url.endsWith('.mov') || url.endsWith('.avi')
  )
})
// 判断 accept 是否为视频类型
const isVideoAccept = computed(() => props.accept?.includes('video'))
const acceptTypes = computed(
  () => props.accept || 'image/jpeg,image/png,image/gif,image/webp,image/svg+xml',
)
const maxSizeMB = computed(() => props.maxSize || 5)

function triggerUpload() {
  fileInput.value?.click()
}

async function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  // 重置 input，允许重复选择同一文件
  target.value = ''

  // 校验文件大小
  if (file.size > maxSizeMB.value * 1024 * 1024) {
    toast({
      title: '文件过大',
      description: `请选择小于 ${maxSizeMB.value}MB 的文件`,
      variant: 'destructive',
    })
    return
  }

  uploading.value = true
  try {
    const result = await uploadImage(file)
    emit('update:modelValue', result.url)
    toast({ title: '上传成功' })
  } catch (error: unknown) {
    const err = error as { message?: string }
    toast({
      title: '上传失败',
      description: err.message || '请稍后重试',
      variant: 'destructive',
    })
  } finally {
    uploading.value = false
  }
}

function handleRemove() {
  emit('update:modelValue', '')
}
</script>

<template>
  <div class="space-y-2">
    <input
      ref="fileInput"
      type="file"
      :accept="acceptTypes"
      class="hidden"
      @change="handleFileChange"
    />

    <!-- 已上传媒体预览 -->
    <div v-if="hasMedia" class="relative inline-block">
      <!-- 视频预览 -->
      <video
        v-if="isVideo"
        :src="displayUrl"
        class="h-24 w-24 rounded-lg border object-cover"
        muted
        loop
        autoplay
      />
      <!-- 图片预览 -->
      <img
        v-else
        :src="displayUrl"
        alt="preview"
        class="h-24 w-24 rounded-lg border object-cover"
      />
      <Button
        variant="destructive"
        size="icon"
        class="absolute -right-2 -top-2 h-6 w-6"
        @click="handleRemove"
      >
        <X class="h-3 w-3" />
      </Button>
    </div>

    <!-- 上传按钮 -->
    <div v-else>
      <Button
        type="button"
        variant="outline"
        :disabled="uploading"
        class="h-24 w-24 flex-col gap-2"
        @click="triggerUpload"
      >
        <Loader2 v-if="uploading" class="h-6 w-6 animate-spin" />
        <template v-else>
          <Video v-if="isVideoAccept" class="h-6 w-6 text-muted-foreground" />
          <ImageIcon v-else class="h-6 w-6 text-muted-foreground" />
          <span class="text-xs text-muted-foreground">{{ placeholder || '上传图片' }}</span>
        </template>
      </Button>
    </div>
  </div>
</template>
