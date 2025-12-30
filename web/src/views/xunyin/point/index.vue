<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
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
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Plus,
  Search,
  Trash2,
  Loader2,
  RefreshCw,
  Edit,
  MapPin,
  Image as ImageIcon,
  Copy,
} from 'lucide-vue-next'
import ImageUpload from '@/components/common/ImageUpload.vue'
import RichTextEditor from '@/components/common/RichTextEditor.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import {
  listPoint,
  getPoint,
  delPoint,
  addPoint,
  updatePoint,
  updatePointStatus,
  type ExplorationPoint,
  type PointForm,
} from '@/api/xunyin/point'
import { listJourney, type Journey } from '@/api/xunyin/journey'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

const route = useRoute()
const loading = ref(true)
const pointList = ref<ExplorationPoint[]>([])
const journeyOptions = ref<Journey[]>([])
const total = ref(0)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  journeyId: (route.query.journeyId as string) || undefined,
  name: '',
  taskType: undefined as string | undefined,
  status: undefined as string | undefined,
})

const showDialog = ref(false)
const showDeleteDialog = ref(false)
const pointToDelete = ref<ExplorationPoint | null>(null)
const isEdit = ref(false)
const submitLoading = ref(false)

// 批量选择
const selectedIds = ref<string[]>([])
const showBatchDeleteDialog = ref(false)

const taskTypeOptions = [
  { value: 'gesture', label: '手势识别' },
  { value: 'photo', label: '拍照探索' },
  { value: 'treasure', label: 'AR寻宝' },
]

const form = reactive<PointForm>({
  journeyId: '',
  name: '',
  latitude: 0,
  longitude: 0,
  taskType: 'gesture',
  taskDescription: '',
  targetGesture: '',
  arAssetUrl: '',
  culturalBackground: '',
  culturalKnowledge: '',
  distanceFromPrev: 0,
  pointsReward: 50,
  orderNum: 0,
  status: '0',
})

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const res = await listPoint(queryParams)
    pointList.value = res.list
    total.value = res.total
    selectedIds.value = []
  } finally {
    loading.value = false
  }
}

async function getJourneyOptions() {
  try {
    const res = await listJourney({ pageSize: 100 })
    journeyOptions.value = res.list
  } catch {
    // 忽略错误
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.journeyId = undefined
  queryParams.name = ''
  queryParams.taskType = undefined
  queryParams.status = undefined
  handleQuery()
}

function resetForm() {
  form.id = undefined
  form.journeyId = ''
  form.name = ''
  form.latitude = 0
  form.longitude = 0
  form.taskType = 'gesture'
  form.taskDescription = ''
  form.targetGesture = ''
  form.arAssetUrl = ''
  form.culturalBackground = ''
  form.culturalKnowledge = ''
  form.distanceFromPrev = 0
  form.pointsReward = 50
  form.orderNum = 0
  form.status = '0'
}

function handleAdd() {
  resetForm()
  isEdit.value = false
  showDialog.value = true
}

async function handleUpdate(row: ExplorationPoint) {
  resetForm()
  isEdit.value = true
  const data = await getPoint(row.id)
  Object.assign(form, data)
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.name || !form.journeyId || !form.taskDescription) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }
  submitLoading.value = true
  try {
    if (form.id) {
      await updatePoint(form)
      toast({ title: '修改成功' })
    } else {
      await addPoint(form)
      toast({ title: '新增成功' })
    }
    showDialog.value = false
    getList()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: ExplorationPoint) {
  pointToDelete.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!pointToDelete.value) return
  try {
    await delPoint(pointToDelete.value.id)
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
  showBatchDeleteDialog.value = true
}

async function confirmBatchDelete() {
  try {
    await Promise.all(selectedIds.value.map((id) => delPoint(id)))
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    showBatchDeleteDialog.value = false
  } catch {}
}

function handleSelectAll(checked: boolean) {
  selectedIds.value = checked ? pointList.value.map((p) => p.id) : []
}

