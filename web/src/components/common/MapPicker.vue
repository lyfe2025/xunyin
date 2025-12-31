<script setup lang="ts">
import { ref, onUnmounted, watch } from 'vue'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useToast } from '@/components/ui/toast/use-toast'
import { Loader2, MapPin, Search } from 'lucide-vue-next'
import { getMapProviders, type MapProvider } from '@/api/system/config'

const props = defineProps<{
  open: boolean
  latitude?: number
  longitude?: number
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  confirm: [data: { latitude: number; longitude: number; address?: string }]
}>()

const { toast } = useToast()
const loading = ref(true)
const mapContainer = ref<HTMLElement>()
const searchInput = ref('')
const selectedLat = ref(props.latitude || 39.9042)
const selectedLng = ref(props.longitude || 116.4074)
const selectedAddress = ref('')

// 地图服务相关
const providers = ref<MapProvider[]>([])
const currentProvider = ref<string>('')

let map: any = null
let marker: any = null
let geocoder: any = null
let AMap: any = null
let TMap: any = null

// 加载高德地图 SDK
async function loadAmapSDK(key: string): Promise<void> {
  return new Promise((resolve, reject) => {
    if ((window as any).AMap) {
      AMap = (window as any).AMap
      resolve()
      return
    }
    const script = document.createElement('script')
    script.src = `https://webapi.amap.com/maps?v=2.0&key=${key}&plugin=AMap.Geocoder,AMap.PlaceSearch`
    script.onload = () => {
      AMap = (window as any).AMap
      resolve()
    }
    script.onerror = () => reject(new Error('高德地图 SDK 加载失败'))
    document.head.appendChild(script)
  })
}

// 加载腾讯地图 SDK
async function loadTencentSDK(key: string): Promise<void> {
  return new Promise((resolve, reject) => {
    if ((window as any).TMap) {
      TMap = (window as any).TMap
      resolve()
      return
    }
    const script = document.createElement('script')
    script.src = `https://map.qq.com/api/gljs?v=1.exp&key=${key}&libraries=service`
    script.onload = () => {
      TMap = (window as any).TMap
      resolve()
    }
    script.onerror = () => reject(new Error('腾讯地图 SDK 加载失败'))
    document.head.appendChild(script)
  })
}

// 加载 Google 地图 SDK
async function loadGoogleSDK(key: string): Promise<void> {
  return new Promise((resolve, reject) => {
    if ((window as any).google?.maps) {
      resolve()
      return
    }
    const script = document.createElement('script')
    script.src = `https://maps.googleapis.com/maps/api/js?key=${key}&libraries=places`
    script.onload = () => resolve()
    script.onerror = () => reject(new Error('Google 地图 SDK 加载失败'))
    document.head.appendChild(script)
  })
}

// 销毁当前地图
function destroyMap() {
  if (map) {
    if (currentProvider.value === 'amap') {
      map.destroy()
    } else if (currentProvider.value === 'tencent') {
      map.destroy()
    }
    map = null
    marker = null
    geocoder = null
  }
}

// 初始化高德地图
async function initAmapMap(key: string) {
  await loadAmapSDK(key)
  if (!mapContainer.value) return

  map = new AMap.Map(mapContainer.value, {
    zoom: 13,
    center: [selectedLng.value, selectedLat.value],
  })

  marker = new AMap.Marker({
    position: [selectedLng.value, selectedLat.value],
    draggable: true,
  })
  map.add(marker)

  geocoder = new AMap.Geocoder()

  map.on('click', (e: any) => {
    const { lng, lat } = e.lnglat
    updateMarkerAmap(lng, lat)
  })

  marker.on('dragend', (e: any) => {
    const { lng, lat } = e.lnglat
    updateMarkerAmap(lng, lat)
  })

  getAddressAmap(selectedLng.value, selectedLat.value)
}

function updateMarkerAmap(lng: number, lat: number) {
  selectedLng.value = lng
  selectedLat.value = lat
  marker.setPosition([lng, lat])
  getAddressAmap(lng, lat)
}

function getAddressAmap(lng: number, lat: number) {
  if (!geocoder) return
  geocoder.getAddress([lng, lat], (status: string, result: any) => {
    if (status === 'complete' && result.regeocode) {
      selectedAddress.value = result.regeocode.formattedAddress
    }
  })
}

