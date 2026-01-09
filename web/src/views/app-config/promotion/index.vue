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
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
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
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import {
  Plus,
  Search,
  RefreshCw,
  Pencil,
  Trash2,
  TrendingUp,
  Users,
  Download,
  Eye,
  BarChart3,
} from 'lucide-vue-next'
import {
  listChannels,
  createChannel,
  updateChannel,
  deleteChannel,
  batchDeleteChannels,
  getStatsSummary,
  getChannelRanking,
  type PromotionChannel,
  type CreateChannelParams,
  type StatsSummary,
  type ChannelRanking,
} from '@/api/app-config/promotion'

const { toast } = useToast()

// 状态
const loading = ref(false)
const list = ref<PromotionChannel[]>([])
const total = ref(0)
const selectedIds = ref<string[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增渠道')
const submitLoading = ref(false)
const activeTab = ref('channels')

// 删除确认对话框
const showDeleteDialog = ref(false)
const deleteTarget = ref<PromotionChannel | null>(null)
const showBatchDeleteDialog = ref(false)

// 统计数据
const summary = ref<StatsSummary>({
  totalPageViews: 0,
  totalDownloadClicks: 0,
  totalInstallCount: 0,
  totalRegisterCount: 0,
  totalActiveCount: 0,
})
const ranking = ref<ChannelRanking[]>([])

// 查询参数
const queryParams = reactive({
  channelName: '',
  channelType: '__all__',
  status: '',
  pageNum: 1,
  pageSize: 10,
})

// 表单数据
const form = reactive<CreateChannelParams>({
  channelCode: '',
  channelName: '',
  channelType: '',
  description: '',
  downloadUrl: '',
  qrcodeImage: '',
  status: '0',
})

const editingId = ref<string | null>(null)

// 渠道类型选项
const channelTypeOptions = [
  { value: 'social', label: '社交媒体' },
  { value: 'ad', label: '广告投放' },
  { value: 'offline', label: '线下推广' },
  { value: 'other', label: '其他' },
]

// 获取渠道列表
async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      channelType: queryParams.channelType === '__all__' ? '' : queryParams.channelType,
    }
    const res = await listChannels(params)
    list.value = res.data.list
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

// 获取统计数据
async function getStats() {
  try {
    const [summaryRes, rankingRes] = await Promise.all([getStatsSummary({}), getChannelRanking({})])
    summary.value = summaryRes.data
    ranking.value = rankingRes.data
  } catch {
    // 忽略错误
  }
}

// 搜索
function handleSearch() {
  queryParams.pageNum = 1
  getList()
}

// 重置
function handleReset() {
  queryParams.channelName = ''
  queryParams.channelType = '__all__'
  queryParams.status = ''
  queryParams.pageNum = 1
  getList()
}

// 新增
function handleAdd() {
  editingId.value = null
  dialogTitle.value = '新增渠道'
  resetForm()
  dialogVisible.value = true
}

// 编辑
function handleEdit(row: PromotionChannel) {
  editingId.value = row.id
  dialogTitle.value = '编辑渠道'
  Object.assign(form, {
    channelCode: row.channelCode,
    channelName: row.channelName,
    channelType: row.channelType || '',
    description: row.description || '',
    downloadUrl: row.downloadUrl || '',
    qrcodeImage: row.qrcodeImage || '',
    status: row.status,
  })
  dialogVisible.value = true
}

// 重置表单
function resetForm() {
  Object.assign(form, {
    channelCode: '',
    channelName: '',
    channelType: '',
    description: '',
    downloadUrl: '',
    qrcodeImage: '',
    status: '0',
  })
}

// 提交
async function handleSubmit() {
  if (!form.channelCode || !form.channelName) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }

  submitLoading.value = true
  try {
    if (editingId.value) {
      const { channelCode: _channelCode, ...updateData } = form
      await updateChannel(editingId.value, updateData)
      toast({ title: '更新成功' })
    } else {
      await createChannel(form)
      toast({ title: '创建成功' })
    }
    dialogVisible.value = false
    getList()
  } finally {
    submitLoading.value = false
  }
}

