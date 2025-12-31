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
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Search,
  RefreshCw,
  Eye,
  Award,
  Link,
  Link2Off,
  Copy,
  Loader,
} from 'lucide-vue-next'
import {
  listUserSeal,
  getUserSeal,
  getUserSealStats,
  type UserSeal,
  type UserSealStats,
} from '@/api/xunyin/user-seal'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import { formatDate } from '@/utils/format'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

const loading = ref(true)
const userSealList = ref<UserSeal[]>([])
const total = ref(0)
const stats = ref<UserSealStats | null>(null)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  nickname: '',
  sealName: '',
  sealType: undefined as string | undefined,
  isChained: undefined as string | undefined,
})

const sealTypeOptions = [
  { value: 'route', label: '路线印记' },
  { value: 'city', label: '城市印记' },
  { value: 'special', label: '特殊印记' },
]

function getSealTypeLabel(type: string) {
  return sealTypeOptions.find((t) => t.value === type)?.label || type
}

// 详情弹窗
const showDetailDialog = ref(false)
const currentUserSeal = ref<UserSeal | null>(null)
const detailLoading = ref(false)

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      isChained: queryParams.isChained === 'true' ? true : queryParams.isChained === 'false' ? false : undefined,
    }
    const res = await listUserSeal(params)
    userSealList.value = res.list
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    stats.value = await getUserSealStats()
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
  queryParams.sealName = ''
  queryParams.sealType = undefined
  queryParams.isChained = undefined
  handleQuery()
}

async function handleViewDetail(row: UserSeal) {
  detailLoading.value = true
  showDetailDialog.value = true
  try {
    currentUserSeal.value = await getUserSeal(row.id)
  } finally {
    detailLoading.value = false
  }
}

