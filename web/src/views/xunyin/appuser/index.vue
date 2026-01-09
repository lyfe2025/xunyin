<script setup lang="ts">
import { ref, reactive, onMounted, watch, computed } from 'vue'
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Search,
  RefreshCw,
  Award,
  Eye,
  Coins,
  Calendar,
  Smartphone,
  Mail,
  ShieldCheck,
  UserCheck,
  Clock,
  Users,
  UserX,
  FileCheck,
  FileClock,
  FileX,
  X,
  ChevronLeft,
  ChevronRight,
} from 'lucide-vue-next'
import BrandIcon from '@/components/icons/BrandIcons.vue'
import {
  listAppUser,
  getAppUser,
  changeAppUserStatus,
  listVerifications,
  auditVerification,
  getAppUserStats,
  getVerificationStats,
  batchAuditVerifications,
  type AppUser,
  type UserVerification,
  type AppUserStats,
  type VerificationStats,
} from '@/api/xunyin/appuser'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import { formatDate } from '@/utils/format'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

// 工具函数：处理 "all" 值转 undefined
function normalizeQueryValue<T>(value: T | 'all' | undefined): T | undefined {
  return value === 'all' ? undefined : value
}

const loading = ref(true)
const userList = ref<AppUser[]>([])
const total = ref(0)
const userStats = ref<AppUserStats | null>(null)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  phone: '',
  email: '',
  nickname: '',
  loginType: undefined as string | undefined,
  isVerified: undefined as string | undefined,
  status: undefined as string | undefined,
})

// 登录方式配置
const loginTypeOptions = [
  { value: 'wechat', label: '微信', color: 'text-green-500' },
  { value: 'email', label: '邮箱', color: 'text-blue-500' },
  { value: 'google', label: 'Google', color: '' },
  { value: 'apple', label: 'Apple', color: 'text-gray-700 dark:text-gray-300' },
]

// 性别配置
const genderOptions: Record<string, string> = {
  '0': '男',
  '1': '女',
  '2': '未知',
}

function getLoginTypeInfo(type: string) {
  return loginTypeOptions.find((o) => o.value === type) || { value: type, label: type, color: '' }
}

// 批量选择
const selectedIds = ref<string[]>([])
const selectAll = ref(false)
// 详情弹窗
const showDetailDialog = ref(false)
const currentUser = ref<AppUser | null>(null)
const detailLoading = ref(false)

// 图片预览
const showImagePreview = ref(false)
const previewImages = ref<string[]>([])
const currentImageIndex = ref(0)

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const params = {
      ...queryParams,
      loginType: normalizeQueryValue(queryParams.loginType),
      status: normalizeQueryValue(queryParams.status),
      isVerified:
        queryParams.isVerified === 'all'
          ? undefined
          : queryParams.isVerified === 'true'
            ? true
            : queryParams.isVerified === 'false'
              ? false
              : undefined,
    }
    const res = await listAppUser(params)
    userList.value = res.list
    total.value = res.total
    selectedIds.value = []
    selectAll.value = false
  } finally {
    loading.value = false
  }
}

