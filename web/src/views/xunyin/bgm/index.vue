<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, computed, watch } from 'vue'
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { Checkbox } from '@/components/ui/checkbox'
import { Slider } from '@/components/ui/slider'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Search,
  RefreshCw,
  Plus,
  Pencil,
  Trash2,
  Music,
  Home,
  Building,
  Route,
  Loader,
  Play,
  Pause,
  Square,
  ChevronRight,
  Upload,
} from 'lucide-vue-next'
import {
  listBgm,
  createBgm,
  updateBgm,
  deleteBgm,
  getBgmStats,
  updateBgmStatus,
  batchDeleteBgm,
  batchUpdateBgmStatus,
  type Bgm,
  type BgmStats,
  type CreateBgmDto,
} from '@/api/xunyin/bgm'
import { listCity } from '@/api/xunyin/city'
import { listJourney } from '@/api/xunyin/journey'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'

const loading = ref(true)
const bgmList = ref<Bgm[]>([])
const total = ref(0)
const stats = ref<BgmStats | null>(null)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  name: '',
  context: undefined as string | undefined,
  status: undefined as string | undefined,
})

const contextOptions = [
  { value: 'home', label: '首页', icon: Home },
  { value: 'city', label: '城市', icon: Building },
  { value: 'journey', label: '文化之旅', icon: Route },
]

function getContextLabel(context: string) {
  return contextOptions.find((c) => c.value === context)?.label || context
}

const cityOptions = ref<{ id: string; name: string }[]>([])
const journeyOptions = ref<{ id: string; name: string; cityName?: string }[]>([])

const showFormDialog = ref(false)
const formLoading = ref(false)
const isEdit = ref(false)
const currentId = ref('')
const form = reactive<CreateBgmDto>({
  name: '',
  url: '',
  context: 'home',
  contextId: undefined,
  duration: undefined,
  orderNum: 0,
  status: '0',
})

const showDeleteDialog = ref(false)
const deleteId = ref('')
const selectedIds = ref<string[]>([])
const showBatchDeleteDialog = ref(false)

const currentPlayingId = ref<string | null>(null)
// eslint-disable-next-line no-undef
const audioRef = ref<HTMLAudioElement | null>(null)
const audioProgress = ref(0)
const audioDuration = ref(0)
const isPlaying = ref(false)

// 文件上传
// eslint-disable-next-line no-undef
const fileInputRef = ref<HTMLInputElement | null>(null)
const uploadLoading = ref(false)

const { toast } = useToast()

const selectAll = ref(false)

const isIndeterminate = computed(
  () => selectedIds.value.length > 0 && selectedIds.value.length < bgmList.value.length
)

// 监听全选状态变化
watch(selectAll, (newVal) => {
  if (newVal) {
    selectedIds.value = bgmList.value.map((item) => item.id)
  } else if (selectedIds.value.length === bgmList.value.length) {
    // 只有当前是全选状态时才清空
    selectedIds.value = []
  }
})

// 监听选中项变化，更新全选状态
watch(
  selectedIds,
  (newVal) => {
    selectAll.value = bgmList.value.length > 0 && newVal.length === bgmList.value.length
  },
  { deep: true }
)

function toggleSelect(id: string) {
  const index = selectedIds.value.indexOf(id)
  if (index > -1) {
    selectedIds.value.splice(index, 1)
  } else {
    selectedIds.value.push(id)
  }
}

