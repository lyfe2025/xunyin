<script setup lang="ts">
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { useToast } from '@/components/ui/toast/use-toast'
import { Upload, X, Loader2, Image as ImageIcon } from 'lucide-vue-next'
import { uploadImage } from '@/api/upload'

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

const imageUrl = computed(() => props.modelValue || '')
const acceptTypes = computed(
  () => props.accept || 'image/jpeg,image/png,image/gif,image/webp,image/svg+xml'
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

    <!-- 已上传图片预览 -->
    <div v-if="imageUrl" class="relative inline-block">
      <img :src="imageUrl" alt="preview" class="h-24 w-24 rounded-lg border object-cover" />
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
          <ImageIcon class="h-6 w-6 text-muted-foreground" />
          <span class="text-xs text-muted-foreground">{{ placeholder || '上传图片' }}</span>
        </template>
      </Button>
    </div>
  </div>
</template>
