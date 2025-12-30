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
import { Plus, Search, Trash2, Loader2, RefreshCw, Edit, Award, Copy } from 'lucide-vue-next'
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
  type Seal,
  type SealForm,
} from '@/api/xunyin/seal'
import { listJourney, type Journey } from '@/api/xunyin/journey'
import { listCity, type City } from '@/api/xunyin/city'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import { exportToCsv, exportToJson, getExportFilename } from '@/utils/export'

const loading = ref(true)
const sealList = ref<Seal[]>([])
const journeyOptions = ref<Journey[]>([])
const cityOptions = ref<City[]>([])
const total = ref(0)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  type: undefined as string | undefined,
  name: '',
  status: undefined as string | undefined,
})

const showDialog = ref(false)
const showDeleteDialog = ref(false)
const sealToDelete = ref<Seal | null>(null)
const isEdit = ref(false)
const submitLoading = ref(false)

// 批量选择
const selectedIds = ref<string[]>([])
const showBatchDeleteDialog = ref(false)

const sealTypeOptions = [
  { value: 'route', label: '路线印记' },
  { value: 'city', label: '城市印记' },
  { value: 'special', label: '特殊印记' },
]

const form = reactive<SealForm>({
  type: 'route',
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

async function getList() {
  loading.value = true
  try {
    const res = await listSeal(queryParams)
    sealList.value = res.list
    total.value = res.total
    selectedIds.value = []
  } finally {
    loading.value = false
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
    // 忽略错误，下拉选项加载失败不影响主列表
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.type = undefined
  queryParams.name = ''
  queryParams.status = undefined
  handleQuery()
}

function resetForm() {
  form.id = undefined
  form.type = 'route'
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
    await Promise.all(selectedIds.value.map((id) => delSeal(id)))
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    showBatchDeleteDialog.value = false
  } catch {}
}

function handleSelectAll(checked: boolean) {
  selectedIds.value = checked ? sealList.value.map((s) => s.id) : []
}

function handleSelectOne(id: string, checked: boolean) {
  if (checked) {
    selectedIds.value.push(id)
  } else {
    selectedIds.value = selectedIds.value.filter((i) => i !== id)
  }
}

function getSealTypeLabel(type: string) {
  return sealTypeOptions.find((t) => t.value === type)?.label || type
}

function getSealTypeVariant(type: string) {
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

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await updateSealStatus(id, status)
  toast({ title: '状态更新成功' })
  const seal = sealList.value.find((s) => s.id === id)
  if (seal) seal.status = status
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

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('印记数据')
  if (format === 'csv') {
    exportToCsv(
      sealList.value,
      [
        { key: 'name', label: '名称' },
        { key: 'type', label: '类型' },
        { key: 'journeyName', label: '关联文化之旅' },
        { key: 'cityName', label: '关联城市' },
        { key: 'badgeTitle', label: '称号' },
        { key: 'unlockCondition', label: '解锁条件' },
        { key: 'orderNum', label: '排序号' },
        { key: 'status', label: '状态' },
      ],
      filename
    )
  } else {
    exportToJson(sealList.value, filename)
  }
}

onMounted(() => {
  getList()
  getOptions()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">印记管理</h2>
        <p class="text-sm text-muted-foreground">管理用户可收集的印记徽章</p>
      </div>
      <div class="flex gap-2">
        <ExportButton
          v-if="sealList.length > 0"
          :formats="['csv', 'json']"
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
        <Button size="sm" @click="handleAdd"> <Plus class="h-4 w-4 mr-2" />新增印记 </Button>
      </div>
    </div>

    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">印记类型</span>
        <Select v-model="queryParams.type">
          <SelectTrigger class="w-[130px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="t in sealTypeOptions" :key="t.value" :value="t.value">{{
              t.label
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
        <Select v-model="queryParams.status">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
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

    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="8" :rows="10" />
      <EmptyState
        v-else-if="sealList.length === 0"
        title="暂无印记数据"
        action-text="新增印记"
        @action="handleAdd"
      />
      <Table v-else class="min-w-[900px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox
                :checked="selectedIds.length === sealList.length && sealList.length > 0"
                @update:checked="handleSelectAll"
              />
            </TableHead>
            <TableHead>印记</TableHead>
            <TableHead>类型</TableHead>
            <TableHead>关联</TableHead>
            <TableHead>称号</TableHead>
            <TableHead>排序</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="seal in sealList" :key="seal.id">
            <TableCell>
              <Checkbox
                :checked="selectedIds.includes(seal.id)"
                @update:checked="(checked: boolean) => handleSelectOne(seal.id, checked)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-3">
                <TooltipProvider v-if="seal.imageAsset">
                  <Tooltip>
                    <TooltipTrigger>
                      <img
                        :src="seal.imageAsset"
                        :alt="seal.name"
                        class="w-10 h-10 rounded-full object-cover border"
                      />
                    </TooltipTrigger>
                    <TooltipContent side="right" class="p-0">
                      <img
                        :src="seal.imageAsset"
                        :alt="seal.name"
                        class="max-w-[200px] max-h-[200px] rounded-lg"
                      />
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
                <div
                  v-else
                  class="w-10 h-10 rounded-full bg-muted flex items-center justify-center"
                >
                  <Award class="w-5 h-5 text-primary" />
                </div>
                <div>
                  <div class="font-medium">{{ seal.name }}</div>
                  <div class="text-xs text-muted-foreground line-clamp-1">
                    {{ seal.description || '-' }}
                  </div>
                </div>
              </div>
            </TableCell>
            <TableCell>
              <Badge :variant="getSealTypeVariant(seal.type)">{{
                getSealTypeLabel(seal.type)
              }}</Badge>
            </TableCell>
            <TableCell>
              <span v-if="seal.journeyName">文化之旅: {{ seal.journeyName }}</span>
              <span v-else-if="seal.cityName">城市: {{ seal.cityName }}</span>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell>{{ seal.badgeTitle || '-' }}</TableCell>
            <TableCell>{{ seal.orderNum }}</TableCell>
            <TableCell>
              <StatusSwitch :model-value="seal.status" :id="seal.id" @change="handleStatusChange" />
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
              <Button variant="ghost" size="icon" @click="handleUpdate(seal)"
                ><Edit class="w-4 h-4"
              /></Button>
              <Button
                variant="ghost"
                size="icon"
                class="text-destructive"
                @click="handleDelete(seal)"
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
                  <SelectItem v-for="t in sealTypeOptions" :key="t.value" :value="t.value">{{
                    t.label
                  }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid gap-2">
              <Label>名称 *</Label>
              <Input v-model="form.name" placeholder="如：西湖探索者" />
            </div>
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
                  <SelectItem v-for="j in journeyOptions" :key="j.id" :value="j.id">{{
                    j.name
                  }}</SelectItem>
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
                  <SelectItem v-for="c in cityOptions" :key="c.id" :value="c.id">{{
                    c.name
                  }}</SelectItem>
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

    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`确定要删除印记「${sealToDelete?.name}」吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

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
