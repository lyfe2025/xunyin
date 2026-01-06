<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Plus, Edit, Trash2, RefreshCw, List } from 'lucide-vue-next'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import { formatDate } from '@/utils/format'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  listType,
  getType,
  delType,
  addType,
  updateType,
  changeDictTypeStatus,
  batchChangeDictTypeStatus,
  type DictType,
} from '@/api/system/dict'

const router = useRouter()
const { toast } = useToast()

// Query parameters
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  dictName: '',
  dictType: '',
  status: undefined,
})

const loading = ref(true)
const total = ref(0)
const typeList = ref<DictType[]>([])
const showDialog = ref(false)
const showDeleteDialog = ref(false)
const showBatchDeleteDialog = ref(false)
const dictToDelete = ref<DictType | null>(null)
const dialogTitle = ref('')
const form = reactive<Partial<DictType>>({
  dictId: undefined,
  dictName: '',
  dictType: '',
  status: '0',
  remark: '',
})

// 批量选择
const selectedIds = ref<string[]>([])
const selectAll = ref(false)

// Fetch data
async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      status: queryParams.status === 'all' ? undefined : queryParams.status,
    }
    const response = await listType(params)
    typeList.value = response.rows
    total.value = response.total
    selectedIds.value = []
    selectAll.value = false
  } finally {
    loading.value = false
  }
}

// Search operations
function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.dictName = ''
  queryParams.dictType = ''
  queryParams.status = undefined
  handleQuery()
}

// Add/Edit operations
function handleAdd() {
  resetForm()
  dialogTitle.value = '添加字典类型'
  showDialog.value = true
}

async function handleUpdate(row: DictType) {
  try {
    resetForm()
    const res = await getType(row.dictId)
    Object.assign(form, res)
    dialogTitle.value = '修改字典类型'
    showDialog.value = true
  } catch (error) {
    console.error('获取数据失败:', error)
  }
}

function handleDelete(row: DictType) {
  dictToDelete.value = row
  showDeleteDialog.value = true
}

function handleDictData(row: DictType) {
  router.push({
    path: '/system/dict/data',
    query: { dictType: row.dictType, dictName: row.dictName },
  })
}

async function confirmDelete() {
  if (!dictToDelete.value) return
  try {
    await delType([dictToDelete.value.dictId])
    toast({
      title: '删除成功',
      description: '字典类型已删除',
    })
    getList()
  } finally {
    showDeleteDialog.value = false
  }
}

async function submitForm() {
  if (!form.dictName || !form.dictType) {
    toast({
      title: '验证失败',
      description: '字典名称和类型不能为空',
      variant: 'destructive',
    })
    return
  }

  try {
    if (form.dictId) {
      await updateType(form)
      toast({
        title: '修改成功',
        description: '字典类型已更新',
      })
    } else {
      await addType(form)
      toast({
        title: '添加成功',
        description: '字典类型已添加',
      })
    }
    showDialog.value = false
    getList()
  } catch (error) {
    console.error('提交失败:', error)
  }
}

function resetForm() {
  form.dictId = undefined
  form.dictName = ''
  form.dictType = ''
  form.status = '0'
  form.remark = ''
}

// 状态切换
async function handleStatusChange(dictId: string, status: string) {
  await changeDictTypeStatus(dictId, status)
  const dict = typeList.value.find((d) => d.dictId === dictId)
  if (dict) dict.status = status
}

// 批量选择
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
    selectedIds.value = typeList.value.map((d) => d.dictId)
  } else if (selectedIds.value.length === typeList.value.length) {
    selectedIds.value = []
  }
})

// 监听选中项变化，更新全选状态
watch(
  selectedIds,
  (newVal) => {
    selectAll.value = typeList.value.length > 0 && newVal.length === typeList.value.length
  },
  { deep: true },
)

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
    await delType(selectedIds.value)
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    showBatchDeleteDialog.value = false
  } catch {
    // 忽略错误
  }
}

// 批量状态操作
async function handleBatchStatus(status: string) {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要操作的数据', variant: 'destructive' })
    return
  }
  try {
    await batchChangeDictTypeStatus(selectedIds.value, status)
    toast({ title: status === '0' ? '批量启用成功' : '批量停用成功' })
    getList()
  } catch (e: any) {
    toast({ title: '操作失败', description: e.message, variant: 'destructive' })
  }
}

