<script setup lang="ts">
import { computed } from 'vue'

interface DataPoint {
  label: string
  value: number
}

interface Props {
  data: DataPoint[]
  type?: 'bar' | 'line'
  color?: string
  height?: number
  showLabels?: boolean
  showValues?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  type: 'bar',
  color: '#3b82f6',
  height: 200,
  showLabels: true,
  showValues: true,
})

const maxValue = computed(() => Math.max(...props.data.map((d) => d.value), 1))

const barWidth = computed(() => {
  const count = props.data.length
  if (count <= 7) return 32
  if (count <= 14) return 20
  return 12
})

const points = computed(() => {
  if (props.type !== 'line' || props.data.length === 0) return ''
  const width = 100 / (props.data.length - 1 || 1)
  return props.data
    .map((d, i) => {
      const x = i * width
      const y = 100 - (d.value / maxValue.value) * 100
      return `${x},${y}`
    })
    .join(' ')
})
</script>

<template>
  <div class="w-full">
    <!-- Bar Chart -->
    <div
      v-if="type === 'bar'"
      class="flex items-end justify-between gap-1"
      :style="{ height: `${height}px` }"
    >
      <div
        v-for="(item, index) in data"
        :key="index"
        class="flex flex-col items-center gap-1"
        :style="{ width: `${barWidth}px` }"
      >
        <span v-if="showValues" class="text-xs text-muted-foreground">{{ item.value }}</span>
        <div
          class="w-full rounded-t transition-all duration-300 hover:opacity-80"
          :style="{
            height: `${(item.value / maxValue) * (height - 40)}px`,
            backgroundColor: color,
            minHeight: item.value > 0 ? '4px' : '0',
          }"
        />
        <span v-if="showLabels" class="text-xs text-muted-foreground truncate w-full text-center">
          {{ item.label }}
        </span>
      </div>
    </div>

    <!-- Line Chart -->
    <div v-else class="relative" :style="{ height: `${height}px` }">
      <svg class="w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
        <!-- Grid lines -->
        <line
          v-for="i in 5"
          :key="i"
          x1="0"
          :y1="i * 20"
          x2="100"
          :y2="i * 20"
          stroke="currentColor"
          stroke-opacity="0.1"
          stroke-width="0.5"
        />
        <!-- Line -->
        <polyline
          :points="points"
          fill="none"
          :stroke="color"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          vector-effect="non-scaling-stroke"
        />
        <!-- Area fill -->
        <polygon
          v-if="data.length > 0"
          :points="`0,100 ${points} 100,100`"
          :fill="color"
          fill-opacity="0.1"
        />
        <!-- Points -->
        <circle
          v-for="(item, index) in data"
          :key="index"
          :cx="(index / (data.length - 1 || 1)) * 100"
          :cy="100 - (item.value / maxValue) * 100"
          r="3"
          :fill="color"
          vector-effect="non-scaling-stroke"
        />
      </svg>
      <!-- Labels -->
      <div v-if="showLabels" class="flex justify-between mt-2">
        <span
          v-for="(item, index) in data"
          :key="index"
          class="text-xs text-muted-foreground"
          :class="{ 'opacity-0': index > 0 && index < data.length - 1 && data.length > 7 }"
        >
          {{ item.label }}
        </span>
      </div>
    </div>
  </div>
</template>
