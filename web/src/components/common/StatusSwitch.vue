<script setup lang="ts">
import { ref, computed } from 'vue'
import { Switch } from '@/components/ui/switch'
import { Loader2 } from 'lucide-vue-next'
import { useToast } from '@/components/ui/toast/use-toast'

interface Props {
  modelValue: string
  id: string
  /** 显示名称，用于提示信息，如"城市「杭州」已启用" */
  name?: string
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
  name: '',
  activeValue: '0',
  inactiveValue: '1',
  activeText: '启用',
  inactiveText: '停用',
  showText: false,
})

const emit = defineEmits<Emits>()
const { toast } = useToast()

const loading = ref(false)

const isActive = computed(() => props.modelValue === props.activeValue)

// 生成提示信息
function getToastMessage(checked: boolean): string {
  const action = checked ? props.activeText : props.inactiveText
  if (props.name) {
    return `「${props.name}」已${action}`
  }
  return `已${action}`
}

async function handleChange(checked: boolean) {
  const newValue = checked ? props.activeValue : props.inactiveValue
  loading.value = true
  try {
    await emit('change', props.id, newValue)
    emit('update:modelValue', newValue)
    toast({ title: getToastMessage(checked) })
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
      <Switch :checked="isActive" @update:checked="handleChange" />
      <span
        v-if="showText"
        class="text-xs"
        :class="isActive ? 'text-green-600' : 'text-muted-foreground'"
      >
        {{ isActive ? activeText : inactiveText }}
      </span>
    </template>
  </div>
</template>