// 删除
function handleDelete(row: PromotionChannel) {
  deleteTarget.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  await deleteChannel(deleteTarget.value.id)
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
  await batchDeleteChannels(selectedIds.value)
  toast({ title: '删除成功' })
  selectedIds.value = []
  showBatchDeleteDialog.value = false
  getList()
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

// 获取渠道类型标签
function getChannelTypeLabel(type?: string) {
  return channelTypeOptions.find((o) => o.value === type)?.label || type || '-'
}

onMounted(() => {
  getList()
  getStats()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4">
    <!-- 页面标题 -->
    <div>
      <h2 class="text-xl sm:text-2xl font-bold tracking-tight">推广统计</h2>
      <p class="text-muted-foreground">管理推广渠道和查看推广效果数据</p>
    </div>

    <Tabs v-model="activeTab">
      <TabsList>
        <TabsTrigger value="channels">渠道管理</TabsTrigger>
        <TabsTrigger value="stats">数据统计</TabsTrigger>
      </TabsList>

      <!-- 渠道管理 -->
      <TabsContent value="channels" class="space-y-4">
        <!-- 搜索栏 -->
        <Card>
          <CardContent class="pt-6">
            <div class="flex flex-wrap gap-4 items-end">
              <div class="grid gap-2">
                <Label>渠道名称</Label>
                <Input v-model="queryParams.channelName" placeholder="请输入" class="w-48" />
              </div>
              <div class="grid gap-2">
                <Label>渠道类型</Label>
                <Select v-model="queryParams.channelType">
                  <SelectTrigger class="w-32">
                    <SelectValue placeholder="全部" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="__all__">全部</SelectItem>
                    <SelectItem
                      v-for="opt in channelTypeOptions"
                      :key="opt.value"
                      :value="opt.value"
                    >
                      {{ opt.label }}
                    </SelectItem>
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
            <Button @click="handleAdd"><Plus class="h-4 w-4 mr-2" />新增渠道</Button>
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
                <TableHead>渠道编码</TableHead>
                <TableHead>渠道名称</TableHead>
                <TableHead>渠道类型</TableHead>
                <TableHead>描述</TableHead>
                <TableHead>创建时间</TableHead>
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
                <TableCell class="font-mono text-sm">{{ row.channelCode }}</TableCell>
                <TableCell>{{ row.channelName }}</TableCell>
                <TableCell>
                  <Badge variant="outline">{{ getChannelTypeLabel(row.channelType) }}</Badge>
                </TableCell>
                <TableCell class="max-w-48 truncate">{{ row.description || '-' }}</TableCell>
                <TableCell>{{ row.createTime?.slice(0, 10) }}</TableCell>
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
                <TableCell colspan="7" class="text-center py-8 text-muted-foreground">
                  暂无数据
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </Card>
      </TabsContent>

      <!-- 数据统计 -->
      <TabsContent value="stats" class="space-y-4">
        <!-- 统计卡片 -->
        <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
          <Card>
            <CardContent class="pt-6">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-blue-100 dark:bg-blue-900 rounded-lg">
                  <Eye class="h-5 w-5 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <p class="text-sm text-muted-foreground">页面访问</p>
                  <p class="text-2xl font-bold">{{ summary.totalPageViews.toLocaleString() }}</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="pt-6">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-green-100 dark:bg-green-900 rounded-lg">
                  <Download class="h-5 w-5 text-green-600 dark:text-green-400" />
                </div>
                <div>
                  <p class="text-sm text-muted-foreground">下载点击</p>
                  <p class="text-2xl font-bold">
                    {{ summary.totalDownloadClicks.toLocaleString() }}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="pt-6">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-purple-100 dark:bg-purple-900 rounded-lg">
                  <TrendingUp class="h-5 w-5 text-purple-600 dark:text-purple-400" />
                </div>
                <div>
                  <p class="text-sm text-muted-foreground">安装数</p>
                  <p class="text-2xl font-bold">{{ summary.totalInstallCount.toLocaleString() }}</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="pt-6">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-orange-100 dark:bg-orange-900 rounded-lg">
                  <Users class="h-5 w-5 text-orange-600 dark:text-orange-400" />
                </div>
                <div>
                  <p class="text-sm text-muted-foreground">注册数</p>
                  <p class="text-2xl font-bold">
                    {{ summary.totalRegisterCount.toLocaleString() }}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent class="pt-6">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-pink-100 dark:bg-pink-900 rounded-lg">
                  <BarChart3 class="h-5 w-5 text-pink-600 dark:text-pink-400" />
                </div>
                <div>
                  <p class="text-sm text-muted-foreground">活跃用户</p>
                  <p class="text-2xl font-bold">{{ summary.totalActiveCount.toLocaleString() }}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <!-- 渠道排行 -->
        <Card>
          <CardHeader>
            <CardTitle>渠道排行榜</CardTitle>
            <CardDescription>按安装数排序的 Top 10 渠道</CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead class="w-12">排名</TableHead>
                  <TableHead>渠道</TableHead>
                  <TableHead class="text-right">页面访问</TableHead>
                  <TableHead class="text-right">下载点击</TableHead>
                  <TableHead class="text-right">安装数</TableHead>
                  <TableHead class="text-right">注册数</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-for="(item, index) in ranking" :key="item.channel?.id">
                  <TableCell>
                    <Badge
                      :variant="index < 3 ? 'default' : 'outline'"
                      :class="{
                        'bg-yellow-500': index === 0,
                        'bg-gray-400': index === 1,
                        'bg-orange-400': index === 2,
                      }"
                    >
                      {{ index + 1 }}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div>
                      <p class="font-medium">{{ item.channel?.channelName }}</p>
                      <p class="text-xs text-muted-foreground">{{ item.channel?.channelCode }}</p>
                    </div>
                  </TableCell>
                  <TableCell class="text-right">{{ item.pageViews.toLocaleString() }}</TableCell>
                  <TableCell class="text-right">{{
                    item.downloadClicks.toLocaleString()
                  }}</TableCell>
                  <TableCell class="text-right font-medium">{{
                    item.installCount.toLocaleString()
                  }}</TableCell>
                  <TableCell class="text-right">{{
                    item.registerCount.toLocaleString()
                  }}</TableCell>
                </TableRow>
                <TableRow v-if="ranking.length === 0">
                  <TableCell colspan="6" class="text-center py-8 text-muted-foreground">
                    暂无数据
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>

    <!-- 新增/编辑弹窗 -->
    <Dialog v-model:open="dialogVisible">
      <DialogContent class="max-w-lg">
        <DialogHeader>
          <DialogTitle>{{ dialogTitle }}</DialogTitle>
        </DialogHeader>

        <div class="space-y-4">
          <div class="grid gap-2">
            <Label>渠道编码 <span class="text-destructive">*</span></Label>
            <Input
              v-model="form.channelCode"
              placeholder="如：wechat_moments"
              :disabled="!!editingId"
            />
            <p class="text-xs text-muted-foreground">唯一标识，创建后不可修改</p>
          </div>
          <div class="grid gap-2">
            <Label>渠道名称 <span class="text-destructive">*</span></Label>
            <Input v-model="form.channelName" placeholder="如：微信朋友圈" />
          </div>
          <div class="grid gap-2">
            <Label>渠道类型</Label>
            <Select v-model="form.channelType">
              <SelectTrigger>
                <SelectValue placeholder="请选择" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem v-for="opt in channelTypeOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="grid gap-2">
            <Label>描述</Label>
            <Input v-model="form.description" placeholder="渠道描述（可选）" />
          </div>
          <div class="grid gap-2">
            <Label>专属下载链接</Label>
            <Input v-model="form.downloadUrl" placeholder="https://..." />
            <p class="text-xs text-muted-foreground">带渠道参数的下载链接，用于追踪来源</p>
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
      :description="`确定要删除渠道「${deleteTarget?.channelName}」吗？关联的统计数据也会被删除。`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 个渠道吗？关联的统计数据也会被删除。`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />
  </div>
</template>
