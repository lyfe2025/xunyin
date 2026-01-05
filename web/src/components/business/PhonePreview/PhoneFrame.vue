<script setup lang="ts">
import { computed } from 'vue'
import type { DeviceType } from './types'

const props = withDefaults(
  defineProps<{
    device?: DeviceType
    scale?: number
    showStatusBar?: boolean
    statusBarColor?: string
  }>(),
  {
    device: 'iphone',
    scale: 0.65,
    showStatusBar: true,
    statusBarColor: 'white',
  }
)

// iPhone 尺寸
const baseWidth = 375
const baseHeight = 812

const frameStyle = computed(() => ({
  width: `${baseWidth * props.scale}px`,
  height: `${baseHeight * props.scale}px`,
}))

const statusBarStyle = computed(() => ({
  color: props.statusBarColor,
}))
</script>

<template>
  <div class="phone-wrapper" :class="device">
    <div class="phone-bezel">
      <!-- 侧边按钮 -->
      <div v-if="device === 'iphone'" class="side-buttons">
        <div class="btn power" />
        <div class="btn vol-up" />
        <div class="btn vol-down" />
        <div class="btn silent" />
      </div>

      <!-- 屏幕 -->
      <div class="phone-screen" :style="frameStyle">
        <!-- 状态栏区域 -->
        <div v-if="showStatusBar" class="status-bar-area" :style="statusBarStyle">
          <!-- 左侧时间 -->
          <span class="time">9:41</span>
          <!-- 中间灵动岛/挖孔 -->
          <div v-if="device === 'iphone'" class="dynamic-island" />
          <div v-else class="punch-hole" />
          <!-- 右侧图标 -->
          <div class="icons">
            <!-- 信号 -->
            <svg viewBox="0 0 18 12" fill="currentColor">
              <rect x="0" y="8" width="3" height="4" rx="0.5" />
              <rect x="5" y="5" width="3" height="7" rx="0.5" />
              <rect x="10" y="2" width="3" height="10" rx="0.5" />
              <rect x="15" y="0" width="3" height="12" rx="0.5" />
            </svg>
            <!-- WiFi -->
            <svg viewBox="0 0 16 12" fill="currentColor">
              <path
                d="M8 9.5a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM8 5c2.5 0 4.8 1 6.4 2.6l-1.4 1.4C11.5 7.8 9.8 7 8 7s-3.5.8-5 2l-1.4-1.4C3.2 6 5.5 5 8 5z"
              />
            </svg>
            <!-- 电池 -->
            <div class="battery">
              <div class="level" />
            </div>
          </div>
        </div>

        <!-- 内容区域 -->
        <div class="screen-content">
          <slot />
        </div>

        <!-- Home Indicator -->
        <div class="home-indicator" />
      </div>
    </div>
  </div>
</template>

<style scoped>
.phone-wrapper {
  position: relative;
  filter: drop-shadow(0 25px 50px rgba(0, 0, 0, 0.25));
}

/* 边框 */
.phone-bezel {
  position: relative;
  padding: 12px;
  background: linear-gradient(145deg, #3a3a3a 0%, #1a1a1a 50%, #2a2a2a 100%);
  border-radius: 54px;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.1),
    inset 0 1px 1px rgba(255, 255, 255, 0.1);
}

.phone-wrapper.android .phone-bezel {
  border-radius: 40px;
  padding: 10px;
}

/* 侧边按钮 */
.side-buttons .btn {
  position: absolute;
  background: linear-gradient(90deg, #222, #3a3a3a, #222);
  border-radius: 2px;
}

.side-buttons .power {
  right: -3px;
  top: 140px;
  width: 4px;
  height: 70px;
}

.side-buttons .vol-up {
  left: -3px;
  top: 115px;
  width: 4px;
  height: 40px;
}

.side-buttons .vol-down {
  left: -3px;
  top: 165px;
  width: 4px;
  height: 40px;
}

.side-buttons .silent {
  left: -3px;
  top: 75px;
  width: 4px;
  height: 24px;
}

/* 屏幕 */
.phone-screen {
  position: relative;
  background: #000;
  border-radius: 42px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.phone-wrapper.android .phone-screen {
  border-radius: 30px;
}

/* 状态栏区域 */
.status-bar-area {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px 0;
  font-size: 14px;
  font-weight: 600;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
  z-index: 100;
}

.status-bar-area .time {
  font-variant-numeric: tabular-nums;
  width: 54px;
}

.status-bar-area .dynamic-island {
  width: 84px;
  height: 24px;
  background: #000;
  border-radius: 12px;
  flex-shrink: 0;
}

.status-bar-area .punch-hole {
  width: 10px;
  height: 10px;
  background: #000;
  border-radius: 50%;
  flex-shrink: 0;
}

.status-bar-area .icons {
  display: flex;
  align-items: center;
  gap: 4px;
  width: 54px;
  justify-content: flex-end;
}

.status-bar-area .icons svg {
  width: 15px;
  height: 10px;
}

.status-bar-area .battery {
  width: 22px;
  height: 10px;
  border: 1.5px solid currentColor;
  border-radius: 3px;
  padding: 1.5px;
  opacity: 0.5;
}

.status-bar-area .battery .level {
  width: 100%;
  height: 100%;
  background: currentColor;
  border-radius: 1px;
  opacity: 1;
}

/* 内容 */
.screen-content {
  flex: 1;
  overflow: hidden;
}

/* Home Indicator */
.home-indicator {
  position: absolute;
  bottom: 8px;
  left: 50%;
  transform: translateX(-50%);
  width: 35%;
  height: 5px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
  z-index: 10;
  pointer-events: none;
}

.phone-wrapper.android .home-indicator {
  width: 28%;
  height: 4px;
  bottom: 6px;
}
</style>