function handleSelectOne(id: string, checked: boolean) {
  if (checked) {
    selectedIds.value.push(id)
  } else {
    selectedIds.value = selectedIds.value.filter((i) => i !== id)
  }
}

function getTaskTypeLabel(type: string) {
  return taskTypeOptions.find((t) => t.value === type)?.label || type
}

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await updatePointStatus(id, status)
  toast({ title: '状态更新成功' })
  const point = pointList.value.find((p) => p.id === id)
  if (point) point.status = status
}

// 复制数据
async function handleCopy(row: ExplorationPoint) {
  resetForm()
  const data = await getPoint(row.id)
  Object.assign(form, data)
  form.id = undefined
  form.name = `${data.name} (副本)`
  isEdit.value = false
  showDialog.value = true
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('探索点数据')
  const columns = [
    { key: 'name' as const, label: '名称' },
    { key: 'journeyName' as const, label: '所属文化之旅' },
    { key: 'taskType' as const, label: '任务类型' },
    { key: 'longitude' as const, label: '经度' },
    { key: 'latitude' as const, label: '纬度' },
    { key: 'pointsReward' as const, label: '积分奖励' },
    { key: 'orderNum' as const, label: '排序号' },
    { key: 'status' as const, label: '状态' },
  ]
  if (format === 'xlsx') {
    exportToExcel(pointList.value, columns, filename, '探索点')
  } else if (format === 'csv') {
    exportToCsv(pointList.value, columns, filename)
  } else {
    exportToJson(pointList.value, filename)
  }
}

