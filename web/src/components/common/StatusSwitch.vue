<script setup lang="ts">
import { ref } from 'vue'
import { Switch } from '@/components/ui/switch'
import { Loader2 } from 'lucide-vue-next'
import { useToast } from '@/components/ui/toast/use-toast'

interface Props {
  modelValue: string
  id: string
  activeValue?: string
  inactiveValue?: string
  activeText?: string
  inactiveText?: string
  showText?: boolean
}

interface Emits {
  (e: 'update:modelValue', value: string): void
  (e: 'change', id: string, value: string): Promise<void> | void
}

const props = withDefaults(defineProps<Props>(), {
  activeValue: '0',
  inactiveValue: '1',
  activeText: '正常',
  inactiveText: '停用',
  showText: false,
})

const emit = defineEmits<Emits>()
const { toast } = useToast()

const loading = ref(false)

const isActive = () => props.modelValue === props.activeValue

async function handleChange(checked: boolean) {
  const newValue = checked ? props.activeValue : props.inactiveValue
  loading.value = true
  try {
    await emit('change', props.id, newValue)
    emit('update:modelValue', newValue)
    toast({ title: checked ? '已启用' : '已停用' })
  } catch (error: any) {
    toast({
      title: '操作失败',
      description: error?.message || '状态更新失败',
      variant: 'destructive',
    })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex items-center gap-2">
    <div v-if="loading" class="flex items-center gap-2">
      <Loader2 class="h-4 w-4 animate-spin text-muted-foreground" />
      <span class="text-xs text-muted-foreground">更新中...</span>
    </div>
    <template v-else>
      <Switch :checked="isActive()" @update:checked="handleChange" />
      <span
        v-if="showText"
        class="text-xs"
        :class="isActive() ? 'text-green-600' : 'text-muted-foreground'"
      >
        {{ isActive() ? activeText : inactiveText }}
      </span>
    </template>
  </div>
</template>
