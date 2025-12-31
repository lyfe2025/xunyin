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
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Progress } from '@/components/ui/progress'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Search,
  RefreshCw,
  Eye,
  MapPin,
  CheckCircle,
  XCircle,
  Loader,
} from 'lucide-vue-next'
import {
  listProgress,
  getProgress,
  getProgressStats,
  type JourneyProgress,
  type ProgressStats,
} from '@/api/xunyin/progress'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import { formatDate } from '@/utils/format'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

const loading = ref(true)
const progressList = ref<JourneyProgress[]>([])
const total = ref(0)
const stats = ref<ProgressStats | null>(null)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  nickname: '',
  journeyName: '',
  status: undefined as string | undefined,
})

const statusOptions = [
  { value: 'in_progress', label: '进行中', variant: 'default' as const, icon: Loader },
  { value: 'completed', label: '已完成', variant: 'secondary' as const, icon: CheckCircle },
  { value: 'abandoned', label: '已放弃', variant: 'destructive' as const, icon: XCircle },
]

function getStatusInfo(status: string) {
  return statusOptions.find((o) => o.value === status) || statusOptions[0]
}

// 详情弹窗
const showDetailDialog = ref(false)
const currentProgress = ref<any>(null)
const detailLoading = ref(false)

const { toast: _toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const res = await listProgress(queryParams)
    progressList.value = res.list
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    stats.value = await getProgressStats()
  } catch {
    // ignore
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.nickname = ''
  queryParams.journeyName = ''
  queryParams.status = undefined
  handleQuery()
}

async function handleViewDetail(row: JourneyProgress) {
  detailLoading.value = true
  showDetailDialog.value = true
  try {
    currentProgress.value = await getProgress(row.id)
  } finally {
    detailLoading.value = false
  }
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('用户进度数据')
  const columns = [
    { key: 'nickname' as const, label: '用户昵称' },
    { key: 'journeyName' as const, label: '文化之旅' },
    { key: 'cityName' as const, label: '城市' },
    { key: 'status' as const, label: '状态' },
    { key: 'completedPoints' as const, label: '已完成探索点' },
    { key: 'totalPoints' as const, label: '总探索点' },
    { key: 'startTime' as const, label: '开始时间' },
    { key: 'completeTime' as const, label: '完成时间' },
    { key: 'timeSpentMinutes' as const, label: '花费时间(分钟)' },
  ]
  if (format === 'xlsx') {
    exportToExcel(progressList.value, columns, filename, '用户进度')
  } else if (format === 'csv') {
    exportToCsv(progressList.value, columns, filename)
  } else {
    exportToJson(progressList.value, filename)
  }
}

