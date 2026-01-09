<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { Search, Plus, Edit, Trash2, RefreshCw } from 'lucide-vue-next'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
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
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Badge } from '@/components/ui/badge'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  listData,
  getData,
  delData,
  addData,
  updateData,
  changeDictDataStatus,
  batchChangeDictDataStatus,
  type DictData,
  type DictDataForm,
} from '@/api/system/dict'

const props = defineProps<{
  dictType: string
  dictName: string
}>()

const open = defineModel<boolean>('open', { default: false })

const { toast } = useToast()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  dictType: '',
  dictLabel: '',
  status: undefined as string | undefined,
})

const loading = ref(false)
const total = ref(0)
const dataList = ref<DictData[]>([])
const showDialog = ref(false)
const showDeleteDialog = ref(false)
const showBatchDeleteDialog = ref(false)
const dataToDelete = ref<DictData | null>(null)
const dialogTitle = ref('')
const form = reactive<DictDataForm>({
  dictCode: undefined,
  dictSort: 0,
  dictLabel: '',
  dictValue: '',
  dictType: '',
  cssClass: '',
  listClass: 'default',
  isDefault: 'N',
  status: '0',
  remark: '',
})

const selectedIds = ref<string[]>([])
const selectAll = ref(false)

// 监听打开状态，加载数据
watch(
  () => open.value,
  (val) => {
    if (val && props.dictType) {
      queryParams.pageNum = 1
      queryParams.dictLabel = ''
      queryParams.status = undefined
      getList()
    }
  },
)

async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      dictType: props.dictType,
      status: queryParams.status === 'all' ? undefined : queryParams.status,
    }
    const response = await listData(params)
    dataList.value = response.rows
    total.value = response.total
    selectedIds.value = []
    selectAll.value = false
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.dictLabel = ''
  queryParams.status = undefined
  handleQuery()
}

function handleAdd() {
  resetForm()
  form.dictType = props.dictType
  dialogTitle.value = '添加字典数据'
  showDialog.value = true
}

async function handleUpdate(row: DictData) {
  try {
    resetForm()
    const res = await getData(row.dictCode)
    Object.assign(form, res)
    dialogTitle.value = '修改字典数据'
    showDialog.value = true
  } catch (error) {
    console.error('获取数据失败:', error)
  }
}

function handleDelete(row: DictData) {
  dataToDelete.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!dataToDelete.value) return
  try {
    await delData([dataToDelete.value.dictCode])
    toast({ title: '删除成功', description: '字典数据已删除' })
    getList()
  } finally {
    showDeleteDialog.value = false
  }
}

async function submitForm() {
  if (!form.dictLabel || !form.dictValue) {
    toast({
      title: '验证失败',
      description: '字典标签和键值不能为空',
      variant: 'destructive',
    })
    return
  }

  try {
    if (form.dictCode) {
      await updateData(form)
      toast({ title: '修改成功', description: '字典数据已更新' })
    } else {
      await addData(form)
      toast({ title: '添加成功', description: '字典数据已添加' })
    }
    showDialog.value = false
    getList()
  } catch (error) {
    console.error('提交失败:', error)
  }
}

function resetForm() {
  form.dictCode = undefined
  form.dictSort = 0
  form.dictLabel = ''
  form.dictValue = ''
  form.dictType = ''
  form.cssClass = ''
  form.listClass = 'default'
  form.isDefault = 'N'
  form.status = '0'
  form.remark = ''
}

async function handleStatusChange(dictCode: string, status: string) {
  await changeDictDataStatus(dictCode, status)
  const data = dataList.value.find((d) => d.dictCode === dictCode)
  if (data) data.status = status as '0' | '1'
}

function handleSelectOne(id: string) {
  const index = selectedIds.value.indexOf(id)
  if (index > -1) {
    selectedIds.value.splice(index, 1)
  } else {
    selectedIds.value.push(id)
  }
}

watch(selectAll, (newVal) => {
  if (newVal) {
    selectedIds.value = dataList.value.map((d) => d.dictCode)
  } else if (selectedIds.value.length === dataList.value.length) {
    selectedIds.value = []
  }
})

watch(
  selectedIds,
  (newVal) => {
    selectAll.value = dataList.value.length > 0 && newVal.length === dataList.value.length
  },
  { deep: true },
)

function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要删除的数据', variant: 'destructive' })
    return
  }
  showBatchDeleteDialog.value = true
}

async function confirmBatchDelete() {
  try {
    await delData(selectedIds.value)
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    showBatchDeleteDialog.value = false
  } catch {
    // 忽略错误
  }
}

async function handleBatchStatus(status: string) {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要操作的数据', variant: 'destructive' })
    return
  }
  try {
    await batchChangeDictDataStatus(selectedIds.value, status)
    toast({ title: status === '0' ? '批量启用成功' : '批量停用成功' })
    getList()
  } catch (e: unknown) {
    const err = e as Error
    toast({ title: '操作失败', description: err.message, variant: 'destructive' })
  }
}
</script>

