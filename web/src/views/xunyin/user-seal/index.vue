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
  DialogFooter,
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
  LinkIcon,
} from 'lucide-vue-next'
import {
  listUserSeal,
  getUserSeal,
  getUserSealStats,
  chainUserSeal,
  getChainProviderInfo,
  type UserSeal,
  type UserSealStats,
  type ChainProviderInfo,
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
  pageSize: 20,
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
      sealType: queryParams.sealType === 'all' ? undefined : queryParams.sealType,
      isChained:
        queryParams.isChained === 'all'
          ? undefined
          : queryParams.isChained === 'true'
            ? true
            : queryParams.isChained === 'false'
              ? false
              : undefined,
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

// 上链确认弹窗
const showChainDialog = ref(false)
const chainLoading = ref(false)
const chainTarget = ref<UserSeal | null>(null)
const chainProviderInfo = ref<ChainProviderInfo | null>(null)
const chainProviderLoading = ref(false)

async function openChainDialog(item: UserSeal) {
  if (item.isChained) return
  chainTarget.value = item
  showChainDialog.value = true

  // 获取链服务配置信息
  chainProviderLoading.value = true
  try {
    chainProviderInfo.value = await getChainProviderInfo()
  } catch (e: any) {
    toast({ title: '获取链配置失败', description: e.message, variant: 'destructive' })
  } finally {
    chainProviderLoading.value = false
  }
}

async function confirmChain() {
  if (!chainTarget.value || !chainProviderInfo.value?.isConfigured) return

  chainLoading.value = true
  try {
    await chainUserSeal(chainTarget.value.id)
    toast({
      title: '上链成功',
      description: `已成功上链至${chainProviderInfo.value.currentProviderName}`,
    })
    showChainDialog.value = false
    showDetailDialog.value = false
    getList()
    loadStats()
  } catch (e: any) {
    toast({ title: '上链失败', description: e.message, variant: 'destructive' })
  } finally {
    chainLoading.value = false
  }
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
    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
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
            <SelectItem value="all">全部</SelectItem>
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
            <SelectItem value="all">全部</SelectItem>
            <SelectItem value="true">已上链</SelectItem>
            <SelectItem value="false">未上链</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex gap-2 ml-auto">
        <Button @click="handleQuery"><Search class="w-4 h-4 mr-2" />搜索</Button>
        <Button variant="outline" @click="resetQuery"
          ><RefreshCw class="w-4 h-4 mr-2" />重置</Button
        >
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
                <Button
                  variant="ghost"
                  size="icon"
                  class="h-6 w-6"
                  @click="copyTxHash(item.txHash!)"
                >
                  <Copy class="w-3 h-3" />
                </Button>
              </div>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell class="text-right">
              <div class="flex items-center justify-end gap-1">
                <Button
                  v-if="!item.isChained"
                  variant="ghost"
                  size="icon"
                  @click="openChainDialog(item)"
                  title="上链"
                >
                  <LinkIcon class="w-4 h-4 text-blue-600" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  @click="handleViewDetail(item)"
                  title="查看详情"
                >
                  <Eye class="w-4 h-4" />
                </Button>
              </div>
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
              {{
                currentUserSeal.timeSpentMinutes ? `${currentUserSeal.timeSpentMinutes} 分钟` : '-'
              }}
            </div>
            <div>
              <span class="text-muted-foreground">上链状态：</span>
              <Badge :variant="currentUserSeal.isChained ? 'default' : 'secondary'" class="ml-1">
                {{ currentUserSeal.isChained ? '已上链' : '未上链' }}
              </Badge>
            </div>
          </div>
          <div
            v-if="currentUserSeal.isChained"
            class="space-y-2 p-4 bg-green-50 dark:bg-green-950 rounded-lg"
          >
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
                <code class="text-xs bg-muted px-2 py-1 rounded break-all">{{
                  currentUserSeal.txHash
                }}</code>
                <Button
                  variant="ghost"
                  size="icon"
                  class="h-6 w-6"
                  @click="copyTxHash(currentUserSeal.txHash!)"
                >
                  <Copy class="w-3 h-3" />
                </Button>
              </div>
            </div>
          </div>
          <div v-else class="p-4 bg-muted/50 border border-dashed rounded-lg">
            <div class="flex items-center justify-between">
              <div>
                <div class="font-medium">未上链</div>
                <div class="text-sm text-muted-foreground">该印记尚未上链存证</div>
              </div>
              <Button @click="openChainDialog(currentUserSeal)">
                <LinkIcon class="w-4 h-4 mr-2" />
                立即上链
              </Button>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- 上链确认弹窗 -->
    <Dialog v-model:open="showChainDialog">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>印记上链</DialogTitle>
          <DialogDescription> 将印记数据上链存证，上链后不可撤销 </DialogDescription>
        </DialogHeader>
        <div v-if="chainTarget" class="space-y-4 py-4">
          <!-- 印记信息 -->
          <div class="flex items-center gap-3 p-3 bg-muted rounded-lg">
            <div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
              <Award class="w-5 h-5 text-primary" />
            </div>
            <div>
              <div class="font-medium">{{ chainTarget.sealName }}</div>
              <div class="text-sm text-muted-foreground">{{ chainTarget.nickname }}</div>
            </div>
          </div>

          <!-- 链服务配置状态 -->
          <div v-if="chainProviderLoading" class="flex justify-center py-4">
            <Loader class="w-5 h-5 animate-spin" />
          </div>
          <div v-else-if="chainProviderInfo" class="space-y-3">
            <!-- 链服务选项列表 -->
            <div class="space-y-2">
              <div class="text-sm font-medium text-muted-foreground">可用链服务</div>
              <div class="grid gap-2">
                <div
                  v-for="option in chainProviderInfo.options"
                  :key="option.value"
                  class="flex items-center gap-3 p-3 border rounded-lg transition-colors"
                  :class="option.isCurrent ? 'border-primary bg-primary/5' : 'border-muted'"
                >
                  <!-- 选中指示器 -->
                  <div
                    class="w-4 h-4 rounded-full border-2 flex items-center justify-center shrink-0"
                    :class="option.isCurrent ? 'border-primary' : 'border-muted-foreground/30'"
                  >
                    <div v-if="option.isCurrent" class="w-2 h-2 rounded-full bg-primary" />
                  </div>
                  <!-- 链服务信息 -->
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2">
                      <span class="font-medium">{{ option.label }}</span>
                      <Badge v-if="option.isCurrent" variant="default" class="text-xs">
                        当前
                      </Badge>
                      <Badge v-if="!option.isConfigured" variant="secondary" class="text-xs">
                        未配置
                      </Badge>
                    </div>
                    <div class="text-xs text-muted-foreground">{{ option.description }}</div>
                  </div>
                  <!-- 配置按钮 -->
                  <Button
                    v-if="!option.isConfigured"
                    variant="outline"
                    size="sm"
                    @click="$router.push('/system/setting?tab=chain')"
                  >
                    去配置
                  </Button>
                </div>
              </div>
            </div>

            <!-- 当前链服务状态提示 -->
            <div
              v-if="chainProviderInfo.isConfigured"
              class="p-3 bg-green-50 dark:bg-green-950/30 border border-green-200 dark:border-green-900 rounded-lg"
            >
              <div class="flex items-center gap-2">
                <Link class="w-4 h-4 text-green-600" />
                <span class="text-sm text-green-700 dark:text-green-300">
                  将使用 <strong>{{ chainProviderInfo.currentProviderName }}</strong> 进行上链
                </span>
              </div>
            </div>
            <div
              v-else
              class="p-3 bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-900 rounded-lg"
            >
              <div class="flex items-center gap-2">
                <Link2Off class="w-4 h-4 text-red-600" />
                <span class="text-sm text-red-600 dark:text-red-400">
                  当前链服务
                  <strong>{{ chainProviderInfo.currentProviderName }}</strong> 未配置，请先完成配置
                </span>
              </div>
            </div>
          </div>

          <!-- 提示信息 -->
          <div
            v-if="chainProviderInfo?.isConfigured"
            class="p-3 bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900 rounded-lg"
          >
            <div class="text-sm text-amber-800 dark:text-amber-200">
              <strong>注意：</strong>上链操作将把印记数据永久存储到区块链上，此操作不可撤销。
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showChainDialog = false" :disabled="chainLoading"
            >取消</Button
          >
          <Button
            @click="confirmChain"
            :disabled="chainLoading || !chainProviderInfo?.isConfigured"
          >
            <Loader v-if="chainLoading" class="w-4 h-4 mr-2 animate-spin" />
            <LinkIcon v-else class="w-4 h-4 mr-2" />
            确认上链
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
