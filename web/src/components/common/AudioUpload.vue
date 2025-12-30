<script setup lang="ts">
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { useToast } from '@/components/ui/toast/use-toast'
import { Upload, X, Loader2, Music } from 'lucide-vue-next'
import { uploadAudio } from '@/api/upload'

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

const audioUrl = computed(() => props.modelValue || '')
const acceptTypes = computed(
  () => props.accept || 'audio/mpeg,audio/mp3,audio/wav,audio/ogg,audio/flac,audio/aac'
)
const maxSizeMB = computed(() => props.maxSize || 20)

function triggerUpload() {
  fileInput.value?.click()
}

async function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  target.value = ''

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
    const result = await uploadAudio(file)
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

function getFileName(url: string) {
  return url.split('/').pop() || '音频文件'
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

    <!-- 已上传音频 -->
    <div v-if="audioUrl" class="flex items-center gap-2 rounded-lg border p-3">
      <Music class="h-5 w-5 text-muted-foreground" />
      <span class="flex-1 truncate text-sm">{{ getFileName(audioUrl) }}</span>
      <audio :src="audioUrl" controls class="h-8 max-w-[200px]" />
      <Button variant="ghost" size="icon" class="h-8 w-8 text-destructive" @click="handleRemove">
        <X class="h-4 w-4" />
      </Button>
    </div>

    <!-- 上传按钮 -->
    <Button
      v-else
      type="button"
      variant="outline"
      :disabled="uploading"
      class="w-full justify-start gap-2"
      @click="triggerUpload"
    >
      <Loader2 v-if="uploading" class="h-4 w-4 animate-spin" />
      <Upload v-else class="h-4 w-4" />
      <span>{{ placeholder || '上传音频' }}</span>
    </Button>
  </div>
</template>
