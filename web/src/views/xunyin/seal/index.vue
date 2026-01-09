<script setup lang="ts">
import { ref, reactive, onMounted, watch, computed } from 'vue'
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
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card, CardContent } from '@/components/ui/card'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Plus,
  Search,
  Trash2,
  Loader2,
  RefreshCw,
  Edit,
  Award,
  Copy,
  Users,
  Sparkles,
  MapPin,
  Route,
  X,
} from 'lucide-vue-next'
import ImageUpload from '@/components/common/ImageUpload.vue'
import RichTextEditor from '@/components/common/RichTextEditor.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import {
  listSeal,
  getSeal,
  delSeal,
  addSeal,
  updateSeal,
  updateSealStatus,
  batchDeleteSeal,
  batchUpdateSealStatus,
  getSealStats,
  type Seal,
  type SealForm,
  type SealStats,
} from '@/api/xunyin/seal'
import { listJourney, type Journey } from '@/api/xunyin/journey'
import { listCity, type City } from '@/api/xunyin/city'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'
import { getDictDataByType, type DictData } from '@/api/system/dict'

const loading = ref(true)
const sealList = ref<Seal[]>([])
const journeyOptions = ref<Journey[]>([])
const cityOptions = ref<City[]>([])
const total = ref(0)
const stats = ref<SealStats | null>(null)
const activeTab = ref('all')

// 字典数据
const sealTypeOptions = ref<DictData[]>([])
const rarityOptions = ref<DictData[]>([])

// 稀有度颜色映射（可通过字典的 cssClass 配置）
const rarityColorMap: Record<string, string> = {
  common: 'bg-gray-100 text-gray-800',
  rare: 'bg-blue-100 text-blue-800',
  legendary: 'bg-amber-100 text-amber-800',
}

// 类型图标映射
const typeIconMap: Record<string, typeof Route> = {
  route: Route,
  city: MapPin,
  special: Sparkles,
}

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  type: undefined as string | undefined,
  rarity: undefined as string | undefined,
  name: '',
  status: undefined as string | undefined,
})

const showDialog = ref(false)
const showDeleteDialog = ref(false)
const showImageDialog = ref(false)
const previewImage = ref('')
const sealToDelete = ref<Seal | null>(null)
const isEdit = ref(false)
const submitLoading = ref(false)

// 批量选择
const selectedIds = ref<string[]>([])
const selectAll = ref(false)
const showBatchDeleteDialog = ref(false)

const form = reactive<SealForm>({
  type: 'route',
  rarity: 'common',
  name: '',
  imageAsset: '',
  description: '',
  unlockCondition: '',
  badgeTitle: '',
  journeyId: undefined,
  cityId: undefined,
  orderNum: 0,
  status: '0',
})

const { toast } = useToast()

// 统计卡片数据
const statsCards = computed(() => {
  if (!stats.value) return []
  const cards = [
    {
      title: '印记总数',
      value: stats.value.total,
      icon: Award,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
  ]
  // 根据字典动态生成类型统计卡片
  sealTypeOptions.value.forEach((opt) => {
    const typeKey = opt.dictValue as keyof typeof stats.value.byType
    cards.push({
      title: opt.dictLabel || opt.dictValue || '',
      value: stats.value?.byType[typeKey] || 0,
      icon: typeIconMap[opt.dictValue || ''] || Award,
      color:
        opt.dictValue === 'route'
          ? 'text-purple-500'
          : opt.dictValue === 'city'
            ? 'text-blue-500'
            : 'text-amber-500',
      bgColor:
        opt.dictValue === 'route'
          ? 'bg-purple-50'
          : opt.dictValue === 'city'
            ? 'bg-blue-50'
            : 'bg-amber-50',
    })
  })
  return cards
})

async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      type: queryParams.type === 'all' ? undefined : queryParams.type,
      rarity: queryParams.rarity === 'all' ? undefined : queryParams.rarity,
      status: queryParams.status === 'all' ? undefined : queryParams.status,
    }
    const res = await listSeal(params)
    sealList.value = res.list
    total.value = res.total
    selectedIds.value = []
    selectAll.value = false
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    stats.value = await getSealStats()
  } catch {
    // 忽略统计加载失败
  }
}

