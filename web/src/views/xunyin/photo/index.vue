<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Search,
  RefreshCw,
  Trash2,
  Eye,
  Image,
  Calendar,
  Users,
  Download,
  MapPin,
  TrendingUp,
  Sparkles,
} from 'lucide-vue-next'
import {
  listPhoto,
  getPhoto,
  deletePhoto,
  getPhotoStats,
  type Photo,
  type PhotoStats,
} from '@/api/xunyin/photo'
import { listCity } from '@/api/xunyin/city'
import { listJourney } from '@/api/xunyin/journey'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import { getResourceUrl } from '@/utils/url'

const loading = ref(true)
const photoList = ref<Photo[]>([])
const total = ref(0)
const stats = ref<PhotoStats | null>(null)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  nickname: '',
  cityId: undefined as string | undefined,
  journeyId: undefined as string | undefined,
  filter: undefined as string | undefined,
  startDate: '',
  endDate: '',
})

// 城市和文化之旅选项
const cityOptions = ref<{ id: string; name: string }[]>([])
const journeyOptions = ref<{ id: string; name: string }[]>([])

// 滤镜选项
const filterOptions = [
  { value: 'original', label: '原图', color: 'secondary' },
  { value: 'vintage', label: '复古', color: 'orange' },
  { value: 'ink', label: '水墨', color: 'slate' },
  { value: 'warm', label: '暖色', color: 'amber' },
  { value: 'cool', label: '冷色', color: 'blue' },
  { value: 'zen', label: '禅意', color: 'green' },
  { value: 'retro', label: '怀旧', color: 'yellow' },
  { value: 'classic', label: '经典', color: 'purple' },
  { value: 'mono', label: '黑白', color: 'gray' },
  { value: 'film', label: '胶片', color: 'rose' },
]

// 详情弹窗
const showDetailDialog = ref(false)
const currentPhoto = ref<Photo | null>(null)

// 删除确认
const showDeleteDialog = ref(false)
const deleteId = ref('')

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const res = await listPhoto(queryParams)
    photoList.value = res.list
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    stats.value = await getPhotoStats()
  } catch {
    /* ignore */
  }
}