onMounted(() => {
  getList()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">字典管理</h2>
        <p class="text-muted-foreground">管理系统字典数据，用于界面下拉框选项等</p>
      </div>
      <div class="flex items-center gap-2">
        <Button @click="handleAdd">
          <Plus class="mr-2 h-4 w-4" />
          新增字典
        </Button>
      </div>
    </div>

    <!-- Filters -->
    <div
      class="flex flex-col sm:flex-row flex-wrap gap-3 sm:gap-4 sm:items-center bg-background/95 p-4 border rounded-lg backdrop-blur supports-[backdrop-filter]:bg-background/60"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">字典名称</span>
        <Input
          v-model="queryParams.dictName"
          placeholder="请输入字典名称"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">字典类型</span>
        <Input
          v-model="queryParams.dictType"
          placeholder="请输入字典类型"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">状态</span>
        <Select v-model="queryParams.status" @update:model-value="handleQuery">
          <SelectTrigger class="w-[120px]">
            <SelectValue placeholder="全部" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">全部</SelectItem>
            <SelectItem value="0">正常</SelectItem>
            <SelectItem value="1">停用</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex gap-2 ml-auto">
        <Button @click="handleQuery">
          <Search class="w-4 h-4 mr-2" />
          搜索
        </Button>
        <Button variant="outline" @click="resetQuery">
          <RefreshCw class="w-4 h-4 mr-2" />
          重置
        </Button>
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

    <!-- Table -->
    <div class="border rounded-md bg-card overflow-x-auto">
      <!-- 骨架屏 -->
      <TableSkeleton v-if="loading" :columns="8" :rows="10" />

      <!-- 空状态 -->
      <EmptyState
        v-else-if="typeList.length === 0"
        title="暂无字典数据"
        description="点击新增字典按钮添加第一个字典类型"
        action-text="新增字典"
        @action="handleAdd"
      />

      <!-- 数据表格 -->
      <Table v-else>
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox v-model="selectAll" />
            </TableHead>
            <TableHead class="w-[100px]">字典编号</TableHead>
            <TableHead>字典名称</TableHead>
            <TableHead>字典类型</TableHead>
            <TableHead>状态</TableHead>
            <TableHead>备注</TableHead>
            <TableHead>创建时间</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="item in typeList" :key="item.dictId">
            <TableCell>
              <Checkbox
                :model-value="selectedIds.includes(item.dictId)"
                @update:model-value="() => handleSelectOne(item.dictId)"
              />
            </TableCell>
            <TableCell>{{ item.dictId }}</TableCell>
            <TableCell>{{ item.dictName }}</TableCell>
            <TableCell>
              <Badge variant="outline">{{ item.dictType }}</Badge>
            </TableCell>
            <TableCell>
              <StatusSwitch
                :model-value="item.status"
                :id="item.dictId"
                :name="item.dictName"
                @change="handleStatusChange"
              />
            </TableCell>
            <TableCell class="text-muted-foreground">{{ item.remark }}</TableCell>
            <TableCell>{{ formatDate(item.createTime) }}</TableCell>
            <TableCell class="text-right space-x-2">
              <Button variant="ghost" size="icon" @click="handleDictData(item)" title="字典数据">
                <List class="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="icon" @click="handleUpdate(item)">
                <Edit class="w-4 h-4" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                class="text-destructive"
                @click="handleDelete(item)"
              >
                <Trash2 class="w-4 h-4" />
              </Button>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>

    <!-- Pagination -->
    <TablePagination
      v-model:page-num="queryParams.pageNum"
      v-model:page-size="queryParams.pageSize"
      :total="total"
      @change="getList"
    />

    <!-- Add/Edit Dialog -->
    <Dialog v-model:open="showDialog">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{{ dialogTitle }}</DialogTitle>
          <DialogDescription> 请填写字典类型信息 </DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-4 items-center gap-4">
            <span class="text-right text-sm">字典名称</span>
            <Input v-model="form.dictName" class="col-span-3" />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <span class="text-right text-sm">字典类型</span>
            <Input v-model="form.dictType" class="col-span-3" />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <span class="text-right text-sm">状态</span>
            <Select v-model="form.status">
              <SelectTrigger class="col-span-3">
                <SelectValue placeholder="请选择状态" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="0">正常</SelectItem>
                <SelectItem value="1">停用</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <span class="text-right text-sm">备注</span>
            <Input v-model="form.remark" class="col-span-3" />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showDialog = false">取消</Button>
          <Button @click="submitForm">确定</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Delete Confirmation Dialog -->
    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`您确定要删除字典类型 &quot;${dictToDelete?.dictName}&quot; 吗？此操作无法撤销。`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <!-- Batch Delete Confirmation Dialog -->
    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 个字典类型吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
