<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
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
import { Checkbox } from '@/components/ui/checkbox'
import { Switch } from '@/components/ui/switch'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Plus,
  Search,
  Trash2,
  Loader2,
  RefreshCw,
  Edit,
  Star,
  MapPin,
  Image as ImageIcon,
  Copy,
} from 'lucide-vue-next'
import ImageUpload from '@/components/common/ImageUpload.vue'
import AudioUpload from '@/components/common/AudioUpload.vue'
import RichTextEditor from '@/components/common/RichTextEditor.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import {
  listJourney,
  getJourney,
  delJourney,
  addJourney,
  updateJourney,
  updateJourneyStatus,
  type Journey,
  type JourneyForm,
} from '@/api/xunyin/journey'
import { listCity, type City } from '@/api/xunyin/city'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const journeyList = ref<Journey[]>([])
const cityOptions = ref<City[]>([])
const total = ref(0)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  cityId: (route.query.cityId as string) || undefined,
  name: '',
  status: undefined as string | undefined,
})

const showDialog = ref(false)
const showDeleteDialog = ref(false)
const journeyToDelete = ref<Journey | null>(null)
const isEdit = ref(false)
const submitLoading = ref(false)

// 批量选择
const selectedIds = ref<string[]>([])
const selectAll = ref(false)
const showBatchDeleteDialog = ref(false)

const form = reactive<JourneyForm>({
  cityId: '',
  name: '',
  theme: '',
  coverImage: '',
  description: '',
  rating: 5,
  estimatedMinutes: 60,
  totalDistance: 1000,
  isLocked: false,
  unlockCondition: '',
  bgmUrl: '',
  orderNum: 0,
  status: '0',
})

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      cityId: queryParams.cityId === 'all' ? undefined : queryParams.cityId,
      status: queryParams.status === 'all' ? undefined : queryParams.status,
    }
    const res = await listJourney(params)
    journeyList.value = res.list
    total.value = res.total
    selectedIds.value = []
    selectAll.value = false
  } finally {
    loading.value = false
  }
}

async function getCityOptions() {
  try {
    const res = await listCity({ pageSize: 100 })
    cityOptions.value = res.list
  } catch {
    // 忽略错误
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.cityId = undefined
  queryParams.name = ''
  queryParams.status = undefined
  handleQuery()
}

function resetForm() {
  form.id = undefined
  form.cityId = ''
  form.name = ''
  form.theme = ''
  form.coverImage = ''
  form.description = ''
  form.rating = 5
  form.estimatedMinutes = 60
  form.totalDistance = 1000
  form.isLocked = false
  form.unlockCondition = ''
  form.bgmUrl = ''
  form.orderNum = 0
  form.status = '0'
}

function handleAdd() {
  resetForm()
  isEdit.value = false
  showDialog.value = true
}

async function handleUpdate(row: Journey) {
  resetForm()
  isEdit.value = true
  const data = await getJourney(row.id)
  Object.assign(form, data)
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.name || !form.cityId || !form.theme) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }
  submitLoading.value = true
  try {
    if (form.id) {
      await updateJourney(form)
      toast({ title: '修改成功' })
    } else {
      await addJourney(form)
      toast({ title: '新增成功' })
    }
    showDialog.value = false
    getList()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: Journey) {
  if (row.pointCount && row.pointCount > 0) {
    toast({
      title: '无法删除',
      description: `该文化之旅下有 ${row.pointCount} 个探索点，请先删除关联数据`,
      variant: 'destructive',
    })
    return
  }
  journeyToDelete.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!journeyToDelete.value) return
  try {
    await delJourney(journeyToDelete.value.id)
    toast({ title: '删除成功' })
    getList()
    showDeleteDialog.value = false
  } catch {}
}

// 批量删除
function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要删除的数据', variant: 'destructive' })
    return
  }
  const hasRelated = journeyList.value
    .filter((j) => selectedIds.value.includes(j.id))
    .some((j) => j.pointCount && j.pointCount > 0)
  if (hasRelated) {
    toast({
      title: '无法删除',
      description: '选中的文化之旅中有关联探索点的数据，请先删除关联数据',
      variant: 'destructive',
    })
    return
  }
  showBatchDeleteDialog.value = true
}

