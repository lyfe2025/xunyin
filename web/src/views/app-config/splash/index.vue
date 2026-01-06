<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
import { useToast } from '@/components/ui/toast/use-toast'
import ImageUpload from '@/components/common/ImageUpload.vue'
import PhonePreview from '@/components/business/PhonePreview/index.vue'
import {
  Plus,
  Search,
  RefreshCw,
  Pencil,
  Trash2,
  Image as ImageIcon,
  Video,
  SkipForward,
} from 'lucide-vue-next'
import {
  listSplash,
  createSplash,
  updateSplash,
  deleteSplash,
  batchDeleteSplash,
  updateSplashStatus,
  type SplashConfig,
  type CreateSplashParams,
} from '@/api/app-config/splash'

const { toast } = useToast()

// 状态
const loading = ref(false)
const list = ref<SplashConfig[]>([])
const total = ref(0)
const selectedIds = ref<string[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增启动页')
const submitLoading = ref(false)

// 查询参数
const queryParams = reactive({
  title: '',
  platform: '__all__',
  status: '__all__',
  pageNum: 1,
  pageSize: 10,
})

// 表单数据
const form = reactive<CreateSplashParams>({
  title: '',
  type: 'image',
  mediaUrl: '',
  linkType: 'none',
  linkUrl: '',
  duration: 3,
  skipDelay: 0,
  platform: 'all',
  startTime: '',
  endTime: '',
  orderNum: 0,
  status: '0',
})

const editingId = ref<string | null>(null)

// 当前选中预览的项
const previewItem = ref<SplashConfig | null>(null)

// 预览数据
const previewData = computed(() => {
  if (dialogVisible.value) {
    return { type: form.type, mediaUrl: form.mediaUrl, duration: form.duration }
  }
  if (previewItem.value) {
    return {
      type: previewItem.value.type,
      mediaUrl: previewItem.value.mediaUrl,
      duration: previewItem.value.duration,
    }
  }
  return { type: 'image', mediaUrl: '', duration: 3 }
})

// 获取列表
async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      platform: queryParams.platform === '__all__' ? '' : queryParams.platform,
      status: queryParams.status === '__all__' ? '' : queryParams.status,
    }
    const res = (await listSplash(params)) as any
    // 兼容 res.data.list 或 res.list 两种格式
    const data = res.data || res
    list.value = data.list || []
    total.value = data.total || 0
    // 默认选中第一个
    if (list.value.length > 0 && !previewItem.value) {
      previewItem.value = list.value[0] ?? null
    }
  } finally {
    loading.value = false
  }
}

// 搜索
function handleSearch() {
  queryParams.pageNum = 1
  previewItem.value = null
  getList()
}

// 重置
function handleReset() {
  queryParams.title = ''
  queryParams.platform = '__all__'
  queryParams.status = '__all__'
  queryParams.pageNum = 1
  previewItem.value = null
  getList()
}

// 新增
function handleAdd() {
  editingId.value = null
  dialogTitle.value = '新增启动页'
  resetForm()
  dialogVisible.value = true
}

// 编辑
function handleEdit(row: SplashConfig) {
  editingId.value = row.id
  dialogTitle.value = '编辑启动页'
  Object.assign(form, {
    title: row.title || '',
    type: row.type,
    mediaUrl: row.mediaUrl,
    linkType: row.linkType || 'none',
    linkUrl: row.linkUrl || '',
    duration: row.duration,
    skipDelay: row.skipDelay,
    platform: row.platform,
    startTime: row.startTime ? row.startTime.slice(0, 16) : '',
    endTime: row.endTime ? row.endTime.slice(0, 16) : '',
    orderNum: row.orderNum,
    status: row.status,
  })
  dialogVisible.value = true
}

// 预览某一项
function handlePreview(row: SplashConfig) {
  previewItem.value = row
}

// 重置表单
function resetForm() {
  Object.assign(form, {
    title: '',
    type: 'image',
    mediaUrl: '',
    linkType: 'none',
    linkUrl: '',
    duration: 3,
    skipDelay: 0,
    platform: 'all',
    startTime: '',
    endTime: '',
    orderNum: 0,
    status: '0',
  })
}

// 提交
async function handleSubmit() {
  if (!form.mediaUrl) {
    toast({ title: '请上传媒体资源', variant: 'destructive' })
    return
  }
  submitLoading.value = true
  try {
    const data = { ...form }
    if (!data.startTime) delete data.startTime
    if (!data.endTime) delete data.endTime
    if (editingId.value) {
      await updateSplash(editingId.value, data)
      toast({ title: '更新成功' })
    } else {
      await createSplash(data)
      toast({ title: '创建成功' })
    }
    dialogVisible.value = false
    getList()
  } finally {
    submitLoading.value = false
  }
}

// 删除
async function handleDelete(row: SplashConfig) {
  if (!window.confirm('确定要删除该启动页配置吗？')) return
  await deleteSplash(row.id)
  toast({ title: '删除成功' })
  if (previewItem.value?.id === row.id) previewItem.value = null
  getList()
}

