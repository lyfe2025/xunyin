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
import { Checkbox } from '@/components/ui/checkbox'
import { useToast } from '@/components/ui/toast/use-toast'
import { Search, RefreshCw, Award, Eye, Coins, Calendar, Smartphone, Mail } from 'lucide-vue-next'
import { listAppUser, getAppUser, changeAppUserStatus, type AppUser } from '@/api/xunyin/appuser'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import { formatDate } from '@/utils/format'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

const loading = ref(true)
const userList = ref<AppUser[]>([])
const total = ref(0)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  phone: '',
  email: '',
  nickname: '',
  loginType: undefined as string | undefined,
  status: undefined as string | undefined,
})

// 登录方式配置
const loginTypeOptions = [
  { value: 'wechat', label: '微信', icon: '💬', color: 'text-green-500' },
  { value: 'email', label: '邮箱', icon: '📧', color: 'text-blue-500' },
  { value: 'google', label: 'Google', icon: '🔍', color: 'text-red-500' },
  { value: 'apple', label: 'Apple', icon: '🍎', color: 'text-gray-700' },
]

function getLoginTypeInfo(type: string) {
  return loginTypeOptions.find((o) => o.value === type) || { label: type, icon: '❓', color: '' }
}

// 批量选择
const selectedIds = ref<string[]>([])

// 详情弹窗
const showDetailDialog = ref(false)
const currentUser = ref<AppUser | null>(null)
const detailLoading = ref(false)

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const res = await listAppUser(queryParams)
    userList.value = res.list
    total.value = res.total
    selectedIds.value = []
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.phone = ''
  queryParams.email = ''
  queryParams.nickname = ''
  queryParams.loginType = undefined
  queryParams.status = undefined
  handleQuery()
}

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await changeAppUserStatus(id, status)
  toast({ title: '状态更新成功' })
  const user = userList.value.find((u) => u.id === id)
  if (user) user.status = status
}

// 查看详情
async function handleDetail(row: AppUser) {
  detailLoading.value = true
  showDetailDialog.value = true
  try {
    currentUser.value = await getAppUser(row.id)
  } catch {
    currentUser.value = row
  } finally {
    detailLoading.value = false
  }
}

// 批量选择
function handleSelectAll(checked: boolean) {
  selectedIds.value = checked ? userList.value.map((u) => u.id) : []
}

function handleSelectOne(id: string, checked: boolean) {
  if (checked) {
    selectedIds.value.push(id)
  } else {
    selectedIds.value = selectedIds.value.filter((i) => i !== id)
  }
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const data =
    selectedIds.value.length > 0
      ? userList.value.filter((u) => selectedIds.value.includes(u.id))
      : userList.value
  const filename = getExportFilename('App用户数据')
  const columns = [
    { key: 'nickname' as const, label: '昵称' },
    { key: 'phone' as const, label: '手机号' },
    { key: 'email' as const, label: '邮箱' },
    { key: 'loginType' as const, label: '登录方式' },
    { key: 'badgeTitle' as const, label: '称号' },
    { key: 'totalPoints' as const, label: '总积分' },
    { key: 'status' as const, label: '状态' },
    { key: 'createTime' as const, label: '注册时间' },
  ]

  if (format === 'xlsx') {
    exportToExcel(data, columns, filename, 'App用户')
  } else if (format === 'csv') {
    exportToCsv(data, columns, filename)
  } else {
    exportToJson(data, filename)
  }
  toast({ title: '导出成功' })
}

