<script setup lang="ts">
import { ref } from 'vue'
import PhoneFrame from './PhoneFrame.vue'
import type { DeviceType } from './types'

withDefaults(
  defineProps<{
    showDeviceSwitch?: boolean
    scale?: number
    hint?: string
  }>(),
  {
    showDeviceSwitch: true,
    scale: 0.65,
    hint: '',
  }
)

const currentDevice = ref<DeviceType>('iphone')
</script>

<template>
  <div class="phone-preview">
    <!-- 设备切换 -->
    <div v-if="showDeviceSwitch" class="device-switch">
      <span class="label">预览效果</span>
      <div class="switch-tabs">
        <button
          :class="['tab', { active: currentDevice === 'iphone' }]"
          @click="currentDevice = 'iphone'"
        >
          iPhone
        </button>
        <button
          :class="['tab', { active: currentDevice === 'android' }]"
          @click="currentDevice = 'android'"
        >
          Android
        </button>
        <div class="tab-indicator" :class="{ right: currentDevice === 'android' }" />
      </div>
    </div>

    <!-- 手机 -->
    <div class="phone-container">
      <PhoneFrame :device="currentDevice" :scale="scale">
        <slot :device="currentDevice" />
      </PhoneFrame>
    </div>

    <!-- 提示文字 -->
    <p class="hint">{{ hint || '点击画面按钮可切换' }}</p>
  </div>
</template>

<style scoped>
.phone-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  min-width: 300px;
}

.device-switch {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.device-switch .label {
  font-size: 14px;
  font-weight: 500;
  color: hsl(var(--foreground));
}

.switch-tabs {
  display: flex;
  position: relative;
  background: hsl(var(--muted));
  border-radius: 8px;
  padding: 3px;
}

.switch-tabs .tab {
  padding: 6px 16px;
  font-size: 13px;
  font-weight: 500;
  color: hsl(var(--muted-foreground));
  background: transparent;
  border: none;
  cursor: pointer;
  transition: color 0.2s;
  position: relative;
  z-index: 1;
  border-radius: 6px;
}

.switch-tabs .tab:hover {
  color: hsl(var(--foreground));
}

.switch-tabs .tab.active {
  color: hsl(var(--foreground));
}

.tab-indicator {
  position: absolute;
  top: 3px;
  left: 3px;
  width: calc(50% - 3px);
  height: calc(100% - 6px);
  background: hsl(var(--background));
  border-radius: 6px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease;
}

.tab-indicator.right {
  transform: translateX(100%);
}

.phone-container {
  display: flex;
  justify-content: center;
  align-items: center;
}

.hint {
  font-size: 12px;
  color: hsl(var(--muted-foreground));
  margin: 20px 0 0;
  text-align: center;
}
</style>
