<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Plus, Edit, Trash2, RefreshCw, BookOpen } from 'lucide-vue-next'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
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
import { listType, getType, delType, addType, updateType, type DictType } from '@/api/system/dict'

const { toast } = useToast()

// Query parameters
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  dictName: '',
  dictType: '',
  status: undefined
})

const loading = ref(true)
const total = ref(0)
const typeList = ref<DictType[]>([])
const showDialog = ref(false)
const showDeleteDialog = ref(false)
const dictToDelete = ref<DictType | null>(null)
const dialogTitle = ref('')
const form = reactive<Partial<DictType>>({
  dictId: undefined,
  dictName: '',
  dictType: '',
  status: '0',
  remark: ''
})

// Fetch data
async function getList() {
  loading.value = true
  try {
    const response = await listType(queryParams)
    typeList.value = response.rows
    total.value = response.total
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

async function confirmDelete() {
  if (!dictToDelete.value) return
  try {
    await delType([dictToDelete.value.dictId])
    toast({
      title: "删除成功",
      description: "字典类型已删除",
    })
    getList()
  } finally {
    showDeleteDialog.value = false
  }
}

async function submitForm() {
  if (!form.dictName || !form.dictType) {
    toast({
      title: "验证失败",
      description: "字典名称和类型不能为空",
      variant: "destructive"
    })
    return
  }
  
  try {
    if (form.dictId) {
      await updateType(form)
      toast({
        title: "修改成功",
        description: "字典类型已更新",
      })
    } else {
      await addType(form)
      toast({
        title: "添加成功",
        description: "字典类型已添加",
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
        <p class="text-muted-foreground">
          管理系统字典数据，用于界面下拉框选项等
        </p>
      </div>
      <div class="flex items-center gap-2">
        <Button @click="handleAdd">
          <Plus class="mr-2 h-4 w-4" />
          新增字典
        </Button>
      </div>
    </div>

    <!-- Filters -->
    <div class="flex flex-col sm:flex-row flex-wrap gap-3 sm:gap-4 sm:items-center bg-background/95 p-4 border rounded-lg backdrop-blur supports-[backdrop-filter]:bg-background/60">
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
        <Select v-model="queryParams.status">
          <SelectTrigger class="w-[120px]">
            <SelectValue placeholder="请选择" />
          </SelectTrigger>
          <SelectContent>
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
      <!-- 骨架屏 -->
      <TableSkeleton v-if="loading" :columns="6" :rows="10" />
      
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
            <TableCell>{{ item.dictId }}</TableCell>
            <TableCell>{{ item.dictName }}</TableCell>
            <TableCell>
              <Badge variant="outline">{{ item.dictType }}</Badge>
            </TableCell>
            <TableCell>
              <Badge :variant="item.status === '0' ? 'default' : 'destructive'">
                {{ item.status === '0' ? '正常' : '停用' }}
              </Badge>
            </TableCell>
            <TableCell class="text-muted-foreground">{{ item.remark }}</TableCell>
            <TableCell>{{ formatDate(item.createTime) }}</TableCell>
            <TableCell class="text-right space-x-2">
              <Button variant="ghost" size="icon" @click="handleUpdate(item)">
                <Edit class="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="icon" class="text-destructive" @click="handleDelete(item)">
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
          <DialogDescription>
            请填写字典类型信息
          </DialogDescription>
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
  </div>
</template>
