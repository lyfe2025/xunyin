<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import { Card, CardContent } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import { useToast } from '@/components/ui/toast/use-toast'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import {
  Plus,
  Search,
  RefreshCw,
  Pencil,
  Trash2,
  Apple,
  Smartphone,
  AlertTriangle,
  Upload,
  FileArchive,
  X,
} from 'lucide-vue-next'
import {
  listVersions,
  createVersion,
  updateVersion,
  deleteVersion,
  batchDeleteVersions,
  updateVersionStatus,
  type AppVersion,
  type CreateVersionParams,
} from '@/api/app-config/version'
import { uploadApk } from '@/api/upload'

const { toast } = useToast()

// 状态
const loading = ref(false)
const list = ref<AppVersion[]>([])
const total = ref(0)
const selectedIds = ref<string[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('发布新版本')
const submitLoading = ref(false)

// APK 上传状态
const uploading = ref(false)
const uploadProgress = ref(0)
const apkFileInput = ref<HTMLInputElement | null>(null)

// 查询参数
const queryParams = reactive({
  platform: '__all__',
  status: '__all__',
  pageNum: 1,
  pageSize: 10,
})

// 表单数据
const form = reactive<CreateVersionParams>({
  versionCode: '',
  versionName: '',
  platform: 'android',
  downloadUrl: '',
  fileSize: '',
  updateContent: '',
  isForceUpdate: false,
  minSupportVersion: '',
  publishTime: '',
  status: '0',
})

const editingId = ref<string | null>(null)

// 删除确认对话框
const showDeleteDialog = ref(false)
const deleteTarget = ref<AppVersion | null>(null)
const showBatchDeleteDialog = ref(false)

// 获取列表
async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      platform: queryParams.platform === '__all__' ? '' : queryParams.platform,
      status: queryParams.status === '__all__' ? '' : queryParams.status,
    }
    const res = await listVersions(params)
    list.value = res.data.list
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

// 搜索
function handleSearch() {
  queryParams.pageNum = 1
  getList()
}

// 重置
function handleReset() {
  queryParams.platform = '__all__'
  queryParams.status = '__all__'
  queryParams.pageNum = 1
  getList()
}

// 新增
function handleAdd() {
  editingId.value = null
  dialogTitle.value = '发布新版本'
  resetForm()
  dialogVisible.value = true
}

// 编辑
function handleEdit(row: AppVersion) {
  editingId.value = row.id
  dialogTitle.value = '编辑版本'
  Object.assign(form, {
    versionCode: row.versionCode,
    versionName: row.versionName,
    platform: row.platform,
    downloadUrl: row.downloadUrl || '',
    fileSize: row.fileSize || '',
    updateContent: row.updateContent || '',
    isForceUpdate: row.isForceUpdate,
    minSupportVersion: row.minSupportVersion || '',
    publishTime: row.publishTime ? row.publishTime.slice(0, 16) : '',
    status: row.status,
  })
  dialogVisible.value = true
}

// 重置表单
function resetForm() {
  Object.assign(form, {
    versionCode: '',
    versionName: '',
    platform: 'android',
    downloadUrl: '',
    fileSize: '',
    updateContent: '',
    isForceUpdate: false,
    minSupportVersion: '',
    publishTime: '',
    status: '0',
  })
}

// 提交
async function handleSubmit() {
  if (!form.versionCode || !form.versionName) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }

  // 验证版本号格式
  if (!/^\d+\.\d+\.\d+$/.test(form.versionCode)) {
    toast({ title: '版本号格式应为 x.x.x', variant: 'destructive' })
    return
  }

  submitLoading.value = true
  try {
    const data = { ...form }
    if (!data.publishTime) delete data.publishTime

    if (editingId.value) {
      await updateVersion(editingId.value, data)
      toast({ title: '更新成功' })
    } else {
      await createVersion(data)
      toast({ title: '发布成功' })
    }
    dialogVisible.value = false
    getList()
  } finally {
    submitLoading.value = false
  }
}

// 删除
function handleDelete(row: AppVersion) {
  deleteTarget.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  await deleteVersion(deleteTarget.value.id)
  toast({ title: '删除成功' })
  showDeleteDialog.value = false
  getList()
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
  await batchDeleteVersions(selectedIds.value)
  toast({ title: '删除成功' })
  selectedIds.value = []
  showBatchDeleteDialog.value = false
  getList()
}

// 状态切换
async function handleStatusChange(row: AppVersion) {
  const newStatus = row.status === '0' ? '1' : '0'
  await updateVersionStatus(row.id, newStatus)
  row.status = newStatus
  toast({ title: '状态更新成功' })
}

