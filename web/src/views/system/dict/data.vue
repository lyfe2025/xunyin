<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Search, Plus, Edit, Trash2, RefreshCw, ArrowLeft } from 'lucide-vue-next'
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
  listData,
  getData,
  delData,
  addData,
  updateData,
  changeDictDataStatus,
  type DictData,
  type DictDataForm,
} from '@/api/system/dict'

const route = useRoute()
const router = useRouter()
const { toast } = useToast()

const dictType = computed(() => (route.query.dictType as string) || '')
const dictName = computed(() => (route.query.dictName as string) || '字典数据')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  dictType: '',
  dictLabel: '',
  status: undefined as string | undefined,
})

const loading = ref(true)
const total = ref(0)
const dataList = ref<DictData[]>([])
const showDialog = ref(false)
const showDeleteDialog = ref(false)
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

async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      status: queryParams.status === 'all' ? undefined : queryParams.status,
    }
    params.dictType = dictType.value
    const response = await listData(params)
    dataList.value = response.rows
    total.value = response.total
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
  form.dictType = dictType.value
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

// 状态切换
async function handleStatusChange(dictCode: string, status: string) {
  await changeDictDataStatus(dictCode, status)
  const data = dataList.value.find((d) => d.dictCode === dictCode)
  if (data) data.status = status
}

function goBack() {
  router.push('/system/dict')
}

onMounted(() => {
  if (dictType.value) {
    getList()
  }
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div class="flex items-center gap-3">
        <Button variant="ghost" size="icon" @click="goBack">
          <ArrowLeft class="h-4 w-4" />
        </Button>
        <div>
          <h2 class="text-xl sm:text-2xl font-bold tracking-tight">{{ dictName }}</h2>
          <p class="text-muted-foreground">
            字典类型：<Badge variant="outline">{{ dictType }}</Badge>
          </p>
        </div>
      </div>
      <Button @click="handleAdd">
        <Plus class="mr-2 h-4 w-4" />
        新增数据
      </Button>
    </div>

    <!-- Filters -->
    <div
      class="flex flex-col sm:flex-row flex-wrap gap-3 sm:gap-4 sm:items-center bg-background/95 p-4 border rounded-lg backdrop-blur supports-[backdrop-filter]:bg-background/60"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">字典标签</span>
        <Input
          v-model="queryParams.dictLabel"
          placeholder="请输入字典标签"
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

    <!-- Table -->
    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="7" :rows="10" />

      <EmptyState
        v-else-if="dataList.length === 0"
        title="暂无字典数据"
        description="点击新增数据按钮添加第一条字典数据"
        action-text="新增数据"
        @action="handleAdd"
      />

      <Table v-else>
        <TableHeader>
          <TableRow>
            <TableHead class="w-[80px]">字典编码</TableHead>
            <TableHead>字典标签</TableHead>
            <TableHead>字典键值</TableHead>
            <TableHead class="w-[80px]">排序</TableHead>
            <TableHead>状态</TableHead>
            <TableHead>备注</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="item in dataList" :key="item.dictCode">
            <TableCell>{{ item.dictCode }}</TableCell>
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
            <TableCell class="text-muted-foreground">{{ item.remark }}</TableCell>
            <TableCell class="text-right space-x-2">
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
      <DialogContent class="sm:max-w-[500px]">
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

    <!-- Delete Confirmation Dialog -->
    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`您确定要删除字典数据 &quot;${dataToDelete?.dictLabel}&quot; 吗？此操作无法撤销。`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />
  </div>
</template>
