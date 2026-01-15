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
  Stamp,
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
  mode: '__all__',
  platform: '__all__',
  status: '__all__',
  pageNum: 1,
  pageSize: 10,
})

// 表单数据
const form = reactive<CreateSplashParams>({
  title: '',
  mode: 'brand',
  // 广告模式字段
  type: 'image',
  mediaUrl: '',
  linkType: 'none',
  linkUrl: '',
  skipDelay: 0,
  // 品牌模式字段
  logoImage: '',
  logoText: '印',
  appName: '寻印',
  slogan: '探索城市文化，收集专属印记',
  backgroundColor: '#F8F5F0',
  textColor: '#2D2D2D',
  logoColor: '#C41E3A',
  // 通用字段
  duration: 3,
  platform: 'all',
  startTime: '',
  endTime: '',
  orderNum: 0,
  status: '0',
})

const editingId = ref<string | null>(null)
const previewItem = ref<SplashConfig | null>(null)

// 预览数据
const previewData = computed(() => {
  if (dialogVisible.value) {
    return {
      mode: form.mode,
      type: form.type,
      mediaUrl: form.mediaUrl,
      duration: form.duration,
      logoImage: form.logoImage,
      logoText: form.logoText,
      appName: form.appName,
      slogan: form.slogan,
      backgroundColor: form.backgroundColor,
      textColor: form.textColor,
      logoColor: form.logoColor,
    }
  }
  if (previewItem.value) {
    return {
      mode: previewItem.value.mode,
      type: previewItem.value.type,
      mediaUrl: previewItem.value.mediaUrl,
      duration: previewItem.value.duration,
      logoImage: previewItem.value.logoImage,
      logoText: previewItem.value.logoText,
      appName: previewItem.value.appName,
      slogan: previewItem.value.slogan,
      backgroundColor: previewItem.value.backgroundColor,
      textColor: previewItem.value.textColor,
      logoColor: previewItem.value.logoColor,
    }
  }
  return {
    mode: 'brand',
    type: 'image',
    mediaUrl: '',
    duration: 3,
    logoImage: '',
    logoText: '印',
    appName: '寻印',
    slogan: '探索城市文化，收集专属印记',
    backgroundColor: '#F8F5F0',
    textColor: '#2D2D2D',
    logoColor: '#C41E3A',
  }
})

// 获取列表
async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      mode: queryParams.mode === '__all__' ? '' : queryParams.mode,
      platform: queryParams.platform === '__all__' ? '' : queryParams.platform,
      status: queryParams.status === '__all__' ? '' : queryParams.status,
    }
    const res = (await listSplash(params)) as any
    const data = res.data || res
    list.value = data.list || []
    total.value = data.total || 0
    if (list.value.length > 0 && !previewItem.value) {
      previewItem.value = list.value[0] ?? null
    }
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  queryParams.pageNum = 1
  previewItem.value = null
  getList()
}

function handleReset() {
  queryParams.title = ''
  queryParams.mode = '__all__'
  queryParams.platform = '__all__'
  queryParams.status = '__all__'
  queryParams.pageNum = 1
  previewItem.value = null
  getList()
}

function handleAdd() {
  editingId.value = null
  dialogTitle.value = '新增启动页'
  resetForm()
  dialogVisible.value = true
}

function handleEdit(row: SplashConfig) {
  editingId.value = row.id
  dialogTitle.value = '编辑启动页'
  Object.assign(form, {
    title: row.title || '',
    mode: row.mode || 'ad',
    type: row.type || 'image',
    mediaUrl: row.mediaUrl || '',
    linkType: row.linkType || 'none',
    linkUrl: row.linkUrl || '',
    skipDelay: row.skipDelay || 0,
    logoImage: row.logoImage || '',
    logoText: row.logoText || '印',
    appName: row.appName || '寻印',
    slogan: row.slogan || '',
    backgroundColor: row.backgroundColor || '#F8F5F0',
    textColor: row.textColor || '#2D2D2D',
    logoColor: row.logoColor || '#C41E3A',
    duration: row.duration,
    platform: row.platform,
    startTime: row.startTime ? row.startTime.slice(0, 16) : '',
    endTime: row.endTime ? row.endTime.slice(0, 16) : '',
    orderNum: row.orderNum,
    status: row.status,
  })
  dialogVisible.value = true
}