onMounted(() => {
  getList()
  loadStats()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">用户进度管理</h2>
        <p class="text-sm text-muted-foreground">查看用户文化之旅进度</p>
      </div>
      <ExportButton
        v-if="progressList.length > 0"
        :formats="['xlsx', 'csv', 'json']"
        @export="handleExport"
      />
    </div>

    <!-- 统计卡片 -->
    <div class="grid gap-4 md:grid-cols-4" v-if="stats">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">总进度数</CardTitle>
          <MapPin class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ stats.total }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">进行中</CardTitle>
          <Loader class="h-4 w-4 text-blue-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-blue-600">{{ stats.inProgress }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">已完成</CardTitle>
          <CheckCircle class="h-4 w-4 text-green-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-green-600">{{ stats.completed }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">已放弃</CardTitle>
          <XCircle class="h-4 w-4 text-red-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-red-600">{{ stats.abandoned }}</div>
        </CardContent>
      </Card>
    </div>

    <!-- 筛选 -->
    <div class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg">
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">用户昵称</span>
        <Input
          v-model="queryParams.nickname"
          placeholder="请输入"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">文化之旅</span>
        <Input
          v-model="queryParams.journeyName"
          placeholder="请输入"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">状态</span>
        <Select v-model="queryParams.status" @update:model-value="handleQuery">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="s in statusOptions" :key="s.value" :value="s.value">
              {{ s.label }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex gap-2 ml-auto">
        <Button @click="handleQuery"><Search class="w-4 h-4 mr-2" />搜索</Button>
        <Button variant="outline" @click="resetQuery"><RefreshCw class="w-4 h-4 mr-2" />重置</Button>
      </div>
    </div>

    <!-- 表格 -->
    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="8" :rows="10" />
      <EmptyState v-else-if="progressList.length === 0" title="暂无进度数据" />
      <Table v-else class="min-w-[900px]">
        <TableHeader>
          <TableRow>
            <TableHead>用户</TableHead>
            <TableHead>文化之旅</TableHead>
            <TableHead>城市</TableHead>
            <TableHead>进度</TableHead>
            <TableHead>状态</TableHead>
            <TableHead>开始时间</TableHead>
            <TableHead>花费时间</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="item in progressList" :key="item.id">
            <TableCell>
              <div class="flex items-center gap-2">
                <Avatar class="h-8 w-8">
                  <AvatarImage :src="getResourceUrl(item.avatar)" />
                  <AvatarFallback>{{ item.nickname?.charAt(0) }}</AvatarFallback>
                </Avatar>
                <span>{{ item.nickname }}</span>
              </div>
            </TableCell>
            <TableCell>{{ item.journeyName }}</TableCell>
            <TableCell>{{ item.cityName || '-' }}</TableCell>
            <TableCell>
              <div class="flex items-center gap-2">
                <Progress :model-value="(item.completedPoints / item.totalPoints) * 100" class="w-20 h-2" />
                <span class="text-sm text-muted-foreground">
                  {{ item.completedPoints }}/{{ item.totalPoints }}
                </span>
              </div>
            </TableCell>
            <TableCell>
              <Badge :variant="getStatusInfo(item.status).variant">
                {{ getStatusInfo(item.status).label }}
              </Badge>
            </TableCell>
            <TableCell>{{ formatDate(item.startTime) }}</TableCell>
            <TableCell>
              <span v-if="item.timeSpentMinutes">{{ item.timeSpentMinutes }} 分钟</span>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell class="text-right">
              <Button variant="ghost" size="icon" @click="handleViewDetail(item)">
                <Eye class="w-4 h-4" />
              </Button>
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

    <!-- 详情弹窗 -->
    <Dialog v-model:open="showDetailDialog">
      <DialogContent class="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>进度详情</DialogTitle>
          <DialogDescription>查看用户文化之旅进度详情</DialogDescription>
        </DialogHeader>
        <div v-if="detailLoading" class="flex justify-center py-8">
          <Loader class="w-6 h-6 animate-spin" />
        </div>
        <div v-else-if="currentProgress" class="space-y-4">
          <div class="flex items-center gap-4">
            <Avatar class="h-12 w-12">
              <AvatarImage :src="getResourceUrl(currentProgress.avatar)" />
              <AvatarFallback>{{ currentProgress.nickname?.charAt(0) }}</AvatarFallback>
            </Avatar>
            <div>
              <div class="font-medium">{{ currentProgress.nickname }}</div>
              <div class="text-sm text-muted-foreground">{{ currentProgress.journeyName }}</div>
            </div>
            <Badge :variant="getStatusInfo(currentProgress.status).variant" class="ml-auto">
              {{ getStatusInfo(currentProgress.status).label }}
            </Badge>
          </div>
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="text-muted-foreground">城市：</span>
              {{ currentProgress.cityName || '-' }}
            </div>
            <div>
              <span class="text-muted-foreground">进度：</span>
              {{ currentProgress.completedPoints }}/{{ currentProgress.totalPoints }}
            </div>
            <div>
              <span class="text-muted-foreground">开始时间：</span>
              {{ formatDate(currentProgress.startTime) }}
            </div>
            <div>
              <span class="text-muted-foreground">完成时间：</span>
              {{ currentProgress.completeTime ? formatDate(currentProgress.completeTime) : '-' }}
            </div>
            <div>
              <span class="text-muted-foreground">花费时间：</span>
              {{ currentProgress.timeSpentMinutes ? `${currentProgress.timeSpentMinutes} 分钟` : '-' }}
            </div>
          </div>
          <!-- 探索点完成情况 -->
          <div v-if="currentProgress.pointCompletions?.length > 0">
            <div class="font-medium mb-2">已完成探索点</div>
            <div class="space-y-2">
              <div
                v-for="pc in currentProgress.pointCompletions"
                :key="pc.id"
                class="flex items-center justify-between p-2 bg-muted rounded"
              >
                <span>{{ pc.point?.name }}</span>
                <span class="text-sm text-muted-foreground">{{ formatDate(pc.completeTime) }}</span>
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>