onMounted(() => {
  getList()
  getJourneyOptions()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">探索点管理</h2>
        <p class="text-sm text-muted-foreground">管理文化之旅中的探索点和任务</p>
      </div>
      <div class="flex gap-2">
        <ExportButton
          v-if="pointList.length > 0"
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
        <Button size="sm" @click="handleAdd"> <Plus class="h-4 w-4 mr-2" />新增探索点 </Button>
      </div>
    </div>

    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">所属文化之旅</span>
        <Select v-model="queryParams.journeyId">
          <SelectTrigger class="w-[180px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="j in journeyOptions" :key="j.id" :value="j.id">{{
              j.name
            }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">名称</span>
        <Input
          v-model="queryParams.name"
          placeholder="请输入"
          class="w-[120px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">任务类型</span>
        <Select v-model="queryParams.taskType">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="t in taskTypeOptions" :key="t.value" :value="t.value">{{
              t.label
            }}</SelectItem>
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
      <TableSkeleton v-if="loading" :columns="9" :rows="10" />
      <EmptyState
        v-else-if="pointList.length === 0"
        title="暂无探索点数据"
        action-text="新增探索点"
        @action="handleAdd"
      />
      <Table v-else class="min-w-[1000px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox
                :checked="selectedIds.length === pointList.length && pointList.length > 0"
                @update:checked="handleSelectAll"
              />
            </TableHead>
            <TableHead>名称</TableHead>
            <TableHead>所属文化之旅</TableHead>
            <TableHead>任务类型</TableHead>
            <TableHead>坐标</TableHead>
            <TableHead>积分奖励</TableHead>
            <TableHead>排序</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="point in pointList" :key="point.id">
            <TableCell>
              <Checkbox
                :checked="selectedIds.includes(point.id)"
                @update:checked="(checked: boolean) => handleSelectOne(point.id, checked)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-3">
                <TooltipProvider v-if="point.arAssetUrl">
                  <Tooltip>
                    <TooltipTrigger>
                      <img
                        :src="getResourceUrl(point.arAssetUrl)"
                        :alt="point.name"
                        class="w-10 h-10 rounded-lg object-cover border"
                      />
                    </TooltipTrigger>
                    <TooltipContent side="right" class="p-0">
                      <img
                        :src="getResourceUrl(point.arAssetUrl)"
                        :alt="point.name"
                        class="max-w-[200px] max-h-[200px] rounded-lg"
                      />
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
                <div v-else class="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                  <ImageIcon class="w-5 h-5 text-muted-foreground" />
                </div>
                <span class="font-medium">{{ point.name }}</span>
              </div>
            </TableCell>
            <TableCell>{{ point.journeyName }}</TableCell>
            <TableCell>
              <Badge variant="outline">{{ getTaskTypeLabel(point.taskType) }}</Badge>
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-1 text-sm text-muted-foreground">
                <MapPin class="w-3 h-3" />
                {{ point.longitude.toFixed(4) }}, {{ point.latitude.toFixed(4) }}
              </div>
            </TableCell>
            <TableCell>{{ point.pointsReward }}</TableCell>
            <TableCell>{{ point.orderNum }}</TableCell>
            <TableCell>
              <StatusSwitch
                :model-value="point.status"
                :id="point.id"
                @change="handleStatusChange"
              />
            </TableCell>
            <TableCell class="text-right space-x-1">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger as-child>
                    <Button variant="ghost" size="icon" @click="handleCopy(point)">
                      <Copy class="w-4 h-4" />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>复制</TooltipContent>
                </Tooltip>
              </TooltipProvider>
              <Button variant="ghost" size="icon" @click="handleUpdate(point)"
                ><Edit class="w-4 h-4"
              /></Button>
              <Button
                variant="ghost"
                size="icon"
                class="text-destructive"
                @click="handleDelete(point)"
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
      <DialogContent class="sm:max-w-[700px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{{ isEdit ? '修改探索点' : '新增探索点' }}</DialogTitle>
          <DialogDescription>请填写探索点信息</DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>所属文化之旅 *</Label>
              <Select v-model="form.journeyId">
                <SelectTrigger><SelectValue placeholder="请选择" /></SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="j in journeyOptions" :key="j.id" :value="j.id">{{
                    j.name
                  }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid gap-2">
              <Label>名称 *</Label>
              <Input v-model="form.name" placeholder="如：断桥残雪" />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>经度</Label>
              <Input v-model.number="form.longitude" type="number" step="0.0000001" />
            </div>
            <div class="grid gap-2">
              <Label>纬度</Label>
              <Input v-model.number="form.latitude" type="number" step="0.0000001" />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>任务类型 *</Label>
              <Select v-model="form.taskType">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="t in taskTypeOptions" :key="t.value" :value="t.value">{{
                    t.label
                  }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid gap-2" v-if="form.taskType === 'gesture'">
              <Label>目标手势</Label>
              <Input v-model="form.targetGesture" placeholder="如：比心" />
            </div>
            <div class="grid gap-2" v-if="form.taskType === 'treasure'">
              <Label>AR资源</Label>
              <ImageUpload v-model="form.arAssetUrl" placeholder="上传AR资源" />
            </div>
          </div>
          <div class="grid gap-2">
            <Label>任务描述 *</Label>
            <RichTextEditor v-model="form.taskDescription" placeholder="描述用户需要完成的任务" />
          </div>
          <div class="grid gap-2">
            <Label>文化背景</Label>
            <RichTextEditor
              v-model="form.culturalBackground"
              placeholder="该探索点的文化历史背景"
            />
          </div>
          <div class="grid gap-2">
            <Label>文化小知识</Label>
            <RichTextEditor
              v-model="form.culturalKnowledge"
              placeholder="完成任务后展示的文化知识"
            />
          </div>
          <div class="grid grid-cols-3 gap-4">
            <div class="grid gap-2">
              <Label>距上一点(米)</Label>
              <Input v-model.number="form.distanceFromPrev" type="number" />
            </div>
            <div class="grid gap-2">
              <Label>积分奖励</Label>
              <Input v-model.number="form.pointsReward" type="number" />
            </div>
            <div class="grid gap-2">
              <Label>排序号</Label>
              <Input v-model.number="form.orderNum" type="number" />
            </div>
          </div>
          <div class="grid gap-2">
            <Label>状态</Label>
            <Select v-model="form.status">
              <SelectTrigger class="w-[150px]"><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="0">正常</SelectItem>
                <SelectItem value="1">停用</SelectItem>
              </SelectContent>
            </Select>
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
      :description="`确定要删除探索点「${pointToDelete?.name}」吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 个探索点吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