async function loadDictData() {
  try {
    const [typeData, rarityData] = await Promise.all([
      getDictDataByType('xunyin_seal_type'),
      getDictDataByType('xunyin_seal_rarity'),
    ])
    sealTypeOptions.value = typeData
    rarityOptions.value = rarityData
  } catch {
    // 忽略字典加载失败
  }
}

async function getOptions() {
  try {
    const [journeyRes, cityRes] = await Promise.all([
      listJourney({ pageSize: 100 }),
      listCity({ pageSize: 100 }),
    ])
    journeyOptions.value = journeyRes.list
    cityOptions.value = cityRes.list
  } catch {
    // 忽略错误
  }
}

function handleTabChange(tab: string | number) {
  const tabValue = String(tab)
  activeTab.value = tabValue
  queryParams.type = tabValue === 'all' ? undefined : tabValue
  queryParams.pageNum = 1
  getList()
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  activeTab.value = 'all'
  queryParams.type = undefined
  queryParams.rarity = undefined
  queryParams.name = ''
  queryParams.status = undefined
  handleQuery()
}

function resetForm() {
  form.id = undefined
  form.type = 'route'
  form.rarity = 'common'
  form.name = ''
  form.imageAsset = ''
  form.description = ''
  form.unlockCondition = ''
  form.badgeTitle = ''
  form.journeyId = undefined
  form.cityId = undefined
  form.orderNum = 0
  form.status = '0'
}

function handleAdd() {
  resetForm()
  isEdit.value = false
  showDialog.value = true
}

async function handleUpdate(row: Seal) {
  resetForm()
  isEdit.value = true
  const data = await getSeal(row.id)
  Object.assign(form, data)
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.name || !form.type || !form.imageAsset) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }
  submitLoading.value = true
  try {
    if (form.id) {
      await updateSeal(form)
      toast({ title: '修改成功' })
    } else {
      await addSeal(form)
      toast({ title: '新增成功' })
    }
    showDialog.value = false
    getList()
    loadStats()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: Seal) {
  sealToDelete.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!sealToDelete.value) return
  try {
    await delSeal(sealToDelete.value.id)
    toast({ title: '删除成功' })
    getList()
    loadStats()
    showDeleteDialog.value = false
  } catch {
    // 错误已由拦截器处理
  }
}

// 批量删除
function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要删除的数据', variant: 'destructive' })
    return
  }
  showBatchDeleteDialog.value = true
}

async function confirmBatchDelete() {
  try {
    await batchDeleteSeal(selectedIds.value)
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    loadStats()
    showBatchDeleteDialog.value = false
  } catch {
    // 错误已由拦截器处理
  }
}

// 批量状态操作
async function handleBatchStatus(status: string) {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要操作的数据', variant: 'destructive' })
    return
  }
  try {
    await batchUpdateSealStatus(selectedIds.value, status)
    toast({ title: status === '0' ? '批量启用成功' : '批量停用成功' })
    getList()
    loadStats()
  } catch (e: unknown) {
    const error = e as Error
    toast({ title: '操作失败', description: error.message, variant: 'destructive' })
  }
}

function handleSelectOne(id: string) {
  const index = selectedIds.value.indexOf(id)
  if (index > -1) {
    selectedIds.value.splice(index, 1)
  } else {
    selectedIds.value.push(id)
  }
}

// 监听全选状态变化
watch(selectAll, (newVal) => {
  if (newVal) {
    selectedIds.value = sealList.value.map((s) => s.id)
  } else if (selectedIds.value.length === sealList.value.length) {
    selectedIds.value = []
  }
})

// 监听选中项变化，更新全选状态
watch(
  selectedIds,
  (newVal) => {
    selectAll.value = sealList.value.length > 0 && newVal.length === sealList.value.length
  },
  { deep: true },
)