// APK 上传
function triggerApkUpload() {
  apkFileInput.value?.click()
}

async function handleApkUpload(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  // 验证文件类型
  if (!file.name.toLowerCase().endsWith('.apk')) {
    toast({ title: '请选择 APK 文件', variant: 'destructive' })
    input.value = ''
    return
  }

  // 验证文件大小 (200MB)
  if (file.size > 200 * 1024 * 1024) {
    toast({ title: 'APK 文件不能超过 200MB', variant: 'destructive' })
    input.value = ''
    return
  }

  uploading.value = true
  uploadProgress.value = 0

  try {
    const result = await uploadApk(file, (percent) => {
      uploadProgress.value = percent
    })
    form.downloadUrl = result.url
    form.fileSize = result.fileSize || `${(file.size / (1024 * 1024)).toFixed(2)} MB`
    toast({ title: 'APK 上传成功' })
  } catch (error: any) {
    toast({ title: error.message || '上传失败', variant: 'destructive' })
  } finally {
    uploading.value = false
    uploadProgress.value = 0
    input.value = ''
  }
}

function clearApkUrl() {
  form.downloadUrl = ''
  form.fileSize = ''
}

// 选择
function handleSelectionChange(id: string, checked: boolean) {
  if (checked) {
    selectedIds.value.push(id)
  } else {
    selectedIds.value = selectedIds.value.filter((i) => i !== id)
  }
}

// 全选
function handleSelectAll(checked: boolean) {
  if (checked) {
    selectedIds.value = list.value.map((item) => item.id)
  } else {
    selectedIds.value = []
  }
}

const isAllSelected = computed(
  () => list.value.length > 0 && selectedIds.value.length === list.value.length,
)