function handlePreview(row: SplashConfig) {
  previewItem.value = row
}

function resetForm() {
  Object.assign(form, {
    title: '',
    mode: 'brand',
    type: 'image',
    mediaUrl: '',
    linkType: 'none',
    linkUrl: '',
    skipDelay: 0,
    logoImage: '',
    logoText: '印',
    appName: '寻印',
    slogan: '探索城市文化，收集专属印记',
    backgroundColor: '#F8F5F0',
    textColor: '#2D2D2D',
    logoColor: '#C41E3A',
    duration: 3,
    platform: 'all',
    startTime: '',
    endTime: '',
    orderNum: 0,
    status: '0',
  })
}

async function handleSubmit() {
  // 广告模式需要媒体资源
  if (form.mode === 'ad' && !form.mediaUrl) {
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
      // 更新预览项
      if (previewItem.value?.id === editingId.value) {
        previewItem.value = { ...previewItem.value, ...data } as SplashConfig
      }
    } else {
      await createSplash(data)
      toast({ title: '创建成功' })
    }
    dialogVisible.value = false
    await getList()
    // 如果是编辑，刷新预览项为最新数据
    if (editingId.value && previewItem.value) {
      const updated = list.value.find((item) => item.id === editingId.value)
      if (updated) previewItem.value = updated
    }
  } finally {
    submitLoading.value = false
  }
}

async function handleDelete(row: SplashConfig) {
  if (!window.confirm('确定要删除该启动页配置吗？')) return
  await deleteSplash(row.id)
  toast({ title: '删除成功' })
  if (previewItem.value?.id === row.id) previewItem.value = null
  getList()
}

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

async function handleStatusChange(row: SplashConfig) {
  const newStatus = row.status === '0' ? '1' : '0'
  await updateSplashStatus(row.id, newStatus)
  row.status = newStatus
  toast({ title: '状态更新成功' })
}