function searchAmap() {
  if (!searchInput.value.trim()) return
  const placeSearch = new AMap.PlaceSearch({ map, pageSize: 5 })
  placeSearch.search(searchInput.value, (status: string, result: any) => {
    if (status === 'complete' && result.poiList?.pois?.length > 0) {
      const poi = result.poiList.pois[0]
      const { lng, lat } = poi.location
      map.setCenter([lng, lat])
      updateMarkerAmap(lng, lat)
    } else {
      toast({ title: '未找到相关地点', variant: 'destructive' })
    }
  })
}

// 初始化腾讯地图
async function initTencentMap(key: string) {
  await loadTencentSDK(key)
  if (!mapContainer.value) return

  const center = new TMap.LatLng(selectedLat.value, selectedLng.value)
  map = new TMap.Map(mapContainer.value, {
    center,
    zoom: 13,
  })

  marker = new TMap.MultiMarker({
    map,
    styles: {
      default: new TMap.MarkerStyle({ width: 25, height: 35, anchor: { x: 12, y: 35 } }),
    },
    geometries: [{ id: 'marker', position: center }],
  })

  geocoder = new TMap.service.Geocoder()

  map.on('click', (e: any) => {
    const { lat, lng } = e.latLng
    updateMarkerTencent(lng, lat)
  })

  getAddressTencent(selectedLng.value, selectedLat.value)
}

function updateMarkerTencent(lng: number, lat: number) {
  selectedLng.value = lng
  selectedLat.value = lat
  marker.updateGeometries([{ id: 'marker', position: new TMap.LatLng(lat, lng) }])
  getAddressTencent(lng, lat)
}

function getAddressTencent(lng: number, lat: number) {
  if (!geocoder) return
  geocoder
    .getAddress({ location: new TMap.LatLng(lat, lng) })
    .then((result: any) => {
      selectedAddress.value = result.result?.address || ''
    })
    .catch(() => {})
}

function searchTencent() {
  if (!searchInput.value.trim()) return
  const search = new TMap.service.Search({ pageSize: 5 })
  search
    .searchRectangle({
      keyword: searchInput.value,
      bounds: map.getBounds(),
    })
    .then((result: any) => {
      if (result.data?.length > 0) {
        const poi = result.data[0]
        const { lat, lng } = poi.location
        map.setCenter(new TMap.LatLng(lat, lng))
        updateMarkerTencent(lng, lat)
      } else {
        toast({ title: '未找到相关地点', variant: 'destructive' })
      }
    })
    .catch(() => {
      toast({ title: '搜索失败', variant: 'destructive' })
    })
}

// 初始化 Google 地图
async function initGoogleMap(key: string) {
  await loadGoogleSDK(key)
  if (!mapContainer.value) return

  const google = (window as any).google
  const center = { lat: selectedLat.value, lng: selectedLng.value }

  map = new google.maps.Map(mapContainer.value, {
    center,
    zoom: 13,
  })

  marker = new google.maps.Marker({
    position: center,
    map,
    draggable: true,
  })

  geocoder = new google.maps.Geocoder()

  map.addListener('click', (e: any) => {
    const lat = e.latLng.lat()
    const lng = e.latLng.lng()
    updateMarkerGoogle(lng, lat)
  })

  marker.addListener('dragend', (e: any) => {
    const lat = e.latLng.lat()
    const lng = e.latLng.lng()
    updateMarkerGoogle(lng, lat)
  })

  getAddressGoogle(selectedLng.value, selectedLat.value)
}

function updateMarkerGoogle(lng: number, lat: number) {
  selectedLng.value = lng
  selectedLat.value = lat
  marker.setPosition({ lat, lng })
  getAddressGoogle(lng, lat)
}

function getAddressGoogle(lng: number, lat: number) {
  if (!geocoder) return
  geocoder.geocode({ location: { lat, lng } }, (results: any, status: string) => {
    if (status === 'OK' && results[0]) {
      selectedAddress.value = results[0].formatted_address
    }
  })
}

function searchGoogle() {
  if (!searchInput.value.trim()) return
  const google = (window as any).google
  const service = new google.maps.places.PlacesService(map)
  service.findPlaceFromQuery(
    { query: searchInput.value, fields: ['geometry'] },
    (results: any, status: string) => {
      if (status === 'OK' && results?.length > 0) {
        const location = results[0].geometry.location
        const lat = location.lat()
        const lng = location.lng()
        map.setCenter({ lat, lng })
        updateMarkerGoogle(lng, lat)
      } else {
        toast({ title: '未找到相关地点', variant: 'destructive' })
      }
    }
  )
}