<template>
  <Sheet v-model:open="open">
    <SheetContent side="right" class="w-full sm:max-w-2xl overflow-y-auto">
      <SheetHeader>
        <SheetTitle>{{ dictName }}</SheetTitle>
        <SheetDescription>
          字典类型：<Badge variant="outline">{{ dictType }}</Badge>
        </SheetDescription>
      </SheetHeader>

      <div class="mt-6 space-y-4">
        <!-- Filters -->
        <div class="flex flex-wrap gap-3 items-center">
          <Input
            v-model="queryParams.dictLabel"
            placeholder="字典标签"
            class="w-[120px]"
            @keyup.enter="handleQuery"
          />
          <Select v-model="queryParams.status" @update:model-value="handleQuery">
            <SelectTrigger class="w-[100px]">
              <SelectValue placeholder="状态" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">全部</SelectItem>
              <SelectItem value="0">正常</SelectItem>
              <SelectItem value="1">停用</SelectItem>
            </SelectContent>
          </Select>
          <Button size="sm" @click="handleQuery">
            <Search class="w-4 h-4" />
          </Button>
          <Button size="sm" variant="outline" @click="resetQuery">
            <RefreshCw class="w-4 h-4" />
          </Button>
          <Button size="sm" class="ml-auto" @click="handleAdd">
            <Plus class="w-4 h-4 mr-1" />
            新增
          </Button>
        </div>

        <!-- 批量操作栏 -->
        <div
          v-if="selectedIds.length > 0"
          class="flex items-center gap-2 p-2 bg-muted/50 border rounded-lg text-sm"
        >
          <span>已选 {{ selectedIds.length }} 项</span>
          <Button size="sm" variant="outline" @click="handleBatchStatus('0')">启用</Button>
          <Button size="sm" variant="outline" @click="handleBatchStatus('1')">停用</Button>
          <Button size="sm" variant="destructive" @click="handleBatchDelete">删除</Button>
        </div>

        <!-- Table -->
        <div class="border rounded-md bg-card">
          <TableSkeleton v-if="loading" :columns="6" :rows="5" />
          <EmptyState
            v-else-if="dataList.length === 0"
            title="暂无字典数据"
            description="点击新增按钮添加"
            action-text="新增数据"
            @action="handleAdd"
          />
          <Table v-else>
            <TableHeader>
              <TableRow>
                <TableHead class="w-[40px]">
                  <Checkbox v-model="selectAll" />
                </TableHead>
                <TableHead>标签</TableHead>
                <TableHead>键值</TableHead>
                <TableHead class="w-[60px]">排序</TableHead>
                <TableHead>状态</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="item in dataList" :key="item.dictCode">
                <TableCell>
                  <Checkbox
                    :model-value="selectedIds.includes(item.dictCode)"
                    @update:model-value="() => handleSelectOne(item.dictCode)"
                  />
                </TableCell>
                <TableCell>
                  <Badge :class="item.listClass ? `badge-${item.listClass}` : ''">
                    {{ item.dictLabel }}
                  </Badge>
                </TableCell>
                <TableCell>{{ item.dictValue }}</TableCell>
                <TableCell>{{ item.dictSort }}</TableCell>
                <TableCell>
                  <StatusSwitch
                    :model-value="item.status"
                    :id="item.dictCode"
                    :name="item.dictLabel"
                    @change="handleStatusChange"
                  />
                </TableCell>
                <TableCell class="text-right space-x-1">
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleUpdate(item)">
                    <Edit class="w-4 h-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    class="h-8 w-8 text-destructive"
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
          :page-sizes="[10, 20, 50]"
          @change="getList"
        />
      </div>

      <!-- Add/Edit Dialog -->
      <Dialog v-model:open="showDialog">
        <DialogContent class="sm:max-w-[450px]">
          <DialogHeader>
            <DialogTitle>{{ dialogTitle }}</DialogTitle>
            <DialogDescription>请填写字典数据信息</DialogDescription>
          </DialogHeader>
          <div class="grid gap-4 py-4">
            <div class="grid grid-cols-4 items-center gap-4">
              <span class="text-right text-sm">字典类型</span>
              <Input v-model="form.dictType" class="col-span-3" disabled />
            </div>
            <div class="grid grid-cols-4 items-center gap-4">
              <span class="text-right text-sm">字典标签</span>
              <Input v-model="form.dictLabel" class="col-span-3" placeholder="显示的文本" />
            </div>
            <div class="grid grid-cols-4 items-center gap-4">
              <span class="text-right text-sm">字典键值</span>
              <Input v-model="form.dictValue" class="col-span-3" placeholder="存储的值" />
            </div>
            <div class="grid grid-cols-4 items-center gap-4">
              <span class="text-right text-sm">显示排序</span>
              <Input v-model.number="form.dictSort" type="number" class="col-span-3" />
            </div>
            <div class="grid grid-cols-4 items-center gap-4">
              <span class="text-right text-sm">回显样式</span>
              <Select v-model="form.listClass">
                <SelectTrigger class="col-span-3">
                  <SelectValue placeholder="请选择" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="default">默认</SelectItem>
                  <SelectItem value="primary">主要</SelectItem>
                  <SelectItem value="success">成功</SelectItem>
                  <SelectItem value="warning">警告</SelectItem>
                  <SelectItem value="danger">危险</SelectItem>
                </SelectContent>
              </Select>
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

      <!-- Delete Confirmation -->
      <ConfirmDialog
        v-model:open="showDeleteDialog"
        title="确认删除"
        :description="`确定要删除 &quot;${dataToDelete?.dictLabel}&quot; 吗？`"
        confirm-text="删除"
        destructive
        @confirm="confirmDelete"
      />

      <!-- Batch Delete Confirmation -->
      <ConfirmDialog
        v-model:open="showBatchDeleteDialog"
        title="确认批量删除"
        :description="`确定要删除选中的 ${selectedIds.length} 条数据吗？`"
        confirm-text="删除"
        destructive
        @confirm="confirmBatchDelete"
      />
    </SheetContent>
  </Sheet>
</template>