async function confirmBatchDelete() {
  try {
    await Promise.all(selectedIds.value.map((id) => delJourney(id)))
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    showBatchDeleteDialog.value = false
  } catch {}
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
    selectedIds.value = journeyList.value.map((j) => j.id)
  } else if (selectedIds.value.length === journeyList.value.length) {
    selectedIds.value = []
  }
})

// 监听选中项变化，更新全选状态
watch(
  selectedIds,
  (newVal) => {
    selectAll.value = journeyList.value.length > 0 && newVal.length === journeyList.value.length
  },
  { deep: true }
)

function goToPoints(journeyId: string) {
  router.push({ path: '/xunyin/point', query: { journeyId } })
}

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await updateJourneyStatus(id, status)
  const journey = journeyList.value.find((j) => j.id === id)
  if (journey) journey.status = status
}

// 复制数据
async function handleCopy(row: Journey) {
  resetForm()
  const data = await getJourney(row.id)
  Object.assign(form, data)
  form.id = undefined
  form.name = `${data.name} (副本)`
  isEdit.value = false
  showDialog.value = true
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('文化之旅数据')
  const columns = [
    { key: 'name' as const, label: '名称' },
    { key: 'cityName' as const, label: '所属城市' },
    { key: 'theme' as const, label: '主题' },
    { key: 'rating' as const, label: '星级' },
    { key: 'estimatedMinutes' as const, label: '预计时长(分钟)' },
    { key: 'totalDistance' as const, label: '总距离(米)' },
    { key: 'completedCount' as const, label: '完成人数' },
    { key: 'pointCount' as const, label: '探索点数' },
    { key: 'status' as const, label: '状态' },
  ]
  if (format === 'xlsx') {
    exportToExcel(journeyList.value, columns, filename, '文化之旅')
  } else if (format === 'csv') {
    exportToCsv(journeyList.value, columns, filename)
  } else {
    exportToJson(journeyList.value, filename)
  }
}