// 批量删除
async function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要删除的数据', variant: 'destructive' })
    return
  }
  if (!window.confirm(`确定要删除选中的 ${selectedIds.value.length} 条数据吗？`)) return
  await batchDeleteSplash(selectedIds.value)
  toast({ title: '删除成功' })
  if (previewItem.value && selectedIds.value.includes(previewItem.value.id)) {
    previewItem.value = null
  }
  selectedIds.value = []
  getList()
}

// 状态切换
async function handleStatusChange(row: SplashConfig) {
  const newStatus = row.status === '0' ? '1' : '0'
  await updateSplashStatus(row.id, newStatus)
  row.status = newStatus
  toast({ title: '状态更新成功' })
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
  selectedIds.value = checked ? list.value.map((item) => item.id) : []
}

const isAllSelected = computed(
  () => list.value.length > 0 && selectedIds.value.length === list.value.length,
)

onMounted(() => {
  getList()
})
</script>

<template>
  <div class="p-4 sm:p-6">
    <!-- 页面标题 -->
    <div class="flex items-center justify-between mb-4">
      <div>
        <h2 class="text-xl font-bold">启动页配置</h2>
        <p class="text-sm text-muted-foreground">管理 APP 启动时展示的开屏广告</p>
      </div>
      <div class="flex gap-2">
        <Button size="sm" @click="handleAdd"><Plus class="h-4 w-4 mr-1" />新增</Button>
      </div>
    </div>

    <!-- 主内容 -->
    <div class="flex gap-8 h-[calc(100vh-140px)]">
      <!-- 左侧：手机预览 -->
      <div class="shrink-0">
        <PhonePreview :scale="0.62" :show-device-switch="true">
          <template #default>
            <div class="w-full h-full bg-black relative flex flex-col">
              <!-- 媒体内容 -->
              <div class="flex-1 relative">
                <img
                  v-if="previewData.mediaUrl && previewData.type === 'image'"
                  :src="previewData.mediaUrl"
                  class="absolute inset-0 w-full h-full object-cover"
                  alt="预览"
                />
                <video
                  v-else-if="previewData.mediaUrl && previewData.type === 'video'"
                  :src="previewData.mediaUrl"
                  class="absolute inset-0 w-full h-full object-cover"
                  autoplay
                  muted
                  loop
                />
                <div
                  v-else
                  class="absolute inset-0 flex items-center justify-center text-white/40 text-sm"
                >
                  {{ list.length === 0 ? '暂无启动页' : '点击列表预览' }}
                </div>

                <!-- 跳过按钮 -->
                <div
                  v-if="previewData.mediaUrl"
                  class="absolute top-3 right-3 bg-black/50 backdrop-blur text-white text-xs px-3 py-1.5 rounded-full flex items-center gap-1"
                >
                  <SkipForward class="h-3 w-3" />
                  跳过 {{ previewData.duration }}s
                </div>
              </div>
            </div>
          </template>
        </PhonePreview>
        <p class="text-xs text-muted-foreground text-center mt-2">
          {{ previewItem?.title || '点击表格行切换预览' }}
        </p>
        <!-- 快速切换按钮 -->
        <div v-if="list.length > 0" class="flex justify-center gap-3 mt-2">
          <button
            v-for="(item, index) in list"
            :key="item.id"
            class="w-3 h-3 rounded-full transition-all border-2"
            :class="
              previewItem?.id === item.id
                ? 'bg-primary border-primary scale-110'
                : 'bg-transparent border-muted-foreground hover:border-primary hover:bg-primary/20'
            "
            :title="item.title || `启动页 ${index + 1}`"
            @click.stop="handlePreview(item)"
          />
        </div>
      </div>

      <!-- 右侧：列表 -->
      <div class="flex-1 min-w-0 overflow-y-auto pr-2 space-y-3">
        <!-- 搜索栏 -->
        <Card>
          <CardContent class="py-3">
            <div class="flex flex-wrap gap-3 items-end">
              <div class="space-y-1">
                <Label class="text-xs">标题</Label>
                <Input v-model="queryParams.title" placeholder="标题" class="w-36 h-8" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">平台</Label>
                <Select v-model="queryParams.platform">
                  <SelectTrigger class="w-24 h-8">
                    <SelectValue placeholder="全部" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="__all__">全部</SelectItem>
                    <SelectItem value="all">通用</SelectItem>
                    <SelectItem value="ios">iOS</SelectItem>
                    <SelectItem value="android">Android</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-1">
                <Label class="text-xs">状态</Label>
                <Select v-model="queryParams.status">
                  <SelectTrigger class="w-24 h-8">
                    <SelectValue placeholder="全部" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="__all__">全部</SelectItem>
                    <SelectItem value="0">启用</SelectItem>
                    <SelectItem value="1">停用</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <Button size="sm" @click="handleSearch"><Search class="h-4 w-4" /></Button>
              <Button variant="outline" size="sm" @click="handleReset">
                <RefreshCw class="h-4 w-4" />
              </Button>
              <Button
                variant="destructive"
                size="sm"
                :disabled="selectedIds.length === 0"
                @click="handleBatchDelete"
              >
                <Trash2 class="h-4 w-4" />
              </Button>
            </div>
          </CardContent>
        </Card>

        <!-- 数据表格 -->
        <Card>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead class="w-10">
                  <Checkbox :checked="isAllSelected" @update:checked="handleSelectAll" />
                </TableHead>
                <TableHead>标题</TableHead>
                <TableHead>类型</TableHead>
                <TableHead>平台</TableHead>
                <TableHead>时长</TableHead>
                <TableHead>状态</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="row in list"
                :key="row.id"
                :class="{ 'bg-muted/50': previewItem?.id === row.id }"
                class="cursor-pointer"
                @click="handlePreview(row)"
              >
                <TableCell @click.stop>
                  <Checkbox
                    :checked="selectedIds.includes(row.id)"
                    @update:checked="(c: boolean) => handleSelectionChange(row.id, c)"
                  />
                </TableCell>
                <TableCell class="font-medium">{{ row.title || '-' }}</TableCell>
                <TableCell>
                  <Badge variant="outline" class="text-xs">
                    <ImageIcon v-if="row.type === 'image'" class="h-3 w-3 mr-1" />
                    <Video v-else class="h-3 w-3 mr-1" />
                    {{ row.type === 'image' ? '图片' : '视频' }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary" class="text-xs">
                    {{
                      row.platform === 'all' ? '通用' : row.platform === 'ios' ? 'iOS' : 'Android'
                    }}
                  </Badge>
                </TableCell>
                <TableCell>{{ row.duration }}s</TableCell>
                <TableCell @click.stop>
                  <Switch :checked="row.status === '0'" @update:checked="handleStatusChange(row)" />
                </TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleEdit(row)">
                    <Pencil class="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleDelete(row)">
                    <Trash2 class="h-4 w-4 text-destructive" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="list.length === 0">
                <TableCell colspan="7" class="text-center py-6 text-muted-foreground">
                  暂无数据
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </Card>
      </div>
    </div>

    <!-- 新增/编辑弹窗 -->
    <Dialog v-model:open="dialogVisible">
      <DialogContent class="max-w-lg">
        <DialogHeader>
          <DialogTitle>{{ dialogTitle }}</DialogTitle>
        </DialogHeader>

        <div class="space-y-4">
          <div class="space-y-1">
            <Label class="text-xs">标题</Label>
            <Input v-model="form.title" placeholder="可选，用于后台识别" />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <Label class="text-xs">类型</Label>
              <Select v-model="form.type">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="image">图片</SelectItem>
                  <SelectItem value="video">视频</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-1">
              <Label class="text-xs">平台</Label>
              <Select v-model="form.platform">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">通用</SelectItem>
                  <SelectItem value="ios">仅 iOS</SelectItem>
                  <SelectItem value="android">仅 Android</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div class="space-y-1">
            <Label class="text-xs">媒体资源</Label>
            <ImageUpload
              v-model="form.mediaUrl"
              :accept="form.type === 'image' ? 'image/*' : 'video/*'"
              :placeholder="form.type === 'image' ? '上传图片' : '上传视频'"
            />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <Label class="text-xs">展示时长（秒）</Label>
              <Input v-model.number="form.duration" type="number" min="1" max="30" />
            </div>
            <div class="space-y-1">
              <Label class="text-xs">跳过延迟（秒）</Label>
              <Input v-model.number="form.skipDelay" type="number" min="0" max="10" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <Label class="text-xs">跳转类型</Label>
              <Select v-model="form.linkType">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="none">不跳转</SelectItem>
                  <SelectItem value="internal">内部页面</SelectItem>
                  <SelectItem value="external">外部链接</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-1">
              <Label class="text-xs">状态</Label>
              <Select v-model="form.status">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="0">启用</SelectItem>
                  <SelectItem value="1">停用</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <!-- 跳转链接 -->
          <div v-if="form.linkType !== 'none'" class="space-y-1">
            <Label class="text-xs">
              {{ form.linkType === 'external' ? '跳转链接' : '页面路径' }}
            </Label>
            <Input
              v-model="form.linkUrl"
              :placeholder="
                form.linkType === 'external' ? 'https://example.com' : '/pages/home/index'
              "
            />
            <p class="text-xs text-muted-foreground">
              {{
                form.linkType === 'external'
                  ? '点击启动页后跳转的外部网址'
                  : '点击启动页后跳转的 APP 内部页面路径'
              }}
            </p>
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
  </div>
</template>

<style scoped>
/* 启动页无需额外样式，状态栏已由 PhonePreview 组件处理 */
</style>
