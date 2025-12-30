<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Label } from '@/components/ui/label'
import pcData from 'china-division/dist/pc.json'

// 城市中心坐标数据（常用城市）
const cityCoordinates: Record<string, { lat: number; lng: number }> = {
  // 直辖市
  北京市: { lat: 39.9042, lng: 116.4074 },
  上海市: { lat: 31.2304, lng: 121.4737 },
  天津市: { lat: 39.0842, lng: 117.2009 },
  重庆市: { lat: 29.563, lng: 106.5516 },
  // 省会及主要城市
  杭州市: { lat: 30.2741, lng: 120.1551 },
  南京市: { lat: 32.0603, lng: 118.7969 },
  苏州市: { lat: 31.299, lng: 120.5853 },
  无锡市: { lat: 31.4912, lng: 120.3119 },
  宁波市: { lat: 29.8683, lng: 121.544 },
  温州市: { lat: 27.9939, lng: 120.6994 },
  广州市: { lat: 23.1291, lng: 113.2644 },
  深圳市: { lat: 22.5431, lng: 114.0579 },
  成都市: { lat: 30.5728, lng: 104.0668 },
  武汉市: { lat: 30.5928, lng: 114.3055 },
  西安市: { lat: 34.3416, lng: 108.9398 },
  长沙市: { lat: 28.2282, lng: 112.9388 },
  郑州市: { lat: 34.7466, lng: 113.6254 },
  济南市: { lat: 36.6512, lng: 117.1201 },
  青岛市: { lat: 36.0671, lng: 120.3826 },
  大连市: { lat: 38.914, lng: 121.6147 },
  沈阳市: { lat: 41.8057, lng: 123.4315 },
  哈尔滨市: { lat: 45.8038, lng: 126.535 },
  长春市: { lat: 43.8171, lng: 125.3235 },
  合肥市: { lat: 31.8206, lng: 117.2272 },
  福州市: { lat: 26.0745, lng: 119.2965 },
  厦门市: { lat: 24.4798, lng: 118.0894 },
  南昌市: { lat: 28.682, lng: 115.8579 },
  昆明市: { lat: 24.8801, lng: 102.8329 },
  贵阳市: { lat: 26.647, lng: 106.6302 },
  南宁市: { lat: 22.817, lng: 108.3665 },
  海口市: { lat: 20.044, lng: 110.1999 },
  三亚市: { lat: 18.2528, lng: 109.512 },
  拉萨市: { lat: 29.65, lng: 91.1 },
  乌鲁木齐市: { lat: 43.8256, lng: 87.6168 },
  兰州市: { lat: 36.0611, lng: 103.8343 },
  西宁市: { lat: 36.6171, lng: 101.7782 },
  银川市: { lat: 38.4872, lng: 106.2309 },
  呼和浩特市: { lat: 40.8414, lng: 111.7519 },
  太原市: { lat: 37.8706, lng: 112.5489 },
  石家庄市: { lat: 38.0428, lng: 114.5149 },
  // 更多城市可按需添加
}

const props = defineProps<{
  province?: string
  city?: string
  showLabel?: boolean
}>()

const emit = defineEmits<{
  'update:province': [value: string]
  'update:city': [value: string]
  change: [data: { province: string; city: string; latitude?: number; longitude?: number }]
}>()

const selectedProvince = ref(props.province || '')
const selectedCity = ref(props.city || '')

// 省份列表
const provinces = computed(() => Object.keys(pcData))

// 当前省份下的城市列表
const cities = computed(() => {
  if (!selectedProvince.value) return []
  return (pcData as Record<string, string[]>)[selectedProvince.value] || []
})

// 监听 props 变化
watch(
  () => props.province,
  (val) => {
    if (val !== selectedProvince.value) {
      selectedProvince.value = val || ''
    }
  }
)

watch(
  () => props.city,
  (val) => {
    if (val !== selectedCity.value) {
      selectedCity.value = val || ''
    }
  }
)

// 省份变化时清空城市
function handleProvinceChange(value: unknown) {
  const val = String(value || '')
  selectedProvince.value = val
  selectedCity.value = ''
  emit('update:province', val)
  emit('update:city', '')
  emit('change', { province: val, city: '' })
}

// 城市变化时触发事件并返回坐标
function handleCityChange(value: unknown) {
  const val = String(value || '')
  selectedCity.value = val
  emit('update:city', val)

  // 查找城市坐标
  const coords = cityCoordinates[val]
  emit('change', {
    province: selectedProvince.value,
    city: val,
    latitude: coords?.lat,
    longitude: coords?.lng,
  })
}
</script>

<template>
  <div class="grid grid-cols-2 gap-4">
    <div class="grid gap-2">
      <Label v-if="showLabel">省份 *</Label>
      <Select :model-value="selectedProvince" @update:model-value="handleProvinceChange">
        <SelectTrigger>
          <SelectValue placeholder="请选择省份" />
        </SelectTrigger>
        <SelectContent class="max-h-[300px]">
          <SelectItem v-for="p in provinces" :key="p" :value="p">{{ p }}</SelectItem>
        </SelectContent>
      </Select>
    </div>
    <div class="grid gap-2">
      <Label v-if="showLabel">城市 *</Label>
      <Select
        :model-value="selectedCity"
        :disabled="!selectedProvince"
        @update:model-value="handleCityChange"
      >
        <SelectTrigger>
          <SelectValue :placeholder="selectedProvince ? '请选择城市' : '请先选择省份'" />
        </SelectTrigger>
        <SelectContent class="max-h-[300px]">
          <SelectItem v-for="c in cities" :key="c" :value="c">{{ c }}</SelectItem>
        </SelectContent>
      </Select>
    </div>
  </div>
</template>