onMounted(() => {
  getList()
  getCityOptions()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">文化之旅管理</h2>
        <p class="text-sm text-muted-foreground">管理寻印 App 中的文化之旅路线</p>
      </div>
      <div class="flex gap-2">
        <ExportButton
          v-if="journeyList.length > 0"
          :formats="['xlsx', 'csv', 'json']"
          @export="handleExport"
        />
        <Button
          v-if="selectedIds.length > 0"
          variant="destructive"
          size="sm"
          @click="handleBatchDelete"
        >
          <Trash2 class="h-4 w-4 mr-2" />批量删除 ({{ selectedIds.length }})
        </Button>
        <Button size="sm" @click="handleAdd"> <Plus class="h-4 w-4 mr-2" />新增文化之旅 </Button>
      </div>
    </div>

    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">所属城市</span>
        <Select v-model="queryParams.cityId" @update:model-value="handleQuery">
          <SelectTrigger class="w-[150px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">全部</SelectItem>
            <SelectItem v-for="city in cityOptions" :key="city.id" :value="city.id">{{
              city.name
            }}</SelectItem>
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

    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="10" :rows="10" />
      <EmptyState
        v-else-if="journeyList.length === 0"
        title="暂无文化之旅数据"
        action-text="新增文化之旅"
        @action="handleAdd"
      />
      <Table v-else class="min-w-[1100px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox v-model="selectAll" />
            </TableHead>
            <TableHead>名称</TableHead>
            <TableHead>所属城市</TableHead>
            <TableHead>主题</TableHead>
            <TableHead>星级</TableHead>
            <TableHead>探索点</TableHead>
            <TableHead>预计时长</TableHead>
            <TableHead>完成人数</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="journey in journeyList" :key="journey.id">
            <TableCell>
              <Checkbox
                :model-value="selectedIds.includes(journey.id)"
                @update:model-value="() => handleSelectOne(journey.id)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-3">
                <TooltipProvider v-if="journey.coverImage">
                  <Tooltip>
                    <TooltipTrigger>
                      <img
                        :src="getResourceUrl(journey.coverImage)"
                        :alt="journey.name"
                        class="w-10 h-10 rounded-lg object-cover border"
                      />
                    </TooltipTrigger>
                    <TooltipContent side="right" class="p-0">
                      <img
                        :src="getResourceUrl(journey.coverImage)"
                        :alt="journey.name"
                        class="max-w-[200px] max-h-[200px] rounded-lg"
                      />
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
                <div v-else class="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                  <ImageIcon class="w-5 h-5 text-muted-foreground" />
                </div>
                <span class="font-medium">{{ journey.name }}</span>
              </div>
            </TableCell>
            <TableCell>{{ journey.cityName }}</TableCell>
            <TableCell>{{ journey.theme }}</TableCell>
            <TableCell>
              <div class="flex items-center gap-1">
                <Star class="w-4 h-4 text-yellow-500 fill-yellow-500" />
                {{ journey.rating }}
              </div>
            </TableCell>
            <TableCell>
              <Button
                v-if="journey.pointCount"
                variant="link"
                size="sm"
                class="h-auto p-0 text-primary"
                @click="goToPoints(journey.id)"
              >
                <MapPin class="w-3 h-3 mr-1" />{{ journey.pointCount }} 个
              </Button>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell>{{ journey.estimatedMinutes }}分钟</TableCell>
            <TableCell>{{ journey.completedCount }}</TableCell>
            <TableCell>
              <StatusSwitch
                :model-value="journey.status"
                :id="journey.id"
                @change="handleStatusChange"
              />
            </TableCell>
            <TableCell class="text-right space-x-1">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger as-child>
                    <Button variant="ghost" size="icon" @click="handleCopy(journey)">
                      <Copy class="w-4 h-4" />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>复制</TooltipContent>
                </Tooltip>
              </TooltipProvider>
              <Button variant="ghost" size="icon" @click="handleUpdate(journey)"
                ><Edit class="w-4 h-4"
              /></Button>
              <Button
                variant="ghost"
                size="icon"
                class="text-destructive"
                @click="handleDelete(journey)"
                ><Trash2 class="w-4 h-4"
              /></Button>
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

    <Dialog v-model:open="showDialog">
      <DialogContent class="sm:max-w-[650px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{{ isEdit ? '修改文化之旅' : '新增文化之旅' }}</DialogTitle>
          <DialogDescription>请填写文化之旅信息</DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>所属城市 *</Label>
              <Select v-model="form.cityId">
                <SelectTrigger><SelectValue placeholder="请选择城市" /></SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="city in cityOptions" :key="city.id" :value="city.id">{{
                    city.name
                  }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid gap-2">
              <Label>名称 *</Label>
              <Input v-model="form.name" placeholder="请输入名称" />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>主题 *</Label>
              <Input v-model="form.theme" placeholder="如：西湖十景" />
            </div>
            <div class="grid gap-2">
              <Label>星级 (1-5)</Label>
              <Input v-model.number="form.rating" type="number" min="1" max="5" />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>预计时长(分钟)</Label>
              <Input v-model.number="form.estimatedMinutes" type="number" />
            </div>
            <div class="grid gap-2">
              <Label>总距离(米)</Label>
              <Input v-model.number="form.totalDistance" type="number" />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>封面图片</Label>
              <ImageUpload v-model="form.coverImage" placeholder="上传封面" />
            </div>
            <div class="grid gap-2">
              <Label>背景音乐</Label>
              <AudioUpload v-model="form.bgmUrl" placeholder="上传背景音乐" />
            </div>
          </div>
          <div class="grid gap-2">
            <Label>描述</Label>
            <RichTextEditor v-model="form.description" placeholder="文化之旅描述" />
          </div>
          <div class="flex items-center gap-4">
            <div class="flex items-center gap-2">
              <Switch v-model:checked="form.isLocked" />
              <Label>是否锁定</Label>
            </div>
            <div class="flex-1 grid gap-2" v-if="form.isLocked">
              <Input v-model="form.unlockCondition" placeholder="解锁条件说明" />
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

    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`确定要删除文化之旅「${journeyToDelete?.name}」吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 条文化之旅吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
