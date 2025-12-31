<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
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
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { useToast } from '@/components/ui/toast/use-toast'
import {
  Plus,
  Search,
  Trash2,
  Loader2,
  RefreshCw,
  Edit,
  Route,
  MapPin,
  Image as ImageIcon,
  Copy,
} from 'lucide-vue-next'
import RichTextEditor from '@/components/common/RichTextEditor.vue'
import {
  listCity,
  getCity,
  delCity,
  addCity,
  updateCity,
  updateCityStatus,
  type City,
  type CityForm,
} from '@/api/xunyin/city'
import TablePagination from '@/components/common/TablePagination.vue'
import TableSkeleton from '@/components/common/TableSkeleton.vue'
import EmptyState from '@/components/common/EmptyState.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import ProvinceCitySelect from '@/components/common/ProvinceCitySelect.vue'
import ImageUpload from '@/components/common/ImageUpload.vue'
import AudioUpload from '@/components/common/AudioUpload.vue'
import StatusSwitch from '@/components/common/StatusSwitch.vue'
import MapPicker from '@/components/common/MapPicker.vue'
import ExportButton from '@/components/common/ExportButton.vue'
import { exportToCsv, exportToJson, exportToExcel, getExportFilename } from '@/utils/export'
import { getResourceUrl } from '@/utils/url'

const router = useRouter()
const loading = ref(true)
const cityList = ref<City[]>([])
const total = ref(0)
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: '',
  province: '',
  status: undefined as string | undefined,
})

const showDialog = ref(false)
const showDeleteDialog = ref(false)
const cityToDelete = ref<City | null>(null)
const isEdit = ref(false)
const submitLoading = ref(false)

// 批量选择
const selectedIds = ref<string[]>([])
const showBatchDeleteDialog = ref(false)
const showMapPicker = ref(false)

const form = reactive<CityForm>({
  name: '',
  province: '',
  latitude: 0,
  longitude: 0,
  iconAsset: '',
  coverImage: '',
  description: '',
  bgmUrl: '',
  orderNum: 0,
  status: '0',
})

const { toast } = useToast()

async function getList() {
  loading.value = true
  try {
    const res = await listCity(queryParams)
    cityList.value = res.list
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
  queryParams.name = ''
  queryParams.province = ''
  queryParams.status = undefined
  handleQuery()
}

function resetForm() {
  form.id = undefined
  form.name = ''
  form.province = ''
  form.latitude = 0
  form.longitude = 0
  form.iconAsset = ''
  form.coverImage = ''
  form.description = ''
  form.bgmUrl = ''
  form.orderNum = 0
  form.status = '0'
}

function handleAdd() {
  resetForm()
  isEdit.value = false
  showDialog.value = true
}

function handleProvinceCityChange(data: {
  province: string
  city: string
  latitude?: number
  longitude?: number
}) {
  form.province = data.province
  form.name = data.city
  if (data.latitude !== undefined) {
    form.latitude = data.latitude
  }
  if (data.longitude !== undefined) {
    form.longitude = data.longitude
  }
}

async function handleUpdate(row: City) {
  resetForm()
  isEdit.value = true
  const data = await getCity(row.id)
  Object.assign(form, data)
  showDialog.value = true
}

// 经纬度校验
function validateCoordinates(): boolean {
  if (form.longitude < -180 || form.longitude > 180) {
    toast({ title: '经度范围应在 -180 到 180 之间', variant: 'destructive' })
    return false
  }
  if (form.latitude < -90 || form.latitude > 90) {
    toast({ title: '纬度范围应在 -90 到 90 之间', variant: 'destructive' })
    return false
  }
  return true
}

async function handleSubmit() {
  if (!form.name || !form.province) {
    toast({ title: '请填写必填项', variant: 'destructive' })
    return
  }
  if (!validateCoordinates()) return

  submitLoading.value = true
  try {
    if (form.id) {
      await updateCity(form)
      toast({ title: '修改成功' })
    } else {
      await addCity(form)
      toast({ title: '新增成功' })
    }
    showDialog.value = false
    getList()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: City) {
  // 检查是否有关联的文化之旅
  if (row.journeyCount && row.journeyCount > 0) {
    toast({
      title: '无法删除',
      description: `该城市下有 ${row.journeyCount} 条文化之旅，请先删除关联数据`,
      variant: 'destructive',
    })
    return
  }
  cityToDelete.value = row
  showDeleteDialog.value = true
}

async function confirmDelete() {
  if (!cityToDelete.value) return
  try {
    await delCity(cityToDelete.value.id)
    toast({ title: '删除成功' })
    getList()
    showDeleteDialog.value = false
  } catch {}
}

// 批量删除
function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    toast({ title: '请选择要删除的数据', variant: 'destructive' })
    return
  }
  // 检查是否有关联数据
  const hasRelated = cityList.value
    .filter((c) => selectedIds.value.includes(c.id))
    .some((c) => c.journeyCount && c.journeyCount > 0)
  if (hasRelated) {
    toast({
      title: '无法删除',
      description: '选中的城市中有关联文化之旅的数据，请先删除关联数据',
      variant: 'destructive',
    })
    return
  }
  showBatchDeleteDialog.value = true
}