async function loadUserStats() {
  try {
    userStats.value = await getAppUserStats()
  } catch {
    // ignore
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
  queryParams.isVerified = undefined
  queryParams.status = undefined
  handleQuery()
}

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await changeAppUserStatus(id, status)
  const user = userList.value.find((u) => u.id === id)
  if (user) user.status = status
  loadUserStats()
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
function handleSelectOne(id: string) {
  const index = selectedIds.value.indexOf(id)
  if (index > -1) {
    selectedIds.value.splice(index, 1)
  } else {
    selectedIds.value.push(id)
  }
}

// 监听全选状态变化
watch(selectAll, (newVal) => {
  if (newVal) {
    selectedIds.value = userList.value.map((u) => u.id)
  } else if (selectedIds.value.length === userList.value.length) {
    selectedIds.value = []
  }
})

// 监听选中项变化，更新全选状态
watch(
  selectedIds,
  (newVal) => {
    selectAll.value = userList.value.length > 0 && newVal.length === userList.value.length
  },
  { deep: true },
)

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
    { key: 'level' as const, label: '等级' },
    { key: 'badgeTitle' as const, label: '称号' },
    { key: 'totalPoints' as const, label: '总积分' },
    { key: 'isVerified' as const, label: '实名认证' },
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

// 图片预览
function openImagePreview(images: string[], index: number = 0) {
  previewImages.value = images.filter(Boolean).map(getResourceUrl)
  currentImageIndex.value = index
  showImagePreview.value = true
}

function prevImage() {
  if (currentImageIndex.value > 0) {
    currentImageIndex.value--
  }
}

function nextImage() {
  if (currentImageIndex.value < previewImages.value.length - 1) {
    currentImageIndex.value++
  }
}

// ========== 实名认证管理 ==========
const activeTab = ref('users')
const verificationActiveTab = ref('all')
const verificationLoading = ref(false)
const verificationList = ref<UserVerification[]>([])
const verificationTotal = ref(0)
const verificationStats = ref<VerificationStats | null>(null)
const verificationQuery = reactive({
  pageNum: 1,
  pageSize: 20,
  realName: '',
  status: undefined as 'pending' | 'approved' | 'rejected' | 'all' | undefined,
})

// 实名认证 Tab 配置
const verificationTabOptions = computed(() => [
  { value: 'all', label: '全部', count: verificationStats.value?.total ?? 0 },
  { value: 'pending', label: '待审核', count: verificationStats.value?.pending ?? 0 },
  { value: 'approved', label: '已通过', count: verificationStats.value?.approved ?? 0 },
  { value: 'rejected', label: '已拒绝', count: verificationStats.value?.rejected ?? 0 },
])

// 批量选择（实名认证）
const selectedVerificationIds = ref<string[]>([])
const selectAllVerifications = ref(false)

// 审核弹窗
const showAuditDialog = ref(false)
const currentVerification = ref<UserVerification | null>(null)
const auditForm = reactive({
  status: 'approved' as 'approved' | 'rejected',
  rejectReason: '',
})
const auditLoading = ref(false)
const isBatchAudit = ref(false)

async function getVerificationList() {
  verificationLoading.value = true
  try {
    // 根据 tab 决定 status 参数
    const statusParam =
      verificationActiveTab.value === 'all'
        ? undefined
        : (verificationActiveTab.value as 'pending' | 'approved' | 'rejected')

    const params = {
      ...verificationQuery,
      status: statusParam,
    }
    const res = await listVerifications(params)
    verificationList.value = res.list
    verificationTotal.value = res.total
    selectedVerificationIds.value = []
    selectAllVerifications.value = false
  } finally {
    verificationLoading.value = false
  }
}

async function loadVerificationStats() {
  try {
    verificationStats.value = await getVerificationStats()
  } catch {
    // ignore
  }
}

function handleVerificationQuery() {
  verificationQuery.pageNum = 1
  getVerificationList()
}

function resetVerificationQuery() {
  verificationQuery.realName = ''
  verificationQuery.status = undefined
  verificationActiveTab.value = 'all'
  handleVerificationQuery()
}

function handleVerificationTabChange(tab: string) {
  verificationActiveTab.value = tab
  verificationQuery.pageNum = 1
  getVerificationList()
}

// 批量选择（实名认证）
function handleSelectVerification(id: string) {
  const index = selectedVerificationIds.value.indexOf(id)
  if (index > -1) {
    selectedVerificationIds.value.splice(index, 1)
  } else {
    selectedVerificationIds.value.push(id)
  }
}

// 只选择待审核的记录
const pendingVerifications = computed(() =>
  verificationList.value.filter((v) => v.status === 'pending'),
)

watch(selectAllVerifications, (newVal) => {
  if (newVal) {
    selectedVerificationIds.value = pendingVerifications.value.map((v) => v.id)
  } else if (selectedVerificationIds.value.length === pendingVerifications.value.length) {
    selectedVerificationIds.value = []
  }
})

watch(
  selectedVerificationIds,
  (newVal) => {
    selectAllVerifications.value =
      pendingVerifications.value.length > 0 && newVal.length === pendingVerifications.value.length
  },
  { deep: true },
)

function openAuditDialog(row: UserVerification) {
  currentVerification.value = row
  auditForm.status = 'approved'
  auditForm.rejectReason = ''
  isBatchAudit.value = false
  showAuditDialog.value = true
}

function openBatchAuditDialog() {
  if (selectedVerificationIds.value.length === 0) {
    toast({ title: '请选择要审核的记录', variant: 'destructive' })
    return
  }
  currentVerification.value = null
  auditForm.status = 'approved'
  auditForm.rejectReason = ''
  isBatchAudit.value = true
  showAuditDialog.value = true
}

async function handleAudit() {
  if (auditForm.status === 'rejected' && !auditForm.rejectReason.trim()) {
    toast({ title: '请填写拒绝原因', variant: 'destructive' })
    return
  }
  auditLoading.value = true
  try {
    if (isBatchAudit.value) {
      await batchAuditVerifications({
        ids: selectedVerificationIds.value,
        status: auditForm.status,
        rejectReason: auditForm.status === 'rejected' ? auditForm.rejectReason : undefined,
      })
      toast({ title: `批量审核成功，共 ${selectedVerificationIds.value.length} 条` })
    } else if (currentVerification.value) {
      await auditVerification(currentVerification.value.id, {
        status: auditForm.status,
        rejectReason: auditForm.status === 'rejected' ? auditForm.rejectReason : undefined,
      })
      toast({ title: '审核成功' })
    }
    showAuditDialog.value = false
    getVerificationList()
    loadVerificationStats()
    loadUserStats()
  } finally {
    auditLoading.value = false
  }
}

function getVerificationStatusBadge(status: string) {
  switch (status) {
    case 'pending':
      return { label: '待审核', variant: 'outline' as const, class: 'text-yellow-600' }
    case 'approved':
      return { label: '已通过', variant: 'default' as const, class: 'bg-green-500' }
    case 'rejected':
      return { label: '已拒绝', variant: 'destructive' as const, class: '' }
    default:
      return { label: status, variant: 'outline' as const, class: '' }
  }
}

function handleTabChange(tab: string) {
  activeTab.value = tab
  if (tab === 'verifications' && verificationList.value.length === 0) {
    getVerificationList()
    loadVerificationStats()
  }
}

onMounted(() => {
  getList()
  loadUserStats()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">App用户管理</h2>
        <p class="text-sm text-muted-foreground">管理寻印 App 的注册用户</p>
      </div>
    </div>

    <Tabs :default-value="activeTab" @update:model-value="(val) => handleTabChange(String(val))">
      <TabsList>
        <TabsTrigger value="users">用户列表</TabsTrigger>
        <TabsTrigger value="verifications">实名认证</TabsTrigger>
      </TabsList>

      <!-- 用户列表 Tab -->
      <TabsContent value="users" class="space-y-4">
        <!-- 统计卡片 -->
        <div class="grid gap-4 md:grid-cols-4" v-if="userStats">
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">总用户数</CardTitle>
              <Users class="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold">{{ userStats.total }}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">已实名</CardTitle>
              <ShieldCheck class="h-4 w-4 text-green-500" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-green-600">{{ userStats.verified }}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">正常状态</CardTitle>
              <UserCheck class="h-4 w-4 text-blue-500" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-blue-600">{{ userStats.active }}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">已禁用</CardTitle>
              <UserX class="h-4 w-4 text-red-500" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-red-600">{{ userStats.disabled }}</div>
            </CardContent>
          </Card>
        </div>

        <!-- 筛选 -->
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
            <Select v-model="queryParams.loginType" @update:model-value="handleQuery">
              <SelectTrigger class="w-[120px]"><SelectValue placeholder="全部" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">全部</SelectItem>
                <SelectItem v-for="opt in loginTypeOptions" :key="opt.value" :value="opt.value">
                  <div class="flex items-center gap-2">
                    <BrandIcon :name="opt.value as any" class="w-4 h-4" :class="opt.color" />
                    {{ opt.label }}
                  </div>
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium">实名</span>
            <Select v-model="queryParams.isVerified" @update:model-value="handleQuery">
              <SelectTrigger class="w-[100px]"><SelectValue placeholder="全部" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">全部</SelectItem>
                <SelectItem value="true">已认证</SelectItem>
                <SelectItem value="false">未认证</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium">状态</span>
            <Select v-model="queryParams.status" @update:model-value="handleQuery">
              <SelectTrigger class="w-[100px]"><SelectValue placeholder="全部" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">全部</SelectItem>
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
            <ExportButton
              v-if="userList.length > 0"
              :formats="['xlsx', 'csv', 'json']"
              :text="selectedIds.length > 0 ? `导出 (${selectedIds.length})` : '导出'"
              @export="handleExport"
            />
          </div>
        </div>

        <!-- 表格 -->
        <div class="border rounded-md bg-card overflow-x-auto">
          <TableSkeleton v-if="loading" :columns="10" :rows="10" show-checkbox />
          <EmptyState v-else-if="userList.length === 0" title="暂无用户数据" />
          <Table v-else class="min-w-[1100px]">
            <TableHeader>
              <TableRow>
                <TableHead class="w-[50px]"><Checkbox v-model="selectAll" /></TableHead>
                <TableHead>用户</TableHead>
                <TableHead>联系方式</TableHead>
                <TableHead>登录方式</TableHead>
                <TableHead>等级/积分</TableHead>
                <TableHead>实名认证</TableHead>
                <TableHead>最后登录</TableHead>
                <TableHead>状态</TableHead>
                <TableHead>注册时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="user in userList" :key="user.id">
                <TableCell>
                  <Checkbox
                    :model-value="selectedIds.includes(user.id)"
                    @update:model-value="() => handleSelectOne(user.id)"
                  />
                </TableCell>
                <TableCell>
                  <div class="flex items-center gap-3">
                    <Avatar class="h-9 w-9">
                      <AvatarImage :src="getResourceUrl(user.avatar)" />
                      <AvatarFallback>{{ user.nickname?.charAt(0) || 'U' }}</AvatarFallback>
                    </Avatar>
                    <div>
                      <span class="font-medium">{{ user.nickname }}</span>
                      <div
                        v-if="user.badgeTitle"
                        class="flex items-center gap-1 text-xs text-muted-foreground"
                      >
                        <Award class="w-3 h-3 text-yellow-500" />{{ user.badgeTitle }}
                      </div>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="space-y-1 text-sm">
                    <div v-if="user.phone" class="flex items-center gap-1">
                      <Smartphone class="w-3 h-3 text-muted-foreground" />{{ user.phone }}
                    </div>
                    <div v-if="user.email" class="flex items-center gap-1">
                      <Mail class="w-3 h-3 text-muted-foreground" />{{ user.email }}
                    </div>
                    <span v-if="!user.phone && !user.email" class="text-muted-foreground">-</span>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="outline" class="gap-1.5">
                    <BrandIcon
                      :name="user.loginType as any"
                      class="w-3.5 h-3.5"
                      :class="getLoginTypeInfo(user.loginType).color"
                    />
                    {{ getLoginTypeInfo(user.loginType).label }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <div class="space-y-1">
                    <div class="text-sm">Lv.{{ user.level }}</div>
                    <div class="flex items-center gap-1 text-xs text-muted-foreground">
                      <Coins class="w-3 h-3 text-amber-500" />{{ user.totalPoints }}
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge v-if="user.isVerified" variant="default" class="bg-green-500"
                    ><ShieldCheck class="w-3 h-3 mr-1" />已认证</Badge
                  >
                  <Badge v-else variant="outline" class="text-muted-foreground">未认证</Badge>
                </TableCell>
                <TableCell>
                  <div v-if="user.lastLoginTime" class="text-sm">
                    <div>{{ formatDate(user.lastLoginTime) }}</div>
                    <div v-if="user.lastLoginIp" class="text-xs text-muted-foreground">
                      {{ user.lastLoginIp }}
                    </div>
                  </div>
                  <span v-else class="text-muted-foreground">-</span>
                </TableCell>
                <TableCell>
                  <StatusSwitch
                    :model-value="user.status"
                    :id="user.id"
                    :name="user.nickname || user.phone"
                    active-text="正常"
                    inactive-text="禁用"
                    @change="handleStatusChange"
                  />
                </TableCell>
                <TableCell>{{ formatDate(user.createTime) }}</TableCell>
                <TableCell class="text-right">
                  <Button variant="ghost" size="icon" @click="handleDetail(user)"
                    ><Eye class="w-4 h-4"
                  /></Button>
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
      </TabsContent>

      <!-- 实名认证 Tab -->
      <TabsContent value="verifications" class="space-y-4">
        <!-- 统计卡片 -->
        <div class="grid gap-4 md:grid-cols-4" v-if="verificationStats">
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">总认证数</CardTitle>
              <FileCheck class="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold">{{ verificationStats.total }}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">待审核</CardTitle>
              <FileClock class="h-4 w-4 text-yellow-500" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-yellow-600">{{ verificationStats.pending }}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">已通过</CardTitle>
              <ShieldCheck class="h-4 w-4 text-green-500" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-green-600">{{ verificationStats.approved }}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">已拒绝</CardTitle>
              <FileX class="h-4 w-4 text-red-500" />
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-red-600">{{ verificationStats.rejected }}</div>
            </CardContent>
          </Card>
        </div>

        <!-- 状态标签页 -->
        <Tabs
          :model-value="verificationActiveTab"
          @update:model-value="(val) => handleVerificationTabChange(String(val))"
        >
          <TabsList class="grid w-full grid-cols-4 lg:w-[400px]">
            <TabsTrigger v-for="tab in verificationTabOptions" :key="tab.value" :value="tab.value">
              {{ tab.label }}
              <Badge variant="secondary" class="ml-1.5 px-1.5 py-0.5 text-xs">
                {{ tab.count }}
              </Badge>
            </TabsTrigger>
          </TabsList>
        </Tabs>

        <!-- 筛选 -->
        <div
          class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
        >
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium">真实姓名</span>
            <Input
              v-model="verificationQuery.realName"
              placeholder="请输入"
              class="w-[130px]"
              @keyup.enter="handleVerificationQuery"
            />
          </div>
          <div class="flex gap-2 ml-auto">
            <Button
              v-if="selectedVerificationIds.length > 0"
              variant="default"
              @click="openBatchAuditDialog"
            >
              <UserCheck class="w-4 h-4 mr-2" />批量审核 ({{ selectedVerificationIds.length }})
            </Button>
            <Button @click="handleVerificationQuery"><Search class="w-4 h-4 mr-2" />搜索</Button>
            <Button variant="outline" @click="resetVerificationQuery"
              ><RefreshCw class="w-4 h-4 mr-2" />重置</Button
            >
          </div>
        </div>

        <!-- 表格 -->
        <div class="border rounded-md bg-card overflow-x-auto">
          <TableSkeleton v-if="verificationLoading" :columns="8" :rows="10" show-checkbox />
          <EmptyState v-else-if="verificationList.length === 0" title="暂无认证记录" />
          <Table v-else class="min-w-[1000px]">
            <TableHeader>
              <TableRow>
                <TableHead class="w-[50px]">
                  <Checkbox
                    v-model="selectAllVerifications"
                    :disabled="pendingVerifications.length === 0"
                  />
                </TableHead>
                <TableHead>用户</TableHead>
                <TableHead>真实姓名</TableHead>
                <TableHead>身份证号</TableHead>
                <TableHead>证件照片</TableHead>
                <TableHead>状态</TableHead>
                <TableHead>提交时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="item in verificationList" :key="item.id">
                <TableCell>
                  <Checkbox
                    v-if="item.status === 'pending'"
                    :model-value="selectedVerificationIds.includes(item.id)"
                    @update:model-value="() => handleSelectVerification(item.id)"
                  />
                </TableCell>
                <TableCell>
                  <div v-if="item.user" class="flex items-center gap-2">
                    <Avatar class="h-8 w-8">
                      <AvatarImage :src="getResourceUrl(item.user.avatar)" />
                      <AvatarFallback>{{ item.user.nickname?.charAt(0) || 'U' }}</AvatarFallback>
                    </Avatar>
                    <div>
                      <div class="font-medium">{{ item.user.nickname }}</div>
                      <div class="text-xs text-muted-foreground">
                        {{ item.user.phone || item.user.email || '-' }}
                      </div>
                    </div>
                  </div>
                </TableCell>
                <TableCell>{{ item.realName }}</TableCell>
                <TableCell>
                  <span class="font-mono">{{
                    item.idCardNo.replace(/^(.{6})(.*)(.{4})$/, '$1****$3')
                  }}</span>
                </TableCell>
                <TableCell>
                  <div class="flex gap-2">
                    <img
                      v-if="item.idCardFront"
                      :src="getResourceUrl(item.idCardFront)"
                      class="w-16 h-10 object-cover rounded cursor-pointer hover:opacity-80 transition-opacity"
                      @click="openImagePreview([item.idCardFront, item.idCardBack], 0)"
                    />
                    <img
                      v-if="item.idCardBack"
                      :src="getResourceUrl(item.idCardBack)"
                      class="w-16 h-10 object-cover rounded cursor-pointer hover:opacity-80 transition-opacity"
                      @click="openImagePreview([item.idCardFront, item.idCardBack], 1)"
                    />
                    <span v-if="!item.idCardFront && !item.idCardBack" class="text-muted-foreground"
                      >-</span
                    >
                  </div>
                </TableCell>
                <TableCell>
                  <Badge
                    :variant="getVerificationStatusBadge(item.status).variant"
                    :class="getVerificationStatusBadge(item.status).class"
                  >
                    {{ getVerificationStatusBadge(item.status).label }}
                  </Badge>
                  <div
                    v-if="item.status === 'rejected' && item.rejectReason"
                    class="text-xs text-red-500 mt-1"
                  >
                    {{ item.rejectReason }}
                  </div>
                </TableCell>
                <TableCell>{{ formatDate(item.createTime) }}</TableCell>
                <TableCell class="text-right">
                  <Button
                    v-if="item.status === 'pending'"
                    variant="outline"
                    size="sm"
                    @click="openAuditDialog(item)"
                  >
                    <UserCheck class="w-4 h-4 mr-1" />审核
                  </Button>
                  <span v-else class="text-muted-foreground text-sm">{{
                    item.verifiedAt ? formatDate(item.verifiedAt) : '-'
                  }}</span>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
        <TablePagination
          v-model:page-num="verificationQuery.pageNum"
          v-model:page-size="verificationQuery.pageSize"
          :total="verificationTotal"
          @change="getVerificationList"
        />
      </TabsContent>
    </Tabs>

    <!-- 用户详情弹窗 -->
    <Dialog v-model:open="showDetailDialog">
      <DialogContent class="sm:max-w-[550px]">
        <DialogHeader>
          <DialogTitle>用户详情</DialogTitle>
          <DialogDescription>查看 App 用户的详细信息</DialogDescription>
        </DialogHeader>
        <div v-if="detailLoading" class="py-8 text-center text-muted-foreground">加载中...</div>
        <div v-else-if="currentUser" class="space-y-6 py-4 max-h-[60vh] overflow-y-auto">
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
                <Award class="w-4 h-4 text-yellow-500" />{{ currentUser.badgeTitle }}
              </div>
              <div class="flex items-center gap-2 mt-1">
                <Badge v-if="currentUser.isVerified" variant="default" class="bg-green-500 text-xs">
                  <ShieldCheck class="w-3 h-3 mr-1" />已实名
                </Badge>
                <Badge variant="outline" class="text-xs">Lv.{{ currentUser.level }}</Badge>
              </div>
            </div>
          </div>

          <!-- 详细信息 -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Smartphone class="w-4 h-4" />手机号
              </div>
              <div class="font-medium">{{ currentUser.phone || '-' }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Mail class="w-4 h-4" />邮箱
              </div>
              <div class="font-medium">{{ currentUser.email || '-' }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground">性别</div>
              <div class="font-medium">
                {{ currentUser.gender ? genderOptions[currentUser.gender] : '-' }}
              </div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground">生日</div>
              <div class="font-medium">
                {{ currentUser.birthday ? formatDate(currentUser.birthday, 'YYYY-MM-DD') : '-' }}
              </div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Coins class="w-4 h-4" />总积分
              </div>
              <div class="font-medium text-amber-600">{{ currentUser.totalPoints }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground">状态</div>
              <Badge :variant="currentUser.status === '0' ? 'default' : 'destructive'">{{
                currentUser.status === '0' ? '正常' : '禁用'
              }}</Badge>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground">邀请码</div>
              <div class="font-medium font-mono">{{ currentUser.inviteCode || '-' }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground">邀请人</div>
              <div class="font-medium">{{ currentUser.invitedBy || '-' }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Calendar class="w-4 h-4" />注册时间
              </div>
              <div class="font-medium">{{ formatDate(currentUser.createTime) }}</div>
            </div>
            <div class="space-y-1">
              <div class="text-sm text-muted-foreground flex items-center gap-1">
                <Clock class="w-4 h-4" />最后登录
              </div>
              <div class="font-medium">
                {{ currentUser.lastLoginTime ? formatDate(currentUser.lastLoginTime) : '-' }}
              </div>
            </div>
          </div>

          <!-- 个人简介 -->
          <div v-if="currentUser.bio" class="pt-4 border-t">
            <h4 class="text-sm font-medium mb-2">个人简介</h4>
            <p class="text-sm text-muted-foreground">{{ currentUser.bio }}</p>
          </div>

          <!-- 登录方式信息 -->
          <div class="pt-4 border-t">
            <h4 class="text-sm font-medium mb-3">登录方式</h4>
            <Badge variant="outline" class="mb-3 gap-1.5">
              <BrandIcon
                :name="currentUser.loginType as any"
                class="w-4 h-4"
                :class="getLoginTypeInfo(currentUser.loginType).color"
              />
              {{ getLoginTypeInfo(currentUser.loginType).label }}
            </Badge>
            <div class="space-y-2 text-sm text-muted-foreground">
              <div v-if="currentUser.openId">
                <span class="text-foreground">微信 OpenID:</span> {{ currentUser.openId }}
              </div>
              <div v-if="currentUser.unionId">
                <span class="text-foreground">微信 UnionID:</span> {{ currentUser.unionId }}
              </div>
              <div v-if="currentUser.googleId">
                <span class="text-foreground">Google ID:</span> {{ currentUser.googleId }}
              </div>
              <div v-if="currentUser.appleId">
                <span class="text-foreground">Apple ID:</span> {{ currentUser.appleId }}
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- 审核弹窗 -->
    <Dialog v-model:open="showAuditDialog">
      <DialogContent class="sm:max-w-[450px]">
        <DialogHeader>
          <DialogTitle>{{ isBatchAudit ? '批量审核实名认证' : '审核实名认证' }}</DialogTitle>
          <DialogDescription>
            {{
              isBatchAudit
                ? `已选择 ${selectedVerificationIds.length} 条待审核记录`
                : '请审核用户提交的实名认证信息'
            }}
          </DialogDescription>
        </DialogHeader>
        <div class="space-y-4 py-4">
          <!-- 单条审核时显示用户信息 -->
          <div
            v-if="!isBatchAudit && currentVerification"
            class="flex items-center gap-3 p-3 bg-muted rounded-lg"
          >
            <Avatar v-if="currentVerification.user" class="h-10 w-10">
              <AvatarImage :src="getResourceUrl(currentVerification.user.avatar)" />
              <AvatarFallback>{{
                currentVerification.user.nickname?.charAt(0) || 'U'
              }}</AvatarFallback>
            </Avatar>
            <div>
              <div class="font-medium">{{ currentVerification.user?.nickname }}</div>
              <div class="text-sm text-muted-foreground">
                {{ currentVerification.realName }} |
                {{ currentVerification.idCardNo.replace(/^(.{6})(.*)(.{4})$/, '$1****$3') }}
              </div>
            </div>
          </div>

          <!-- 单条审核时显示证件照片 -->
          <div
            v-if="
              !isBatchAudit &&
              currentVerification &&
              (currentVerification.idCardFront || currentVerification.idCardBack)
            "
            class="flex gap-3"
          >
            <img
              v-if="currentVerification.idCardFront"
              :src="getResourceUrl(currentVerification.idCardFront)"
              class="flex-1 h-24 object-cover rounded cursor-pointer hover:opacity-80"
              @click="
                openImagePreview(
                  [currentVerification.idCardFront, currentVerification.idCardBack],
                  0,
                )
              "
            />
            <img
              v-if="currentVerification.idCardBack"
              :src="getResourceUrl(currentVerification.idCardBack)"
              class="flex-1 h-24 object-cover rounded cursor-pointer hover:opacity-80"
              @click="
                openImagePreview(
                  [currentVerification.idCardFront, currentVerification.idCardBack],
                  1,
                )
              "
            />
          </div>

          <div class="space-y-3">
            <div class="flex items-center gap-4">
              <span class="text-sm font-medium">审核结果</span>
              <Select v-model="auditForm.status">
                <SelectTrigger class="w-[150px]"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="approved">通过</SelectItem>
                  <SelectItem value="rejected">拒绝</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div v-if="auditForm.status === 'rejected'" class="space-y-2">
              <span class="text-sm font-medium">拒绝原因</span>
              <Input v-model="auditForm.rejectReason" placeholder="请输入拒绝原因" />
            </div>
          </div>

          <div class="flex justify-end gap-2 pt-4">
            <Button variant="outline" @click="showAuditDialog = false">取消</Button>
            <Button :disabled="auditLoading" @click="handleAudit">
              {{ auditLoading ? '提交中...' : '确认' }}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- 图片预览弹窗 -->
    <Dialog v-model:open="showImagePreview">
      <DialogContent class="sm:max-w-[800px] p-0 bg-black/95">
        <div class="relative">
          <Button
            variant="ghost"
            size="icon"
            class="absolute top-2 right-2 z-10 text-white hover:bg-white/20"
            @click="showImagePreview = false"
          >
            <X class="w-5 h-5" />
          </Button>
          <div class="flex items-center justify-center min-h-[400px] p-4">
            <img
              :src="previewImages[currentImageIndex]"
              class="max-w-full max-h-[70vh] object-contain"
            />
          </div>
          <!-- 导航按钮 -->
          <div
            v-if="previewImages.length > 1"
            class="absolute inset-y-0 left-0 right-0 flex items-center justify-between px-2 pointer-events-none"
          >
            <Button
              variant="ghost"
              size="icon"
              class="pointer-events-auto text-white hover:bg-white/20 disabled:opacity-30"
              :disabled="currentImageIndex === 0"
              @click="prevImage"
            >
              <ChevronLeft class="w-6 h-6" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              class="pointer-events-auto text-white hover:bg-white/20 disabled:opacity-30"
              :disabled="currentImageIndex === previewImages.length - 1"
              @click="nextImage"
            >
              <ChevronRight class="w-6 h-6" />
            </Button>
          </div>
          <!-- 图片指示器 -->
          <div
            v-if="previewImages.length > 1"
            class="absolute bottom-4 left-0 right-0 flex justify-center gap-2"
          >
            <span
              v-for="(_, idx) in previewImages"
              :key="idx"
              class="w-2 h-2 rounded-full transition-colors"
              :class="idx === currentImageIndex ? 'bg-white' : 'bg-white/40'"
            />
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>