onMounted(() => {
  getList()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4">
    <!-- 页面标题 -->
    <div>
      <h2 class="text-xl sm:text-2xl font-bold tracking-tight">版本管理</h2>
      <p class="text-muted-foreground">管理 APP 版本发布和更新策略</p>
    </div>

    <!-- 搜索栏 -->
    <Card>
      <CardContent class="pt-6">
        <div class="flex flex-wrap gap-4 items-end">
          <div class="grid gap-2">
            <Label>平台</Label>
            <Select v-model="queryParams.platform">
              <SelectTrigger class="w-32">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="ios">iOS</SelectItem>
                <SelectItem value="android">Android</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="grid gap-2">
            <Label>状态</Label>
            <Select v-model="queryParams.status">
              <SelectTrigger class="w-32">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="0">启用</SelectItem>
                <SelectItem value="1">停用</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="flex gap-2">
            <Button @click="handleSearch"><Search class="h-4 w-4 mr-2" />搜索</Button>
            <Button variant="outline" @click="handleReset"
              ><RefreshCw class="h-4 w-4 mr-2" />重置</Button
            >
          </div>
        </div>
      </CardContent>
    </Card>

    <!-- 操作栏 -->
    <div class="flex justify-between items-center">
      <div class="flex gap-2">
        <Button @click="handleAdd"><Plus class="h-4 w-4 mr-2" />发布新版本</Button>
        <Button
          variant="destructive"
          :disabled="selectedIds.length === 0"
          @click="handleBatchDelete"
        >
          <Trash2 class="h-4 w-4 mr-2" />批量删除
        </Button>
      </div>
      <span class="text-sm text-muted-foreground">共 {{ total }} 条</span>
    </div>

    <!-- 数据表格 -->
    <Card>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead class="w-12">
              <Checkbox :checked="isAllSelected" @update:checked="handleSelectAll" />
            </TableHead>
            <TableHead>版本号</TableHead>
            <TableHead>版本名称</TableHead>
            <TableHead>平台</TableHead>
            <TableHead>强制更新</TableHead>
            <TableHead>文件大小</TableHead>
            <TableHead>发布时间</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="row in list" :key="row.id">
            <TableCell>
              <Checkbox
                :checked="selectedIds.includes(row.id)"
                @update:checked="(checked) => handleSelectionChange(row.id, checked as boolean)"
              />
            </TableCell>
            <TableCell class="font-mono">{{ row.versionCode }}</TableCell>
            <TableCell>{{ row.versionName }}</TableCell>
            <TableCell>
              <Badge variant="outline" class="gap-1">
                <Apple v-if="row.platform === 'ios'" class="h-3 w-3" />
                <Smartphone v-else class="h-3 w-3" />
                {{ row.platform === 'ios' ? 'iOS' : 'Android' }}
              </Badge>
            </TableCell>
            <TableCell>
              <Badge v-if="row.isForceUpdate" variant="destructive" class="gap-1">
                <AlertTriangle class="h-3 w-3" />
                强制
              </Badge>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell>{{ row.fileSize || '-' }}</TableCell>
            <TableCell>{{ row.publishTime?.slice(0, 10) || '-' }}</TableCell>
            <TableCell>
              <Switch :checked="row.status === '0'" @update:checked="handleStatusChange(row)" />
            </TableCell>
            <TableCell class="text-right">
              <Button variant="ghost" size="icon" @click="handleEdit(row)">
                <Pencil class="h-4 w-4" />
              </Button>
              <Button variant="ghost" size="icon" @click="handleDelete(row)">
                <Trash2 class="h-4 w-4 text-destructive" />
              </Button>
            </TableCell>
          </TableRow>
          <TableRow v-if="list.length === 0">
            <TableCell colspan="9" class="text-center py-8 text-muted-foreground">
              暂无数据
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </Card>

    <!-- 新增/编辑弹窗 -->
    <Dialog v-model:open="dialogVisible">
      <DialogContent class="max-w-lg">
        <DialogHeader>
          <DialogTitle>{{ dialogTitle }}</DialogTitle>
        </DialogHeader>

        <div class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>版本号 <span class="text-destructive">*</span></Label>
              <Input v-model="form.versionCode" placeholder="1.0.0" />
              <p class="text-xs text-muted-foreground">格式：x.x.x</p>
            </div>
            <div class="grid gap-2">
              <Label>版本名称 <span class="text-destructive">*</span></Label>
              <Input v-model="form.versionName" placeholder="v1.0.0 正式版" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>平台</Label>
              <Select v-model="form.platform">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ios">iOS</SelectItem>
                  <SelectItem value="android">Android</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="grid gap-2">
              <Label>文件大小</Label>
              <Input v-model="form.fileSize" placeholder="上传后自动填充" readonly />
            </div>
          </div>

          <!-- APK 上传区域 (仅 Android) -->
          <div v-if="form.platform === 'android'" class="grid gap-2">
            <Label>APK 文件</Label>
            <input
              ref="apkFileInput"
              type="file"
              accept=".apk"
              class="hidden"
              @change="handleApkUpload"
            />
            <div
              v-if="!form.downloadUrl"
              class="border-2 border-dashed rounded-lg p-6 text-center cursor-pointer hover:border-primary transition-colors"
              @click="triggerApkUpload"
            >
              <div v-if="uploading" class="space-y-2">
                <FileArchive class="h-8 w-8 mx-auto text-muted-foreground animate-pulse" />
                <p class="text-sm text-muted-foreground">上传中 {{ uploadProgress }}%</p>
                <Progress :model-value="uploadProgress" class="h-2" />
              </div>
              <div v-else>
                <Upload class="h-8 w-8 mx-auto text-muted-foreground" />
                <p class="mt-2 text-sm text-muted-foreground">点击上传 APK 文件</p>
                <p class="text-xs text-muted-foreground">最大 200MB</p>
              </div>
            </div>
            <div v-else class="flex items-center justify-between p-3 border rounded-lg bg-muted/50">
              <div class="flex items-center gap-2">
                <FileArchive class="h-5 w-5 text-green-600" />
                <span class="text-sm truncate max-w-[280px]">{{ form.downloadUrl }}</span>
              </div>
              <Button variant="ghost" size="icon" @click="clearApkUrl">
                <X class="h-4 w-4" />
              </Button>
            </div>
          </div>

          <!-- iOS 下载地址 -->
          <div v-else class="grid gap-2">
            <Label>下载地址</Label>
            <Input v-model="form.downloadUrl" placeholder="App Store 链接" />
          </div>

          <div class="grid gap-2">
            <Label>更新内容</Label>
            <Textarea v-model="form.updateContent" placeholder="本次更新内容..." rows="4" />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>最低支持版本</Label>
              <Input v-model="form.minSupportVersion" placeholder="1.0.0" />
              <p class="text-xs text-muted-foreground">低于此版本需要更新</p>
            </div>
            <div class="grid gap-2">
              <Label>发布时间</Label>
              <Input v-model="form.publishTime" type="datetime-local" />
            </div>
          </div>

          <div class="flex items-center justify-between p-4 border rounded-lg">
            <div>
              <Label>强制更新</Label>
              <p class="text-sm text-muted-foreground">开启后用户必须更新才能使用</p>
            </div>
            <Switch v-model:checked="form.isForceUpdate" />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" @click="dialogVisible = false">取消</Button>
          <Button @click="handleSubmit" :disabled="submitLoading">
            {{ submitLoading ? '保存中...' : '保存' }}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`确定要删除版本「${deleteTarget?.versionName}」吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 个版本吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