async function getList() {
  loading.value = true
  selectedIds.value = []
  selectAll.value = false
  try {
    const res = await listBgm(queryParams)
    bgmList.value = res.list
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    stats.value = await getBgmStats()
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
    journeyOptions.value = journeys.list.map((j: any) => ({
      id: j.id,
      name: j.name,
      cityName: j.cityName,
    }))
  } catch {
    /* ignore */
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}
function resetQuery() {
  queryParams.name = ''
  queryParams.context = undefined
  queryParams.status = undefined
  handleQuery()
}

function resetForm() {
  form.name = ''
  form.url = ''
  form.context = 'home'
  form.contextId = undefined
  form.duration = undefined
  form.orderNum = 0
  form.status = '0'
}

function handleAdd() {
  isEdit.value = false
  currentId.value = ''
  resetForm()
  showFormDialog.value = true
}

function handleEdit(row: Bgm) {
  isEdit.value = true
  currentId.value = row.id
  // 先设置 context，再设置 contextId（避免 watch 清空）
  form.context = row.context
  // 使用 nextTick 确保 context 变化的 watch 已执行完
  setTimeout(() => {
    form.contextId = row.contextId || undefined
  }, 0)
  form.name = row.name
  form.url = row.url
  form.duration = row.duration || undefined
  form.orderNum = row.orderNum
  form.status = row.status
  showFormDialog.value = true
}

async function handleSubmit() {
  if (!form.name || !form.url || !form.context) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }
  // 城市和文化之旅类型必须选择关联
  if ((form.context === 'city' || form.context === 'journey') && !form.contextId) {
    toast({ title: '请选择关联项', variant: 'destructive' })
    return
  }
  formLoading.value = true
  try {
    // 首页类型清空 contextId
    const submitData = {
      ...form,
      contextId: form.context === 'home' ? undefined : form.contextId,
    }
    if (isEdit.value) {
      await updateBgm(currentId.value, submitData)
      toast({ title: '修改成功' })
    } else {
      await createBgm(submitData)
      toast({ title: '新增成功' })
    }
    showFormDialog.value = false
    getList()
    loadStats()
  } catch (e: any) {
    toast({
      title: isEdit.value ? '修改失败' : '新增失败',
      description: e.message,
      variant: 'destructive',
    })
  } finally {
    formLoading.value = false
  }
}

function handleDelete(row: Bgm) {
  deleteId.value = row.id
  showDeleteDialog.value = true
}

async function confirmDelete() {
  try {
    await deleteBgm(deleteId.value)
    toast({ title: '删除成功' })
    getList()
    loadStats()
  } catch (e: any) {
    toast({ title: '删除失败', description: e.message, variant: 'destructive' })
  }
}

async function handleStatusChange(row: Bgm, checked: boolean) {
  const newStatus = checked ? '0' : '1'
  try {
    await updateBgmStatus(row.id, newStatus)
    row.status = newStatus
    toast({ title: checked ? '已启用' : '已停用' })
  } catch (e: any) {
    toast({ title: '操作失败', description: e.message, variant: 'destructive' })
  }
}

function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要删除的记录', variant: 'destructive' })
    return
  }
  showBatchDeleteDialog.value = true
}

async function confirmBatchDelete() {
  try {
    await batchDeleteBgm(selectedIds.value)
    toast({ title: `成功删除 ${selectedIds.value.length} 条记录` })
    selectedIds.value = []
    getList()
    loadStats()
  } catch (e: any) {
    toast({ title: '批量删除失败', description: e.message, variant: 'destructive' })
  }
}

async function handleBatchStatus(status: string) {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要操作的记录', variant: 'destructive' })
    return
  }
  try {
    await batchUpdateBgmStatus(selectedIds.value, status)
    toast({ title: status === '0' ? '批量启用成功' : '批量停用成功' })
    getList()
  } catch (e: any) {
    toast({ title: '操作失败', description: e.message, variant: 'destructive' })
  }
}

function playAudio(item: Bgm) {
  if (currentPlayingId.value === item.id && isPlaying.value) {
    audioRef.value?.pause()
    isPlaying.value = false
  } else {
    if (currentPlayingId.value !== item.id) {
      currentPlayingId.value = item.id
      audioProgress.value = 0
      if (audioRef.value) {
        audioRef.value.src = item.url
        audioRef.value.load()
      }
    }
    audioRef.value?.play()
    isPlaying.value = true
  }
}

function stopAudio() {
  if (audioRef.value) {
    audioRef.value.pause()
    audioRef.value.currentTime = 0
  }
  currentPlayingId.value = null
  isPlaying.value = false
  audioProgress.value = 0
}

function onAudioTimeUpdate() {
  if (audioRef.value) {
    audioProgress.value = audioRef.value.currentTime
    audioDuration.value = audioRef.value.duration || 0
  }
}
function onAudioEnded() {
  isPlaying.value = false
  audioProgress.value = 0
}
function seekAudio(value: number[]) {
  if (audioRef.value && value[0] !== undefined) audioRef.value.currentTime = value[0]
}