function getSealTypeLabel(type: string) {
  const opt = sealTypeOptions.value.find((t) => t.dictValue === type)
  return opt?.dictLabel || type
}

function getSealTypeVariant(type: string) {
  // 可以通过字典的 listClass 配置，这里保留默认映射
  switch (type) {
    case 'route':
      return 'default'
    case 'city':
      return 'secondary'
    case 'special':
      return 'outline'
    default:
      return 'default'
  }
}

function getRarityLabel(rarity: string) {
  const opt = rarityOptions.value.find((r) => r.dictValue === rarity)
  return opt?.dictLabel || rarity
}

function getRarityClass(rarity: string) {
  // 优先使用字典的 cssClass，否则使用默认映射
  const opt = rarityOptions.value.find((r) => r.dictValue === rarity)
  if (opt?.cssClass) return opt.cssClass
  return rarityColorMap[rarity] || 'bg-gray-100 text-gray-800'
}

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await updateSealStatus(id, status)
  const seal = sealList.value.find((s) => s.id === id)
  if (seal) seal.status = status
  loadStats()
}

// 复制数据
async function handleCopy(row: Seal) {
  resetForm()
  const data = await getSeal(row.id)
  Object.assign(form, data)
  form.id = undefined
  form.name = `${data.name} (副本)`
  isEdit.value = false
  showDialog.value = true
}

// 图片预览
function handleImagePreview(url: string) {
  previewImage.value = getResourceUrl(url)
  showImageDialog.value = true
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('印记数据')
  const columns = [
    { key: 'name' as const, label: '名称' },
    { key: 'type' as const, label: '类型' },
    { key: 'rarity' as const, label: '稀有度' },
    { key: 'journeyName' as const, label: '关联文化之旅' },
    { key: 'cityName' as const, label: '关联城市' },
    { key: 'badgeTitle' as const, label: '称号' },
    { key: 'collectedCount' as const, label: '收集人数' },
    { key: 'unlockCondition' as const, label: '解锁条件' },
    { key: 'orderNum' as const, label: '排序号' },
    { key: 'status' as const, label: '状态' },
  ]
  if (format === 'xlsx') {
    exportToExcel(sealList.value, columns, filename, '印记')
  } else if (format === 'csv') {
    exportToCsv(sealList.value, columns, filename)
  } else {
    exportToJson(sealList.value, filename)
  }
}

