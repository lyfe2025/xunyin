<script setup lang="ts">
import { ref, computed } from 'vue'
import { Input } from '@/components/ui/input'
import { Eye, EyeOff } from 'lucide-vue-next'

interface Props {
  modelValue: string
  placeholder?: string
  showStrength?: boolean
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: '请输入密码',
  showStrength: false,
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const showPassword = ref(false)

// 密码强度计算
const passwordStrength = computed(() => {
  const pwd = props.modelValue
  if (!pwd) return { level: 0, text: '', color: '' }

  let strength = 0
  if (pwd.length >= 8) strength++
  if (/[a-z]/.test(pwd)) strength++
  if (/[A-Z]/.test(pwd)) strength++
  if (/[0-9]/.test(pwd)) strength++
  if (/[^a-zA-Z0-9]/.test(pwd)) strength++

  if (strength <= 2) return { level: 1, text: '弱', color: 'text-red-500' }
  if (strength <= 3) return { level: 2, text: '中', color: 'text-yellow-500' }
  return { level: 3, text: '强', color: 'text-green-500' }
})

function handleUpdate(value: string | number) {
  emit('update:modelValue', String(value))
}
</script>

<template>
  <div class="space-y-2">
    <div class="relative">
      <Input
        :model-value="modelValue"
        :type="showPassword ? 'text' : 'password'"
        :placeholder="placeholder"
        :disabled="disabled"
        class="pr-10"
        @update:model-value="handleUpdate"
      />
      <button
        type="button"
        class="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
        @click="showPassword = !showPassword"
      >
        <EyeOff v-if="showPassword" class="h-4 w-4" />
        <Eye v-else class="h-4 w-4" />
      </button>
    </div>
    <!-- 密码强度 -->
    <div v-if="showStrength && modelValue" class="flex items-center gap-2 text-xs">
      <span>密码强度:</span>
      <span :class="passwordStrength.color">{{ passwordStrength.text }}</span>
      <div class="flex-1 h-1 bg-gray-200 rounded-full overflow-hidden">
        <div
          class="h-full transition-all"
          :class="{
            'bg-red-500': passwordStrength.level === 1,
            'bg-yellow-500': passwordStrength.level === 2,
            'bg-green-500': passwordStrength.level === 3,
          }"
          :style="{ width: `${(passwordStrength.level / 3) * 100}%` }"
        />
      </div>
    </div>
  </div>
</template>