function handleSelectionChange(id: string, checked: boolean) {
  if (checked) {
    selectedIds.value.push(id)
  } else {
    selectedIds.value = selectedIds.value.filter((i) => i !== id)
  }
}

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
        <p class="text-sm text-muted-foreground">管理 APP 启动时展示的品牌页或开屏广告</p>
      </div>
      <div class="flex gap-2">
        <Button size="sm" @click="handleAdd"><Plus class="h-4 w-4 mr-1" />新增</Button>
      </div>
    </div>

    <!-- 主内容 -->
    <div class="flex gap-8 h-[calc(100vh-140px)]">
      <!-- 左侧：手机预览 -->
      <div class="shrink-0">
        <PhonePreview
          :scale="0.85"
          :show-device-switch="true"
          :status-bar-color="previewData.mode === 'brand' ? 'black' : 'white'"
        >
          <template #default>
            <!-- 品牌模式预览 -->
            <div
              v-if="previewData.mode === 'brand'"
              class="w-full h-full flex flex-col items-center justify-center"
              :style="{ backgroundColor: previewData.backgroundColor || '#F8F5F0' }"
            >
              <!-- Logo -->
              <div
                v-if="previewData.logoImage"
                class="w-24 h-24 rounded-[20px] overflow-hidden shadow-lg"
              >
                <img :src="previewData.logoImage" class="w-full h-full object-cover" alt="Logo" />
              </div>
              <div
                v-else
                class="w-24 h-24 rounded-[20px] flex items-center justify-center shadow-lg"
                :style="{ backgroundColor: previewData.logoColor || '#C41E3A' }"
              >
                <span class="text-5xl font-bold text-white">
                  {{ previewData.logoText || '印' }}
                </span>
              </div>
              <!-- 应用名称 -->
              <h1
                class="mt-6 text-3xl font-bold"
                :style="{ color: previewData.textColor || '#2D2D2D' }"
              >
                {{ previewData.appName || '寻印' }}
              </h1>
              <!-- 标语 -->
              <p class="mt-2 text-sm opacity-70" :style="{ color: previewData.textColor }">
                {{ previewData.slogan || '探索城市文化，收集专属印记' }}
              </p>
            </div>

            <!-- 广告模式预览 -->
            <div v-else class="w-full h-full bg-black relative flex flex-col">
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
                  class="absolute top-12 right-3 bg-black/50 backdrop-blur text-white text-xs px-3 py-1.5 rounded-full flex items-center gap-1"
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
                <Label class="text-xs">模式</Label>
                <Select v-model="queryParams.mode">
                  <SelectTrigger class="w-24 h-8">
                    <SelectValue placeholder="全部" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="__all__">全部</SelectItem>
                    <SelectItem value="brand">品牌</SelectItem>
                    <SelectItem value="ad">广告</SelectItem>
                  </SelectContent>
                </Select>
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
                <TableHead>模式</TableHead>
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
                    <Stamp v-if="row.mode === 'brand'" class="h-3 w-3 mr-1" />
                    <ImageIcon v-else-if="row.type === 'image'" class="h-3 w-3 mr-1" />
                    <Video v-else class="h-3 w-3 mr-1" />
                    {{ row.mode === 'brand' ? '品牌' : row.type === 'image' ? '图片' : '视频' }}
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
      <DialogContent class="max-w-lg max-h-[90vh] overflow-y-auto">
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
              <Label class="text-xs">模式</Label>
              <Select v-model="form.mode">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="brand">品牌启动页</SelectItem>
                  <SelectItem value="ad">广告启动页</SelectItem>
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

          <!-- 品牌模式配置 -->
          <template v-if="form.mode === 'brand'">
            <div class="space-y-1">
              <Label class="text-xs">Logo 图片（可选）</Label>
              <ImageUpload v-model="form.logoImage" placeholder="上传 Logo" />
              <p class="text-xs text-muted-foreground">建议尺寸：200x200，圆角会自动处理</p>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">Logo 文字（无图片时显示）</Label>
                <Input v-model="form.logoText" placeholder="印" maxlength="2" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">应用名称</Label>
                <Input v-model="form.appName" placeholder="寻印" />
              </div>
            </div>

            <div class="space-y-1">
              <Label class="text-xs">标语</Label>
              <Input v-model="form.slogan" placeholder="探索城市文化，收集专属印记" />
            </div>

            <div class="grid grid-cols-3 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">背景色</Label>
                <Input v-model="form.backgroundColor" type="color" class="h-10 p-1" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">文字颜色</Label>
                <Input v-model="form.textColor" type="color" class="h-10 p-1" />
              </div>
              <div class="space-y-1">
                <Label class="text-xs">Logo 背景色</Label>
                <Input v-model="form.logoColor" type="color" class="h-10 p-1" />
              </div>
            </div>
          </template>

          <!-- 广告模式配置 -->
          <template v-else>
            <div class="space-y-1">
              <Label class="text-xs">媒体类型</Label>
              <Select v-model="form.type">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="image">图片</SelectItem>
                  <SelectItem value="video">视频</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div class="space-y-1">
              <Label class="text-xs">媒体资源</Label>
              <ImageUpload
                v-model="form.mediaUrl"
                :accept="form.type === 'image' ? 'image/*' : 'video/*'"
                :placeholder="form.type === 'image' ? '上传图片' : '上传视频'"
              />
              <p class="text-xs text-muted-foreground">建议尺寸：1080x1920 (9:16) 或更高分辨率</p>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <Label class="text-xs">跳过延迟（秒）</Label>
                <Input v-model.number="form.skipDelay" type="number" min="0" max="10" />
              </div>
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
            </div>

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
            </div>
          </template>

          <!-- 通用配置 -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <Label class="text-xs">展示时长（秒）</Label>
              <Input v-model.number="form.duration" type="number" min="1" max="30" />
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
/* 启动页无需额外样式 */
</style>