function formatDuration(seconds: number | null): string {
  if (!seconds) return '-'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

function getContextDisplay(item: Bgm): string {
  if (item.context === 'home') return '-'
  if (item.context === 'city') return item.contextName || '-'
  if (item.context === 'journey') {
    if (item.contextCityName && item.contextName)
      return `${item.contextCityName} > ${item.contextName}`
    return item.contextName || '-'
  }
  return '-'
}

// 触发文件选择
function triggerFileInput() {
  fileInputRef.value?.click()
}

// 处理文件上传
async function handleFileChange(event: Event) {
  // eslint-disable-next-line no-undef
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  // 验证文件类型
  if (!file.type.startsWith('audio/')) {
    toast({ title: '请选择音频文件', variant: 'destructive' })
    return
  }

  uploadLoading.value = true
  try {
    // 获取音频时长
    const duration = await getAudioDuration(file)
    form.duration = Math.round(duration)

    // TODO: 实际项目中这里应该上传文件到服务器，获取返回的 URL
    // 这里暂时使用本地 URL 作为演示
    const localUrl = URL.createObjectURL(file)
    form.url = `/audio/bgm/${file.name}`

    toast({ title: '文件已选择', description: `时长: ${formatDuration(form.duration)}` })

    // 清理临时 URL
    URL.revokeObjectURL(localUrl)
  } catch (e: any) {
    toast({ title: '获取音频信息失败', description: e.message, variant: 'destructive' })
  } finally {
    uploadLoading.value = false
    // 清空 input，允许重复选择同一文件
    input.value = ''
  }
}

// 获取音频时长
function getAudioDuration(file: File): Promise<number> {
  return new Promise((resolve, reject) => {
    const audio = new window.Audio()
    audio.preload = 'metadata'

    audio.onloadedmetadata = () => {
      resolve(audio.duration)
      URL.revokeObjectURL(audio.src)
    }

    audio.onerror = () => {
      reject(new Error('无法读取音频文件'))
      URL.revokeObjectURL(audio.src)
    }

    audio.src = URL.createObjectURL(file)
  })
}

// 只在新增模式下，切换类型时清空关联
watch(
  () => form.context,
  (newVal, oldVal) => {
    if (!isEdit.value && oldVal !== undefined) {
      form.contextId = undefined
    }
  }
)

onMounted(() => {
  getList()
  loadStats()
  loadOptions()
  audioRef.value = new window.Audio()
  audioRef.value.addEventListener('timeupdate', onAudioTimeUpdate)
  audioRef.value.addEventListener('ended', onAudioEnded)
})

onUnmounted(() => {
  if (audioRef.value) {
    audioRef.value.pause()
    audioRef.value.removeEventListener('timeupdate', onAudioTimeUpdate)
    audioRef.value.removeEventListener('ended', onAudioEnded)
  }
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">背景音乐管理</h2>
        <p class="text-sm text-muted-foreground">管理 App 各场景的背景音乐</p>
      </div>
      <Button @click="handleAdd"><Plus class="w-4 h-4 mr-2" />新增</Button>
    </div>

    <!-- 统计卡片 -->
    <div class="grid gap-4 md:grid-cols-4" v-if="stats">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">总数</CardTitle>
          <Music class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent
          ><div class="text-2xl font-bold">{{ stats.total }}</div></CardContent
        >
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">首页音乐</CardTitle>
          <Home class="h-4 w-4 text-blue-500" />
        </CardHeader>
        <CardContent
          ><div class="text-2xl font-bold text-blue-600">{{ stats.home }}</div></CardContent
        >
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">城市音乐</CardTitle>
          <Building class="h-4 w-4 text-green-500" />
        </CardHeader>
        <CardContent
          ><div class="text-2xl font-bold text-green-600">{{ stats.city }}</div></CardContent
        >
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">文化之旅音乐</CardTitle>
          <Route class="h-4 w-4 text-orange-500" />
        </CardHeader>
        <CardContent
          ><div class="text-2xl font-bold text-orange-600">{{ stats.journey }}</div></CardContent
        >
      </Card>
    </div>

    <!-- 筛选 -->
    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">名称</span>
        <Input
          v-model="queryParams.name"
          placeholder="请输入"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">类型</span>
        <Select v-model="queryParams.context" @update:model-value="handleQuery">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="c in contextOptions" :key="c.value" :value="c.value">{{
              c.label
            }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">状态</span>
        <Select v-model="queryParams.status" @update:model-value="handleQuery">
          <SelectTrigger class="w-[100px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="0">正常</SelectItem>
            <SelectItem value="1">停用</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex gap-2 ml-auto">
        <Button @click="handleQuery"><Search class="w-4 h-4 mr-2" />搜索</Button>
        <Button variant="outline" @click="resetQuery"
          ><RefreshCw class="w-4 h-4 mr-2" />重置</Button
        >
      </div>
    </div>

    <!-- 批量操作栏 -->
    <div
      v-if="selectedIds.length > 0"
      class="flex items-center gap-3 p-3 bg-muted/50 border rounded-lg"
    >
      <span class="text-sm">已选择 {{ selectedIds.length }} 项</span>
      <Button size="sm" variant="outline" @click="handleBatchStatus('0')">批量启用</Button>
      <Button size="sm" variant="outline" @click="handleBatchStatus('1')">批量停用</Button>
      <Button size="sm" variant="destructive" @click="handleBatchDelete">批量删除</Button>
    </div>

    <!-- 当前播放控制 -->
    <div
      v-if="currentPlayingId"
      class="flex items-center gap-4 p-3 bg-primary/5 border border-primary/20 rounded-lg"
    >
      <Button size="icon" variant="ghost" @click="stopAudio"><Square class="w-4 h-4" /></Button>
      <div class="flex-1">
        <div class="text-sm font-medium mb-1">
          {{ bgmList.find((b) => b.id === currentPlayingId)?.name }}
        </div>
        <div class="flex items-center gap-2">
          <span class="text-xs text-muted-foreground w-10">{{ formatTime(audioProgress) }}</span>
          <Slider
            :model-value="[audioProgress]"
            :max="audioDuration || 100"
            :step="1"
            class="flex-1"
            @update:model-value="seekAudio"
          />
          <span class="text-xs text-muted-foreground w-10">{{ formatTime(audioDuration) }}</span>
        </div>
      </div>
    </div>

    <!-- 表格 -->
    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="9" :rows="10" />
      <EmptyState v-else-if="bgmList.length === 0" title="暂无背景音乐" />
      <Table v-else class="min-w-[900px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox v-model="selectAll" :indeterminate="isIndeterminate" />
            </TableHead>
            <TableHead>名称</TableHead>
            <TableHead>类型</TableHead>
            <TableHead>关联</TableHead>
            <TableHead>音频</TableHead>
            <TableHead>时长</TableHead>
            <TableHead>排序</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="item in bgmList" :key="item.id">
            <TableCell>
              <Checkbox
                :model-value="selectedIds.includes(item.id)"
                @update:model-value="() => toggleSelect(item.id)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-2">
                <Music class="w-4 h-4 text-muted-foreground" /><span>{{ item.name }}</span>
              </div>
            </TableCell>
            <TableCell
              ><Badge variant="outline">{{ getContextLabel(item.context) }}</Badge></TableCell
            >
            <TableCell>
              <div class="flex items-center gap-1 text-sm">
                <template v-if="item.context === 'journey' && item.contextCityName">
                  <span class="text-muted-foreground">{{ item.contextCityName }}</span>
                  <ChevronRight class="w-3 h-3 text-muted-foreground" />
                  <span>{{ item.contextName }}</span>
                </template>
                <template v-else>{{ getContextDisplay(item) }}</template>
              </div>
            </TableCell>
            <TableCell>
              <Button
                size="icon"
                variant="ghost"
                class="h-8 w-8"
                @click="playAudio(item)"
                :title="currentPlayingId === item.id && isPlaying ? '暂停' : '播放'"
              >
                <Pause
                  v-if="currentPlayingId === item.id && isPlaying"
                  class="w-4 h-4 text-primary"
                />
                <Play v-else class="w-4 h-4" />
              </Button>
            </TableCell>
            <TableCell>{{ formatDuration(item.duration) }}</TableCell>
            <TableCell>{{ item.orderNum }}</TableCell>
            <TableCell>
              <Switch
                :checked="item.status === '0'"
                @update:checked="(checked) => handleStatusChange(item, checked)"
              />
            </TableCell>
            <TableCell class="text-right">
              <div class="flex items-center justify-end gap-1">
                <Button variant="ghost" size="icon" @click="handleEdit(item)" title="编辑"
                  ><Pencil class="w-4 h-4"
                /></Button>
                <Button variant="ghost" size="icon" @click="handleDelete(item)" title="删除"
                  ><Trash2 class="w-4 h-4 text-destructive"
                /></Button>
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

    <!-- 表单弹窗 -->
    <Dialog v-model:open="showFormDialog">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{{ isEdit ? '编辑背景音乐' : '新增背景音乐' }}</DialogTitle>
          <DialogDescription>{{
            isEdit ? '修改背景音乐信息' : '添加新的背景音乐'
          }}</DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid gap-2">
            <Label>名称 <span class="text-destructive">*</span></Label>
            <Input v-model="form.name" placeholder="请输入音乐名称" />
          </div>
          <div class="grid gap-2">
            <Label>音频文件 <span class="text-destructive">*</span></Label>
            <div class="flex gap-2">
              <Input v-model="form.url" placeholder="请输入音频URL或上传文件" class="flex-1" />
              <Button
                type="button"
                variant="outline"
                @click="triggerFileInput"
                :disabled="uploadLoading"
              >
                <Loader v-if="uploadLoading" class="w-4 h-4 mr-2 animate-spin" />
                <Upload v-else class="w-4 h-4 mr-2" />
                上传
              </Button>
              <input
                ref="fileInputRef"
                type="file"
                accept="audio/*"
                class="hidden"
                @change="handleFileChange"
              />
            </div>
          </div>
          <div class="grid gap-2">
            <Label>类型 <span class="text-destructive">*</span></Label>
            <Select v-model="form.context">
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem v-for="c in contextOptions" :key="c.value" :value="c.value">{{
                  c.label
                }}</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div v-if="form.context === 'city'" class="grid gap-2">
            <Label>关联城市 <span class="text-destructive">*</span></Label>
            <Select v-model="form.contextId">
              <SelectTrigger><SelectValue placeholder="请选择城市" /></SelectTrigger>
              <SelectContent>
                <SelectItem v-for="c in cityOptions" :key="c.id" :value="c.id">{{
                  c.name
                }}</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div v-if="form.context === 'journey'" class="grid gap-2">
            <Label>关联文化之旅 <span class="text-destructive">*</span></Label>
            <Select v-model="form.contextId">
              <SelectTrigger><SelectValue placeholder="请选择文化之旅" /></SelectTrigger>
              <SelectContent>
                <SelectItem v-for="j in journeyOptions" :key="j.id" :value="j.id">
                  <span v-if="j.cityName" class="text-muted-foreground">{{ j.cityName }} > </span
                  >{{ j.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>时长</Label>
              <div class="flex items-center h-10 px-3 border rounded-md bg-muted/50 text-sm">
                {{ form.duration ? formatDuration(form.duration) : '上传后自动获取' }}
              </div>
            </div>
            <div class="grid gap-2">
              <Label>排序</Label>
              <Input v-model.number="form.orderNum" type="number" />
            </div>
          </div>
          <div class="grid gap-2">
            <Label>状态</Label>
            <Select v-model="form.status">
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="0">正常</SelectItem>
                <SelectItem value="1">停用</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showFormDialog = false">取消</Button>
          <Button @click="handleSubmit" :disabled="formLoading">
            <Loader v-if="formLoading" class="w-4 h-4 mr-2 animate-spin" />确定
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- 删除确认 -->
    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      description="确定要删除这条背景音乐吗？此操作不可恢复。"
      @confirm="confirmDelete"
    />
    <!-- 批量删除确认 -->
    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 条背景音乐吗？此操作不可恢复。`"
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