// 初始化地图
async function initMap() {
  loading.value = true
  try {
    // 获取可用的地图服务
    providers.value = await getMapProviders()

    if (providers.value.length === 0) {
      toast({ title: '请先在系统设置中配置地图服务', variant: 'destructive' })
      emit('update:open', false)
      return
    }

    // 如果只有一个或还没选择，自动选第一个
    if (!currentProvider.value || !providers.value.find((p) => p.name === currentProvider.value)) {
      currentProvider.value = providers.value[0]?.name || ''
    }

    await switchProvider(currentProvider.value)
  } catch (error: any) {
    toast({ title: error.message || '地图加载失败', variant: 'destructive' })
  } finally {
    loading.value = false
  }
}

// 切换地图服务
async function switchProvider(name: string) {
  const provider = providers.value.find((p) => p.name === name)
  if (!provider) return

  loading.value = true
  destroyMap()

  try {
    if (name === 'amap') {
      await initAmapMap(provider.key)
    } else if (name === 'tencent') {
      await initTencentMap(provider.key)
    } else if (name === 'google') {
      await initGoogleMap(provider.key)
    }
  } catch (error: any) {
    toast({ title: error.message || '地图加载失败', variant: 'destructive' })
  } finally {
    loading.value = false
  }
}

// 搜索
function handleSearch() {
  if (currentProvider.value === 'amap') {
    searchAmap()
  } else if (currentProvider.value === 'tencent') {
    searchTencent()
  } else if (currentProvider.value === 'google') {
    searchGoogle()
  }
}

// 确认选择
function handleConfirm() {
  emit('confirm', {
    latitude: selectedLat.value,
    longitude: selectedLng.value,
    address: selectedAddress.value,
  })
  emit('update:open', false)
}

// 监听弹窗打开
watch(
  () => props.open,
  (val) => {
    if (val) {
      selectedLat.value = props.latitude || 39.9042
      selectedLng.value = props.longitude || 116.4074
      selectedAddress.value = ''
      setTimeout(initMap, 100)
    }
  }
)

// 监听地图服务切换
watch(currentProvider, (val, oldVal) => {
  if (val && oldVal && val !== oldVal) {
    switchProvider(val)
  }
})

onUnmounted(() => {
  destroyMap()
})
</script>

<template>
  <Dialog :open="open" @update:open="emit('update:open', $event)">
    <DialogContent class="sm:max-w-[700px]">
      <DialogHeader>
        <DialogTitle>地图选点</DialogTitle>
        <DialogDescription>点击地图或拖动标记选择位置</DialogDescription>
      </DialogHeader>

      <div class="space-y-4">
        <!-- 地图服务选择 + 搜索框 -->
        <div class="flex gap-2">
          <Select v-if="providers.length > 1" v-model="currentProvider" class="w-[140px]">
            <SelectTrigger>
              <SelectValue placeholder="选择地图" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="p in providers" :key="p.name" :value="p.name">
                {{ p.label }}
              </SelectItem>
            </SelectContent>
          </Select>
          <Input
            v-model="searchInput"
            placeholder="搜索地点..."
            class="flex-1"
            @keyup.enter="handleSearch"
          />
          <Button variant="outline" @click="handleSearch">
            <Search class="w-4 h-4" />
          </Button>
        </div>

        <!-- 地图容器 -->
        <div class="relative">
          <div ref="mapContainer" class="w-full h-[400px] rounded-lg border bg-muted" />
          <div
            v-if="loading"
            class="absolute inset-0 flex items-center justify-center bg-background/80"
          >
            <Loader2 class="w-8 h-8 animate-spin text-primary" />
          </div>
        </div>

        <!-- 选中信息 -->
        <div class="grid grid-cols-2 gap-4">
          <div class="grid gap-2">
            <Label>经度</Label>
            <Input :model-value="selectedLng.toFixed(6)" readonly />
          </div>
          <div class="grid gap-2">
            <Label>纬度</Label>
            <Input :model-value="selectedLat.toFixed(6)" readonly />
          </div>
        </div>
        <div v-if="selectedAddress" class="flex items-start gap-2 text-sm text-muted-foreground">
          <MapPin class="w-4 h-4 mt-0.5 shrink-0" />
          <span>{{ selectedAddress }}</span>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="emit('update:open', false)">取消</Button>
        <Button @click="handleConfirm">确定</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