async function confirmBatchDelete() {
  try {
    await Promise.all(selectedIds.value.map((id) => delCity(id)))
    toast({ title: `成功删除 ${selectedIds.value.length} 条数据` })
    getList()
    showBatchDeleteDialog.value = false
  } catch {}
}

// 全选
function handleSelectAll(checked: boolean) {
  selectedIds.value = checked ? cityList.value.map((c) => c.id) : []
}

function handleSelectOne(id: string, checked: boolean) {
  if (checked) {
    selectedIds.value.push(id)
  } else {
    selectedIds.value = selectedIds.value.filter((i) => i !== id)
  }
}

// 跳转到文化之旅页面并筛选
function goToJourneys(cityId: string) {
  router.push({ path: '/xunyin/journey', query: { cityId } })
}

// 状态切换
async function handleStatusChange(id: string, status: string) {
  await updateCityStatus(id, status)
  toast({ title: '状态更新成功' })
  // 更新本地数据
  const city = cityList.value.find((c) => c.id === id)
  if (city) city.status = status
}

// 复制数据
async function handleCopy(row: City) {
  resetForm()
  const data = await getCity(row.id)
  Object.assign(form, data)
  form.id = undefined
  form.name = `${data.name} (副本)`
  isEdit.value = false
  showDialog.value = true
}

// 地图选点回调
function handleMapPickerConfirm(data: { latitude: number; longitude: number; address?: string }) {
  form.latitude = data.latitude
  form.longitude = data.longitude
}

// 导出
function handleExport(format: 'xlsx' | 'csv' | 'json') {
  const filename = getExportFilename('城市数据')
  const columns = [
    { key: 'name' as const, label: '城市名称' },
    { key: 'province' as const, label: '省份' },
    { key: 'longitude' as const, label: '经度' },
    { key: 'latitude' as const, label: '纬度' },
    { key: 'explorerCount' as const, label: '探索人数' },
    { key: 'journeyCount' as const, label: '文化之旅数' },
    { key: 'orderNum' as const, label: '排序号' },
    { key: 'status' as const, label: '状态' },
  ]
  if (format === 'xlsx') {
    exportToExcel(cityList.value, columns, filename, '城市数据')
  } else if (format === 'csv') {
    exportToCsv(cityList.value, columns, filename)
  } else {
    exportToJson(cityList.value, filename)
  }
}