onMounted(() => {
  getList()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">App用户管理</h2>
        <p class="text-sm text-muted-foreground">管理寻印 App 的注册用户</p>
      </div>
      <div class="flex gap-2">
        <ExportButton
          v-if="userList.length > 0"
          :formats="['xlsx', 'csv', 'json']"
          :text="selectedIds.length > 0 ? `导出 (${selectedIds.length})` : '导出'"
          @export="handleExport"
        />
      </div>
    </div>

    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">手机号</span>
        <Input
          v-model="queryParams.phone"
          placeholder="请输入"
          class="w-[130px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">邮箱</span>
        <Input
          v-model="queryParams.email"
          placeholder="请输入"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">昵称</span>
        <Input
          v-model="queryParams.nickname"
          placeholder="请输入"
          class="w-[120px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">登录方式</span>
        <Select v-model="queryParams.loginType">
          <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem v-for="opt in loginTypeOptions" :key="opt.value" :value="opt.value">
              {{ opt.icon }} {{ opt.label }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">状态</span>
        <Select v-model="queryParams.status">
          <SelectTrigger class="w-[100px]"><SelectValue placeholder="全部" /></SelectTrigger>
          <SelectContent>
            <SelectItem value="0">正常</SelectItem>
            <SelectItem value="1">禁用</SelectItem>
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

    <div class="border rounded-md bg-card overflow-x-auto">
      <TableSkeleton v-if="loading" :columns="9" :rows="10" show-checkbox />
      <EmptyState v-else-if="userList.length === 0" title="暂无用户数据" />
      <Table v-else class="min-w-[1000px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox
                :checked="selectedIds.length === userList.length && userList.length > 0"
                @update:checked="handleSelectAll"
              />
            </TableHead>
            <TableHead>用户</TableHead>
            <TableHead>联系方式</TableHead>
            <TableHead>登录方式</TableHead>
            <TableHead>称号</TableHead>
            <TableHead>总积分</TableHead>
            <TableHead>状态</TableHead>
            <TableHead>注册时间</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="user in userList" :key="user.id">
            <TableCell>
              <Checkbox
                :checked="selectedIds.includes(user.id)"
                @update:checked="(checked: boolean) => handleSelectOne(user.id, checked)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-3">
                <Avatar class="h-9 w-9">
                  <AvatarImage :src="getResourceUrl(user.avatar)" />
                  <AvatarFallback>{{ user.nickname?.charAt(0) || 'U' }}</AvatarFallback>
                </Avatar>
                <span class="font-medium">{{ user.nickname }}</span>
              </div>
            </TableCell>
            <TableCell>
              <div class="space-y-1 text-sm">
                <div v-if="user.phone" class="flex items-center gap-1">
                  <Smartphone class="w-3 h-3 text-muted-foreground" />
                  {{ user.phone }}
                </div>
                <div v-if="user.email" class="flex items-center gap-1">
                  <Mail class="w-3 h-3 text-muted-foreground" />
                  {{ user.email }}
                </div>
                <span v-if="!user.phone && !user.email" class="text-muted-foreground">-</span>
              </div>
            </TableCell>
            <TableCell>
              <Badge variant="outline" :class="getLoginTypeInfo(user.loginType).color">
                {{ getLoginTypeInfo(user.loginType).icon }}
                {{ getLoginTypeInfo(user.loginType).label }}
              </Badge>
            </TableCell>
            <TableCell>
              <div v-if="user.badgeTitle" class="flex items-center gap-1">
                <Award class="w-4 h-4 text-yellow-500" />
                {{ user.badgeTitle }}
              </div>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-1">
                <Coins class="w-4 h-4 text-amber-500" />
                {{ user.totalPoints }}
              </div>
            </TableCell>
            <TableCell>
              <StatusSwitch
                :model-value="user.status"
                :id="user.id"
                active-text="正常"
                inactive-text="禁用"
                @change="handleStatusChange"
              />
            </TableCell>
            <TableCell>{{ formatDate(user.createTime) }}</TableCell>
            <TableCell class="text-right">
              <Button variant="ghost" size="icon" @click="handleDetail(user)">
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

    <!-- 用户详情弹窗 -->
    <Dialog v-model:open="showDetailDialog">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>用户详情</DialogTitle>
          <DialogDescription>查看 App 用户的详细信息</DialogDescription>
        </DialogHeader>
        <div v-if="detailLoading" class="py-8 text-center text-muted-foreground">加载中...</div>
        <div v-else-if="currentUser" class="space-y-6 py-4">
          <!-- 用户基本信息 -->
          <div class="flex items-center gap-4">
            <Avatar class="h-16 w-16">
              <AvatarImage :src="getResourceUrl(currentUser.avatar)" />
              <AvatarFallback class="text-xl">{{
                currentUser.nickname?.charAt(0) || 'U'
              }}</AvatarFallback>
            </Avatar>
            <div>
              <h3 class="text-lg font-semibold">{{ currentUser.nickname }}</h3>
              <div
                v-if="currentUser.badgeTitle"
                class="flex items-center gap-1 text-sm text-muted-foreground"
              >
                <Award class="w-4 h-4 text-yellow-500" />
                {{ currentUser.badgeTitle }}
              </div>
            </div>
          </div>

          <!-- 详细信息 -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Smartphone class="w-4 h-4" /> 手机号
              </div>
              <div class="font-medium">{{ currentUser.phone || '-' }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Coins class="w-4 h-4" /> 总积分
              </div>
              <div class="font-medium text-amber-600">{{ currentUser.totalPoints }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground">状态</div>
              <Badge :variant="currentUser.status === '0' ? 'default' : 'destructive'">
                {{ currentUser.status === '0' ? '正常' : '禁用' }}
              </Badge>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Calendar class="w-4 h-4" /> 注册时间
              </div>
              <div class="font-medium">{{ formatDate(currentUser.createTime) }}</div>
            </div>
          </div>

          <!-- 登录方式信息 -->
          <div class="pt-4 border-t">
            <h4 class="text-sm font-medium mb-3">登录方式</h4>
            <Badge
              variant="outline"
              :class="getLoginTypeInfo(currentUser.loginType).color"
              class="mb-3"
            >
              {{ getLoginTypeInfo(currentUser.loginType).icon }}
              {{ getLoginTypeInfo(currentUser.loginType).label }}
            </Badge>
            <div class="space-y-2 text-sm text-muted-foreground">
              <div v-if="currentUser.email" class="flex items-center gap-2">
                <Mail class="w-4 h-4" />
                <span>邮箱: {{ currentUser.email }}</span>
              </div>
              <div v-if="currentUser.openId">
                <div>微信 OpenID: {{ currentUser.openId }}</div>
                <div v-if="currentUser.unionId">微信 UnionID: {{ currentUser.unionId }}</div>
              </div>
              <div v-if="currentUser.googleId">Google ID: {{ currentUser.googleId }}</div>
              <div v-if="currentUser.appleId">Apple ID: {{ currentUser.appleId }}</div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>