async function loadOptions() {
  try {
    const [cities, journeys] = await Promise.all([
      listCity({ pageNum: 1, pageSize: 100 }),
      listJourney({ pageNum: 1, pageSize: 100 }),
    ])
    cityOptions.value = cities.list.map((c: any) => ({ id: c.id, name: c.name }))
    journeyOptions.value = journeys.list.map((j: any) => ({ id: j.id, name: j.name }))
  } catch {
    /* ignore */
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.nickname = ''
  queryParams.cityId = undefined
  queryParams.journeyId = undefined
  queryParams.filter = undefined
  queryParams.startDate = ''
  queryParams.endDate = ''
  handleQuery()
}

async function handleView(row: Photo) {
  try {
    currentPhoto.value = await getPhoto(row.id)
    showDetailDialog.value = true
  } catch (e: any) {
    toast({ title: '获取详情失败', description: e.message, variant: 'destructive' })
  }
}

function handleDelete(row: Photo) {
  deleteId.value = row.id
  showDeleteDialog.value = true
}

async function confirmDelete() {
  try {
    await deletePhoto(deleteId.value)
    toast({ title: '删除成功' })
    getList()
    loadStats()
  } catch (e: any) {
    toast({ title: '删除失败', description: e.message, variant: 'destructive' })
  }
}

function formatDate(dateStr: string): string {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('zh-CN')
}

function getFilterInfo(filter: string | null) {
  if (!filter) return { label: '原图', color: 'secondary' }
  return filterOptions.find((f) => f.value === filter) || { label: filter, color: 'secondary' }
}

function handleDownload(photo: Photo) {
  const url = getResourceUrl(photo.photoUrl)
  const link = document.createElement('a')
  link.href = url
  link.download = `photo_${photo.id}.jpg`
  link.target = '_blank'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

function openMap(lat: number, lng: number) {
  // 打开高德地图
  window.open(`https://uri.amap.com/marker?position=${lng},${lat}&name=拍摄位置`, '_blank')
}

onMounted(() => {
  getList()
  loadStats()
  loadOptions()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">用户相册管理</h2>
        <p class="text-sm text-muted-foreground">查看和管理用户上传的探索照片</p>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="grid gap-4 md:grid-cols-4" v-if="stats">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">照片总数</CardTitle>
          <Image class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ stats.totalPhotos }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">今日新增</CardTitle>
          <Calendar class="h-4 w-4 text-blue-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-blue-600">{{ stats.todayPhotos }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">本周新增</CardTitle>
          <TrendingUp class="h-4 w-4 text-purple-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-purple-600">{{ stats.weekPhotos || 0 }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">活跃用户</CardTitle>
          <Users class="h-4 w-4 text-green-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-green-600">{{ stats.activeUsers }}</div>
        </CardContent>
      </Card>
    </div>

    <!-- 筛选 -->
    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">用户昵称</span>
        <Input
          v-model="queryParams.nickname"
          placeholder="请输入"
          class="w-[120px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">城市</span>
        <Select v-model="queryParams.cityId" @update:model-value="handleQuery">
          <SelectTrigger class="w-[100px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="c in cityOptions" :key="c.id" :value="c.id">{{ c.name }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">文化之旅</span>
        <Select v-model="queryParams.journeyId" @update:model-value="handleQuery">
          <SelectTrigger class="w-[130px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="j in journeyOptions" :key="j.id" :value="j.id">{{
              j.name
            }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">滤镜</span>
        <Select v-model="queryParams.filter" @update:model-value="handleQuery">
          <SelectTrigger class="w-[100px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="f in filterOptions" :key="f.value" :value="f.value">{{
              f.label
            }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">开始日期</span>
        <Input v-model="queryParams.startDate" type="date" class="w-[140px]" />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">结束日期</span>
        <Input v-model="queryParams.endDate" type="date" class="w-[140px]" />
      </div>
      <div class="flex gap-2 ml-auto">
        <Button @click="handleQuery"><Search class="w-4 h-4 mr-2" />搜索</Button>
        <Button variant="outline" @click="resetQuery"
          ><RefreshCw class="w-4 h-4 mr-2" />重置</Button
        >
      </div>
    </div>

    <!-- 表格 -->
    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="8" :rows="10" />
      <EmptyState v-else-if="photoList.length === 0" title="暂无照片" />
      <Table v-else class="min-w-[1000px]">
        <TableHeader>
          <TableRow>
            <TableHead>照片</TableHead>
            <TableHead>用户</TableHead>
            <TableHead>城市</TableHead>
            <TableHead>文化之旅</TableHead>
            <TableHead>探索点</TableHead>
            <TableHead>滤镜</TableHead>
            <TableHead>拍摄时间</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="item in photoList" :key="item.id">
            <TableCell>
              <img
                :src="getResourceUrl(item.thumbnailUrl || item.photoUrl)"
                :alt="item.point.name"
                class="w-16 h-16 object-cover rounded cursor-pointer hover:opacity-80 transition-opacity"
                @click="handleView(item)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-2">
                <Avatar class="h-8 w-8">
                  <AvatarImage :src="item.user.avatar ? getResourceUrl(item.user.avatar) : ''" />
                  <AvatarFallback>{{ item.user.nickname?.charAt(0) }}</AvatarFallback>
                </Avatar>
                <span>{{ item.user.nickname }}</span>
              </div>
            </TableCell>
            <TableCell>{{ item.journey.city.name }}</TableCell>
            <TableCell>{{ item.journey.name }}</TableCell>
            <TableCell>{{ item.point.name }}</TableCell>
            <TableCell>
              <Badge
                :variant="
                  getFilterInfo(item.filter).color === 'secondary' ? 'secondary' : 'outline'
                "
                :class="{
                  'border-orange-500 text-orange-600':
                    getFilterInfo(item.filter).color === 'orange',
                  'border-slate-500 text-slate-600': getFilterInfo(item.filter).color === 'slate',
                  'border-amber-500 text-amber-600': getFilterInfo(item.filter).color === 'amber',
                  'border-blue-500 text-blue-600': getFilterInfo(item.filter).color === 'blue',
                  'border-green-500 text-green-600': getFilterInfo(item.filter).color === 'green',
                  'border-yellow-500 text-yellow-600':
                    getFilterInfo(item.filter).color === 'yellow',
                  'border-purple-500 text-purple-600':
                    getFilterInfo(item.filter).color === 'purple',
                  'border-gray-500 text-gray-600': getFilterInfo(item.filter).color === 'gray',
                  'border-rose-500 text-rose-600': getFilterInfo(item.filter).color === 'rose',
                }"
              >
                <Sparkles class="w-3 h-3 mr-1" v-if="item.filter && item.filter !== 'original'" />
                {{ getFilterInfo(item.filter).label }}
              </Badge>
            </TableCell>
            <TableCell>{{ formatDate(item.takenTime) }}</TableCell>
            <TableCell class="text-right">
              <div class="flex items-center justify-end gap-1">
                <Button
                  v-if="item.latitude && item.longitude"
                  variant="ghost"
                  size="icon"
                  @click="openMap(item.latitude, item.longitude)"
                  title="查看位置"
                >
                  <MapPin class="w-4 h-4 text-blue-500" />
                </Button>
                <Button variant="ghost" size="icon" @click="handleView(item)" title="查看">
                  <Eye class="w-4 h-4" />
                </Button>
                <Button variant="ghost" size="icon" @click="handleDownload(item)" title="下载">
                  <Download class="w-4 h-4 text-green-500" />
                </Button>
                <Button variant="ghost" size="icon" @click="handleDelete(item)" title="删除">
                  <Trash2 class="w-4 h-4 text-destructive" />
                </Button>
              </div>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>

    <TablePagination
      v-model:page-num="queryParams.pageNum"
      v-model:page-size="queryParams.pageSize"
      :total="total"
      @change="getList"
    />

    <!-- 详情弹窗 -->
    <Dialog v-model:open="showDetailDialog">
      <DialogContent class="sm:max-w-[700px]">
        <DialogHeader>
          <DialogTitle>照片详情</DialogTitle>
        </DialogHeader>
        <div v-if="currentPhoto" class="space-y-4">
          <div class="relative">
            <img
              :src="getResourceUrl(currentPhoto.photoUrl)"
              :alt="currentPhoto.point.name"
              class="w-full max-h-[400px] object-contain rounded bg-muted"
            />
            <Badge
              class="absolute top-2 right-2"
              :variant="
                getFilterInfo(currentPhoto.filter).color === 'secondary' ? 'secondary' : 'outline'
              "
            >
              <Sparkles
                class="w-3 h-3 mr-1"
                v-if="currentPhoto.filter && currentPhoto.filter !== 'original'"
              />
              {{ getFilterInfo(currentPhoto.filter).label }}
            </Badge>
          </div>
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div class="flex items-center gap-2">
              <span class="text-muted-foreground">用户：</span>
              <div class="flex items-center gap-2">
                <Avatar class="h-6 w-6">
                  <AvatarImage
                    :src="currentPhoto.user.avatar ? getResourceUrl(currentPhoto.user.avatar) : ''"
                  />
                  <AvatarFallback>{{ currentPhoto.user.nickname?.charAt(0) }}</AvatarFallback>
                </Avatar>
                <span>{{ currentPhoto.user.nickname }}</span>
              </div>
            </div>
            <div>
              <span class="text-muted-foreground">手机号：</span>
              <span>{{ currentPhoto.user.phone || '-' }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">城市：</span>
              <span>{{ currentPhoto.journey.city.name }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">文化之旅：</span>
              <span>{{ currentPhoto.journey.name }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">探索点：</span>
              <span>{{ currentPhoto.point.name }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">拍摄时间：</span>
              <span>{{ formatDate(currentPhoto.takenTime) }}</span>
            </div>
            <div
              v-if="currentPhoto.latitude && currentPhoto.longitude"
              class="col-span-2 flex items-center gap-2"
            >
              <span class="text-muted-foreground">拍摄位置：</span>
              <span
                >{{ currentPhoto.latitude.toFixed(6) }},
                {{ currentPhoto.longitude.toFixed(6) }}</span
              >
              <Button
                variant="link"
                size="sm"
                class="h-auto p-0 text-blue-500"
                @click="openMap(currentPhoto.latitude!, currentPhoto.longitude!)"
              >
                <MapPin class="w-3 h-3 mr-1" />查看地图
              </Button>
            </div>
          </div>
          <div class="flex justify-end gap-2 pt-2 border-t">
            <Button variant="outline" @click="handleDownload(currentPhoto)">
              <Download class="w-4 h-4 mr-2" />下载原图
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- 删除确认 -->
    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      description="确定要删除这张照片吗？此操作不可恢复。"
      @confirm="confirmDelete"
    />
  </div>
</template>