onMounted(() => {
  loadDictData()
  getList()
  getOptions()
  loadStats()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <!-- 页面标题 -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">印记管理</h2>
        <p class="text-sm text-muted-foreground">管理用户可收集的印记徽章</p>
      </div>
      <div class="flex gap-2">
        <ExportButton
          v-if="sealList.length > 0"
          :formats="['xlsx', 'csv', 'json']"
          @export="handleExport"
        />
        <Button size="sm" @click="handleAdd"> <Plus class="h-4 w-4 mr-2" />新增印记 </Button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div v-if="stats" class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <Card v-for="card in statsCards" :key="card.title" class="overflow-hidden">
        <CardContent class="p-4">
          <div class="flex items-center gap-3">
            <div :class="['p-2 rounded-lg', card.bgColor]">
              <component :is="card.icon" :class="['h-5 w-5', card.color]" />
            </div>
            <div>
              <p class="text-sm text-muted-foreground">{{ card.title }}</p>
              <p class="text-2xl font-bold">{{ card.value }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- 标签页切换 -->
    <Tabs :model-value="activeTab" @update:model-value="handleTabChange" class="w-full">
      <TabsList
        :class="['grid w-full lg:w-auto lg:inline-grid', `grid-cols-${sealTypeOptions.length + 1}`]"
      >
        <TabsTrigger value="all">
          <Award class="h-4 w-4 mr-2" />
          全部
          <Badge variant="secondary" class="ml-2">{{ stats?.total || 0 }}</Badge>
        </TabsTrigger>
        <TabsTrigger v-for="opt in sealTypeOptions" :key="opt.dictValue" :value="opt.dictValue">
          <component :is="typeIconMap[opt.dictValue || ''] || Award" class="h-4 w-4 mr-2" />
          {{ opt.dictLabel }}
          <Badge variant="secondary" class="ml-2">
            {{ stats?.byType[opt.dictValue as keyof typeof stats.byType] || 0 }}
          </Badge>
        </TabsTrigger>
      </TabsList>
    </Tabs>

    <!-- 筛选条件 -->
    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">稀有度</span>
        <Select v-model="queryParams.rarity" @update:model-value="handleQuery">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">全部</SelectItem>
            <SelectItem v-for="r in rarityOptions" :key="r.dictValue" :value="r.dictValue || ''">
              {{ r.dictLabel }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
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
        <span class="text-sm font-medium">状态</span>
        <Select v-model="queryParams.status" @update:model-value="handleQuery">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">全部</SelectItem>
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

    <!-- 数据表格 -->
    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="9" :rows="10" />
      <EmptyState
        v-else-if="sealList.length === 0"
        title="暂无印记数据"
        action-text="新增印记"
        @action="handleAdd"
      />
      <Table v-else class="min-w-[1000px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox v-model="selectAll" />
            </TableHead>
            <TableHead>印记</TableHead>
            <TableHead>类型</TableHead>
            <TableHead>稀有度</TableHead>
            <TableHead>关联</TableHead>
            <TableHead>收集人数</TableHead>
            <TableHead>排序</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="seal in sealList" :key="seal.id">
            <TableCell>
              <Checkbox
                :model-value="selectedIds.includes(seal.id)"
                @update:model-value="() => handleSelectOne(seal.id)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-3">
                <div
                  v-if="seal.imageAsset"
                  class="cursor-pointer"
                  @click="handleImagePreview(seal.imageAsset)"
                >
                  <img
                    :src="getResourceUrl(seal.imageAsset)"
                    :alt="seal.name"
                    class="w-10 h-10 rounded-full object-cover border hover:ring-2 hover:ring-primary transition-all"
                  />
                </div>
                <div
                  v-else
                  class="w-10 h-10 rounded-full bg-muted flex items-center justify-center"
                >
                  <Award class="w-5 h-5 text-primary" />
                </div>
                <div>
                  <div class="font-medium flex items-center gap-2">
                    {{ seal.name }}
                    <span
                      v-if="seal.badgeTitle"
                      class="text-xs px-1.5 py-0.5 bg-amber-100 text-amber-700 rounded"
                    >
                      {{ seal.badgeTitle }}
                    </span>
                  </div>
                  <div class="text-xs text-muted-foreground line-clamp-1 max-w-[200px]">
                    {{ seal.description || seal.unlockCondition || '-' }}
                  </div>
                </div>
              </div>
            </TableCell>
            <TableCell>
              <Badge :variant="getSealTypeVariant(seal.type)">
                {{ getSealTypeLabel(seal.type) }}
              </Badge>
            </TableCell>
            <TableCell>
              <span
                :class="['text-xs px-2 py-1 rounded-full font-medium', getRarityClass(seal.rarity)]"
              >
                {{ getRarityLabel(seal.rarity) }}
              </span>
            </TableCell>
            <TableCell>
              <div v-if="seal.journeyName" class="flex items-center gap-1.5">
                <Badge variant="outline" class="text-purple-600 border-purple-200 bg-purple-50">
                  <Route class="w-3 h-3 mr-1" />
                  {{ seal.journeyName }}
                </Badge>
              </div>
              <div v-else-if="seal.cityName" class="flex items-center gap-1.5">
                <Badge variant="outline" class="text-blue-600 border-blue-200 bg-blue-50">
                  <MapPin class="w-3 h-3 mr-1" />
                  {{ seal.cityName }}
                </Badge>
              </div>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-1.5">
                <Users class="w-4 h-4 text-muted-foreground" />
                <span :class="{ 'font-medium text-primary': (seal.collectedCount || 0) > 0 }">
                  {{ seal.collectedCount || 0 }}
                </span>
              </div>
            </TableCell>
            <TableCell>{{ seal.orderNum }}</TableCell>
            <TableCell>
              <StatusSwitch
                :model-value="seal.status"
                :id="seal.id"
                :name="seal.name"
                @change="handleStatusChange"
              />
            </TableCell>
            <TableCell class="text-right space-x-1">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger as-child>
                    <Button variant="ghost" size="icon" @click="handleCopy(seal)">
                      <Copy class="w-4 h-4" />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>复制</TooltipContent>
                </Tooltip>
              </TooltipProvider>
              <Button variant="ghost" size="icon" @click="handleUpdate(seal)">
                <Edit class="w-4 h-4" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                class="text-destructive"
                @click="handleDelete(seal)"
              >
                <Trash2 class="w-4 h-4" />
              </Button>
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

    <!-- 新增/编辑对话框 -->
    <Dialog v-model:open="showDialog">
      <DialogContent class="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{{ isEdit ? '修改印记' : '新增印记' }}</DialogTitle>
          <DialogDescription>请填写印记信息</DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>印记类型 *</Label>
              <Select v-model="form.type">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="t in sealTypeOptions"
                    :key="t.dictValue"
                    :value="t.dictValue || ''"
                  >
                    {{ t.dictLabel }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid gap-2">
              <Label>稀有度</Label>
              <Select v-model="form.rarity">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="r in rarityOptions"
                    :key="r.dictValue"
                    :value="r.dictValue || ''"
                  >
                    {{ r.dictLabel }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div class="grid gap-2">
            <Label>名称 *</Label>
            <Input v-model="form.name" placeholder="如：西湖探索者" />
          </div>
          <div class="grid gap-2">
            <Label>图片资源 *</Label>
            <ImageUpload v-model="form.imageAsset" placeholder="上传印记图片" />
          </div>
          <div class="grid grid-cols-2 gap-4" v-if="form.type === 'route'">
            <div class="grid gap-2 col-span-2">
              <Label>关联文化之旅</Label>
              <Select v-model="form.journeyId">
                <SelectTrigger><SelectValue placeholder="请选择" /></SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="j in journeyOptions" :key="j.id" :value="j.id">
                    {{ j.name }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4" v-if="form.type === 'city'">
            <div class="grid gap-2 col-span-2">
              <Label>关联城市</Label>
              <Select v-model="form.cityId">
                <SelectTrigger><SelectValue placeholder="请选择" /></SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="c in cityOptions" :key="c.id" :value="c.id">
                    {{ c.name }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div class="grid gap-2">
            <Label>描述</Label>
            <RichTextEditor v-model="form.description" placeholder="印记描述" />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>解锁条件</Label>
              <Input v-model="form.unlockCondition" placeholder="如：完成西湖十景路线" />
            </div>
            <div class="grid gap-2">
              <Label>解锁称号</Label>
              <Input v-model="form.badgeTitle" placeholder="如：西湖探索者" />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>排序号</Label>
              <Input v-model.number="form.orderNum" type="number" />
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
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showDialog = false">取消</Button>
          <Button @click="handleSubmit" :disabled="submitLoading">
            <Loader2 v-if="submitLoading" class="mr-2 h-4 w-4 animate-spin" />确定
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- 图片预览对话框 -->
    <Dialog v-model:open="showImageDialog">
      <DialogContent class="sm:max-w-[500px] p-0 overflow-hidden">
        <DialogHeader class="sr-only">
          <DialogTitle>图片预览</DialogTitle>
        </DialogHeader>
        <div class="relative">
          <Button
            variant="ghost"
            size="icon"
            class="absolute top-2 right-2 z-10 bg-black/50 hover:bg-black/70 text-white rounded-full"
            @click="showImageDialog = false"
          >
            <X class="w-4 h-4" />
          </Button>
          <img :src="previewImage" alt="预览" class="w-full h-auto max-h-[80vh] object-contain" />
        </div>
      </DialogContent>
    </Dialog>

    <!-- 删除确认对话框 -->
    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`确定要删除印记「${sealToDelete?.name}」吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <!-- 批量删除确认对话框 -->
    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 个印记吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