function copyTxHash(hash: string) {
  navigator.clipboard.writeText(hash)
  toast({ title: '已复制交易哈希' })
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('用户印记数据')
  const columns = [
    { key: 'nickname' as const, label: '用户昵称' },
    { key: 'sealName' as const, label: '印记名称' },
    { key: 'sealType' as const, label: '印记类型' },
    { key: 'earnedTime' as const, label: '获得时间' },
    { key: 'pointsEarned' as const, label: '获得积分' },
    { key: 'isChained' as const, label: '是否上链' },
    { key: 'chainName' as const, label: '区块链' },
    { key: 'txHash' as const, label: '交易哈希' },
    { key: 'chainTime' as const, label: '上链时间' },
  ]
  if (format === 'xlsx') {
    exportToExcel(userSealList.value, columns, filename, '用户印记')
  } else if (format === 'csv') {
    exportToCsv(userSealList.value, columns, filename)
  } else {
    exportToJson(userSealList.value, filename)
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
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">用户印记管理</h2>
        <p class="text-sm text-muted-foreground">查看用户获得的印记和上链状态</p>
      </div>
      <ExportButton
        v-if="userSealList.length > 0"
        :formats="['xlsx', 'csv', 'json']"
        @export="handleExport"
      />
    </div>

    <!-- 统计卡片 -->
    <div class="grid gap-4 md:grid-cols-4" v-if="stats">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">总印记数</CardTitle>
          <Award class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ stats.total }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">已上链</CardTitle>
          <Link class="h-4 w-4 text-green-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-green-600">{{ stats.chained }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">未上链</CardTitle>
          <Link2Off class="h-4 w-4 text-gray-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-gray-600">{{ stats.unchained }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">上链率</CardTitle>
          <Link class="h-4 w-4 text-blue-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-blue-600">
            {{ stats.total > 0 ? ((stats.chained / stats.total) * 100).toFixed(1) : 0 }}%
          </div>
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
        <span class="text-sm font-medium">印记名称</span>
        <Input
          v-model="queryParams.sealName"
          placeholder="请输入"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">印记类型</span>
        <Select v-model="queryParams.sealType" @update:model-value="handleQuery">
          <SelectTrigger class="w-[130px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="t in sealTypeOptions" :key="t.value" :value="t.value">
              {{ t.label }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">上链状态</span>
        <Select v-model="queryParams.isChained" @update:model-value="handleQuery">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="true">已上链</SelectItem>
            <SelectItem value="false">未上链</SelectItem>
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
      <EmptyState v-else-if="userSealList.length === 0" title="暂无用户印记数据" />
      <Table v-else class="min-w-[1000px]">
        <TableHeader>
          <TableRow>
            <TableHead>用户</TableHead>
            <TableHead>印记</TableHead>
            <TableHead>类型</TableHead>
            <TableHead>获得时间</TableHead>
            <TableHead>积分</TableHead>
            <TableHead>上链状态</TableHead>
            <TableHead>交易哈希</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="item in userSealList" :key="item.id">
            <TableCell>
              <div class="flex items-center gap-2">
                <Avatar class="h-8 w-8">
                  <AvatarImage :src="getResourceUrl(item.avatar)" />
                  <AvatarFallback>{{ item.nickname?.charAt(0) }}</AvatarFallback>
                </Avatar>
                <span>{{ item.nickname }}</span>
              </div>
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-2">
                <TooltipProvider v-if="item.sealImage">
                  <Tooltip>
                    <TooltipTrigger>
                      <img
                        :src="getResourceUrl(item.sealImage)"
                        :alt="item.sealName"
                        class="w-8 h-8 rounded-full object-cover"
                      />
                    </TooltipTrigger>
                    <TooltipContent side="right" class="p-0">
                      <img
                        :src="getResourceUrl(item.sealImage)"
                        :alt="item.sealName"
                        class="max-w-[150px] max-h-[150px] rounded-lg"
                      />
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
                <span>{{ item.sealName }}</span>
              </div>
            </TableCell>
            <TableCell>
              <Badge variant="outline">{{ getSealTypeLabel(item.sealType) }}</Badge>
            </TableCell>
            <TableCell>{{ formatDate(item.earnedTime) }}</TableCell>
            <TableCell>+{{ item.pointsEarned }}</TableCell>
            <TableCell>
              <Badge :variant="item.isChained ? 'default' : 'secondary'">
                <Link v-if="item.isChained" class="w-3 h-3 mr-1" />
                <Link2Off v-else class="w-3 h-3 mr-1" />
                {{ item.isChained ? '已上链' : '未上链' }}
              </Badge>
            </TableCell>
            <TableCell>
              <div v-if="item.txHash" class="flex items-center gap-1">
                <span class="text-xs font-mono truncate max-w-[120px]">{{ item.txHash }}</span>
                <Button variant="ghost" size="icon" class="h-6 w-6" @click="copyTxHash(item.txHash!)">
                  <Copy class="w-3 h-3" />
                </Button>
              </div>
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
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>印记详情</DialogTitle>
          <DialogDescription>查看用户印记详细信息</DialogDescription>
        </DialogHeader>
        <div v-if="detailLoading" class="flex justify-center py-8">
          <Loader class="w-6 h-6 animate-spin" />
        </div>
        <div v-else-if="currentUserSeal" class="space-y-4">
          <div class="flex items-center gap-4">
            <Avatar class="h-12 w-12">
              <AvatarImage :src="getResourceUrl(currentUserSeal.avatar)" />
              <AvatarFallback>{{ currentUserSeal.nickname?.charAt(0) }}</AvatarFallback>
            </Avatar>
            <div>
              <div class="font-medium">{{ currentUserSeal.nickname }}</div>
              <div class="text-sm text-muted-foreground">{{ currentUserSeal.phone }}</div>
            </div>
          </div>
          <div class="flex items-center gap-4 p-4 bg-muted rounded-lg">
            <img
              v-if="currentUserSeal.sealImage"
              :src="getResourceUrl(currentUserSeal.sealImage)"
              :alt="currentUserSeal.sealName"
              class="w-16 h-16 rounded-full object-cover"
            />
            <div>
              <div class="font-medium">{{ currentUserSeal.sealName }}</div>
              <Badge variant="outline">{{ getSealTypeLabel(currentUserSeal.sealType) }}</Badge>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="text-muted-foreground">获得时间：</span>
              {{ formatDate(currentUserSeal.earnedTime) }}
            </div>
            <div>
              <span class="text-muted-foreground">获得积分：</span>
              +{{ currentUserSeal.pointsEarned }}
            </div>
            <div>
              <span class="text-muted-foreground">花费时间：</span>
              {{ currentUserSeal.timeSpentMinutes ? `${currentUserSeal.timeSpentMinutes} 分钟` : '-' }}
            </div>
            <div>
              <span class="text-muted-foreground">上链状态：</span>
              <Badge :variant="currentUserSeal.isChained ? 'default' : 'secondary'" class="ml-1">
                {{ currentUserSeal.isChained ? '已上链' : '未上链' }}
              </Badge>
            </div>
          </div>
          <div v-if="currentUserSeal.isChained" class="space-y-2 p-4 bg-green-50 dark:bg-green-950 rounded-lg">
            <div class="font-medium text-green-700 dark:text-green-300">区块链信息</div>
            <div class="grid gap-2 text-sm">
              <div>
                <span class="text-muted-foreground">区块链：</span>
                {{ currentUserSeal.chainName }}
              </div>
              <div>
                <span class="text-muted-foreground">区块高度：</span>
                {{ currentUserSeal.blockHeight }}
              </div>
              <div>
                <span class="text-muted-foreground">上链时间：</span>
                {{ formatDate(currentUserSeal.chainTime!) }}
              </div>
              <div class="flex items-center gap-2">
                <span class="text-muted-foreground">交易哈希：</span>
                <code class="text-xs bg-muted px-2 py-1 rounded break-all">{{ currentUserSeal.txHash }}</code>
                <Button variant="ghost" size="icon" class="h-6 w-6" @click="copyTxHash(currentUserSeal.txHash!)">
                  <Copy class="w-3 h-3" />
                </Button>
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>