onMounted(() => {
  getList()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">城市管理</h2>
        <p class="text-sm text-muted-foreground">管理寻印 App 中的城市数据</p>
      </div>
      <div class="flex gap-2">
        <ExportButton
          v-if="cityList.length > 0"
          :formats="['xlsx', 'csv', 'json']"
          @export="handleExport"
        />
        <Button
          v-if="selectedIds.length > 0"
          variant="destructive"
          size="sm"
          @click="handleBatchDelete"
        >
          <Trash2 class="h-4 w-4 mr-2" />批量删除 ({{ selectedIds.length }})
        </Button>
        <Button size="sm" @click="handleAdd"> <Plus class="h-4 w-4 mr-2" />新增城市 </Button>
      </div>
    </div>

    <div
      class="flex flex-wrap gap-3 sm:gap-4 items-center bg-background/95 p-3 sm:p-4 border rounded-lg"
    >
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">城市名称</span>
        <Input
          v-model="queryParams.name"
          placeholder="请输入"
          class="w-[150px]"
          @keyup.enter="handleQuery"
        />
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm font-medium">省份</span>
        <Input
          v-model="queryParams.province"
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
            <SelectItem value="0">正常</SelectItem>
            <SelectItem value="1">停用</SelectItem>
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
      <TableSkeleton v-if="loading" :columns="9" :rows="10" />
      <EmptyState
        v-else-if="cityList.length === 0"
        title="暂无城市数据"
        description="点击新增城市按钮添加"
        action-text="新增城市"
        @action="handleAdd"
      />
      <Table v-else class="min-w-[1000px]">
        <TableHeader>
          <TableRow>
            <TableHead class="w-[50px]">
              <Checkbox
                :checked="selectedIds.length === cityList.length && cityList.length > 0"
                @update:checked="handleSelectAll"
              />
            </TableHead>
            <TableHead>城市</TableHead>
            <TableHead>省份</TableHead>
            <TableHead>坐标</TableHead>
            <TableHead>文化之旅</TableHead>
            <TableHead>探索人数</TableHead>
            <TableHead>排序</TableHead>
            <TableHead>状态</TableHead>
            <TableHead class="text-right">操作</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="city in cityList" :key="city.id">
            <TableCell>
              <Checkbox
                :checked="selectedIds.includes(city.id)"
                @update:checked="(checked: boolean) => handleSelectOne(city.id, checked)"
              />
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-3">
                <TooltipProvider v-if="city.coverImage || city.iconAsset">
                  <Tooltip>
                    <TooltipTrigger>
                      <img
                        :src="getResourceUrl(city.coverImage || city.iconAsset)"
                        :alt="city.name"
                        class="w-10 h-10 rounded-lg object-cover border"
                      />
                    </TooltipTrigger>
                    <TooltipContent side="right" class="p-0">
                      <img
                        :src="getResourceUrl(city.coverImage || city.iconAsset)"
                        :alt="city.name"
                        class="max-w-[200px] max-h-[200px] rounded-lg"
                      />
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
                <div v-else class="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                  <ImageIcon class="w-5 h-5 text-muted-foreground" />
                </div>
                <span class="font-medium">{{ city.name }}</span>
              </div>
            </TableCell>
            <TableCell>{{ city.province }}</TableCell>
            <TableCell>
              <div class="flex items-center gap-1 text-sm text-muted-foreground">
                <MapPin class="w-3 h-3" />
                {{ city.longitude.toFixed(4) }}, {{ city.latitude.toFixed(4) }}
              </div>
            </TableCell>
            <TableCell>
              <Button
                v-if="city.journeyCount"
                variant="link"
                size="sm"
                class="h-auto p-0 text-primary"
                @click="goToJourneys(city.id)"
              >
                <Route class="w-3 h-3 mr-1" />{{ city.journeyCount }} 条
              </Button>
              <span v-else class="text-muted-foreground">-</span>
            </TableCell>
            <TableCell>{{ city.explorerCount }}</TableCell>
            <TableCell>{{ city.orderNum }}</TableCell>
            <TableCell>
              <StatusSwitch :model-value="city.status" :id="city.id" @change="handleStatusChange" />
            </TableCell>
            <TableCell class="text-right space-x-1">
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger as-child>
                    <Button variant="ghost" size="icon" @click="handleCopy(city)">
                      <Copy class="w-4 h-4" />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>复制</TooltipContent>
                </Tooltip>
              </TooltipProvider>
              <Button variant="ghost" size="icon" @click="handleUpdate(city)"
                ><Edit class="w-4 h-4"
              /></Button>
              <Button
                variant="ghost"
                size="icon"
                class="text-destructive"
                @click="handleDelete(city)"
                ><Trash2 class="w-4 h-4"
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

    <Dialog v-model:open="showDialog">
      <DialogContent class="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{{ isEdit ? '修改城市' : '新增城市' }}</DialogTitle>
          <DialogDescription>请填写城市信息</DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <ProvinceCitySelect
            :province="form.province"
            :city="form.name"
            show-label
            @change="handleProvinceCityChange"
          />
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>经度 (-180 ~ 180)</Label>
              <Input
                v-model.number="form.longitude"
                type="number"
                step="0.0000001"
                min="-180"
                max="180"
                placeholder="如 120.1551234"
              />
            </div>
            <div class="grid gap-2">
              <Label>纬度 (-90 ~ 90)</Label>
              <Input
                v-model.number="form.latitude"
                type="number"
                step="0.0000001"
                min="-90"
                max="90"
                placeholder="如 30.2741234"
              />
            </div>
          </div>
          <Button type="button" variant="outline" size="sm" @click="showMapPicker = true">
            <MapPin class="w-4 h-4 mr-2" />地图选点
          </Button>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>图标</Label>
              <ImageUpload v-model="form.iconAsset" placeholder="上传图标" />
            </div>
            <div class="grid gap-2">
              <Label>封面图片</Label>
              <ImageUpload v-model="form.coverImage" placeholder="上传封面" />
            </div>
          </div>
          <div class="grid gap-2">
            <Label>背景音乐</Label>
            <AudioUpload v-model="form.bgmUrl" placeholder="上传背景音乐" />
          </div>
          <div class="grid gap-2">
            <Label>描述</Label>
            <RichTextEditor v-model="form.description" placeholder="城市描述" />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="grid gap-2">
              <Label>排序号</Label>
              <Input v-model.number="form.orderNum" type="number" />
            </div>
            <div class="grid gap-2">
              <Label>状态</Label>
              <Select v-model="form.status">
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="0">正常</SelectItem>
                  <SelectItem value="1">停用</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showDialog = false">取消</Button>
          <Button @click="handleSubmit" :disabled="submitLoading">
            <Loader2 v-if="submitLoading" class="mr-2 h-4 w-4 animate-spin" />确定
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <ConfirmDialog
      v-model:open="showDeleteDialog"
      title="确认删除"
      :description="`确定要删除城市「${cityToDelete?.name}」吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmDelete"
    />

    <ConfirmDialog
      v-model:open="showBatchDeleteDialog"
      title="确认批量删除"
      :description="`确定要删除选中的 ${selectedIds.length} 个城市吗？`"
      confirm-text="删除"
      destructive
      @confirm="confirmBatchDelete"
    />

    <MapPicker
      v-model:open="showMapPicker"
      :latitude="form.latitude"
      :longitude="form.longitude"
      @confirm="handleMapPickerConfirm"
    />
  </div>
</template>
