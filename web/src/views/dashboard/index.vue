<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Users,
  MapPin,
  Route,
  Award,
  CheckCircle,
  Link2,
  TrendingUp,
  Calendar,
  BarChart3,
  LineChart,
  ArrowUpRight,
  Activity,
} from 'lucide-vue-next'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Skeleton } from '@/components/ui/skeleton'
import {
  getDashboardStats,
  getDashboardTrends,
  type DashboardStats,
  type DashboardTrends,
} from '@/api/xunyin/dashboard'
import SimpleChart from '@/components/common/SimpleChart.vue'

const router = useRouter()
const loading = ref(true)
const stats = ref<DashboardStats | null>(null)
const trends = ref<DashboardTrends | null>(null)
const trendDays = ref('7')
const chartType = ref<'bar' | 'line'>('bar')

// 统计卡片配置
const statCards = computed(() => {
  if (!stats.value) return []
  return [
    {
      title: 'App用户总数',
      value: stats.value.totalUsers,
      icon: Users,
      color: 'text-blue-500',
      bg: 'bg-blue-500/10',
      link: '/xunyin/appuser',
    },
    {
      title: '城市数量',
      value: stats.value.totalCities,
      icon: MapPin,
      color: 'text-green-500',
      bg: 'bg-green-500/10',
      link: '/xunyin/city',
    },
    {
      title: '文化之旅数量',
      value: stats.value.totalJourneys,
      icon: Route,
      color: 'text-purple-500',
      bg: 'bg-purple-500/10',
      link: '/xunyin/journey',
    },
    {
      title: '印记数量',
      value: stats.value.totalSeals,
      icon: Award,
      color: 'text-yellow-500',
      bg: 'bg-yellow-500/10',
      link: '/xunyin/seal',
    },
    {
      title: '完成文化之旅总数',
      value: stats.value.totalCompletedJourneys,
      icon: CheckCircle,
      color: 'text-emerald-500',
      bg: 'bg-emerald-500/10',
    },
    {
      title: '上链印记总数',
      value: stats.value.totalChainedSeals,
      icon: Link2,
      color: 'text-orange-500',
      bg: 'bg-orange-500/10',
    },
    {
      title: '今日新增用户',
      value: stats.value.todayNewUsers,
      icon: TrendingUp,
      color: 'text-pink-500',
      bg: 'bg-pink-500/10',
      highlight: true,
    },
    {
      title: '今日完成文化之旅',
      value: stats.value.todayCompletedJourneys,
      icon: Calendar,
      color: 'text-cyan-500',
      bg: 'bg-cyan-500/10',
      highlight: true,
    },
  ]
})

// 格式化日期为 MM-DD
const formatDateLabel = (dateStr: string) => {
  const date = new Date(dateStr)
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${month}-${day}`
}

// 图表数据
const userChartData = computed(() => {
  if (!trends.value?.userTrends) return []
  return trends.value.userTrends.map((t) => ({
    label: formatDateLabel(t.date),
    value: t.count,
  }))
})

const journeyChartData = computed(() => {
  if (!trends.value?.journeyTrends) return []
  return trends.value.journeyTrends.map((t) => ({
    label: formatDateLabel(t.date),
    value: t.count,
  }))
})

const chainChartData = computed(() => {
  if (!trends.value?.chainTrends) return []
  return trends.value.chainTrends.map((t) => ({
    label: formatDateLabel(t.date),
    value: t.count,
  }))
})

// 快捷入口
const quickLinks = [
  { title: '城市管理', icon: MapPin, path: '/xunyin/city', color: 'text-green-500' },
  { title: '文化之旅', icon: Route, path: '/xunyin/journey', color: 'text-purple-500' },
  { title: '探索点', icon: Activity, path: '/xunyin/point', color: 'text-blue-500' },
  { title: '印记管理', icon: Award, path: '/xunyin/seal', color: 'text-yellow-500' },
  { title: 'App用户', icon: Users, path: '/xunyin/appuser', color: 'text-pink-500' },
  { title: '数据统计', icon: BarChart3, path: '/xunyin/dashboard', color: 'text-cyan-500' },
]

function goTo(path: string) {
  router.push(path)
}

async function fetchStats() {
  try {
    stats.value = await getDashboardStats()
  } catch {
    // 使用默认值
    stats.value = {
      totalUsers: 0,
      totalCities: 0,
      totalJourneys: 0,
      totalSeals: 0,
      totalCompletedJourneys: 0,
      totalChainedSeals: 0,
      todayNewUsers: 0,
      todayCompletedJourneys: 0,
    }
  }
}

async function fetchTrends() {
  try {
    trends.value = await getDashboardTrends(Number(trendDays.value))
  } catch {
    trends.value = { userTrends: [], journeyTrends: [], chainTrends: [] }
  }
}

async function handleTrendDaysChange() {
  await fetchTrends()
}

onMounted(async () => {
  loading.value = true
  await Promise.all([fetchStats(), fetchTrends()])
  loading.value = false
})
</script>

<template>
  <div class="flex min-h-screen w-full flex-col">
    <main class="flex flex-1 flex-col gap-4 p-4 sm:p-6 md:gap-6">
      <!-- 页面标题 -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold tracking-tight">工作台</h2>
          <p class="text-muted-foreground">寻印 App 运营数据概览</p>
        </div>
      </div>

      <!-- 统计卡片 -->
      <div class="grid gap-4 grid-cols-2 lg:grid-cols-4">
        <template v-if="loading">
          <Card v-for="i in 8" :key="i">
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <Skeleton class="h-4 w-20" />
              <Skeleton class="h-8 w-8 rounded-full" />
            </CardHeader>
            <CardContent>
              <Skeleton class="h-8 w-16" />
            </CardContent>
          </Card>
        </template>
        <template v-else>
          <Card
            v-for="(card, index) in statCards"
            :key="index"
            :class="[
              'transition-all hover:shadow-md',
              card.link ? 'cursor-pointer hover:border-primary/50' : '',
              card.highlight ? 'border-primary/30 bg-primary/5' : '',
            ]"
            @click="card.link && goTo(card.link)"
          >
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle class="text-sm font-medium">{{ card.title }}</CardTitle>
              <div :class="[card.bg, 'p-2 rounded-full']">
                <component :is="card.icon" :class="['h-4 w-4', card.color]" />
              </div>
            </CardHeader>
            <CardContent>
              <div class="flex items-center justify-between">
                <div class="text-2xl font-bold">{{ card.value?.toLocaleString() || 0 }}</div>
                <ArrowUpRight v-if="card.link" class="h-4 w-4 text-muted-foreground" />
              </div>
            </CardContent>
          </Card>
        </template>
      </div>

      <div class="grid gap-4 lg:grid-cols-3">
        <!-- 数据趋势图表 -->
        <Card class="lg:col-span-2">
          <CardHeader>
            <div class="flex items-center justify-between">
              <div>
                <CardTitle>数据趋势</CardTitle>
                <CardDescription>查看各项数据的变化趋势</CardDescription>
              </div>
              <div class="flex items-center gap-2">
                <div class="flex items-center border rounded-md">
                  <button
                    class="p-2 rounded-l-md transition-colors"
                    :class="
                      chartType === 'bar' ? 'bg-primary text-primary-foreground' : 'hover:bg-muted'
                    "
                    @click="chartType = 'bar'"
                  >
                    <BarChart3 class="h-4 w-4" />
                  </button>
                  <button
                    class="p-2 rounded-r-md transition-colors"
                    :class="
                      chartType === 'line' ? 'bg-primary text-primary-foreground' : 'hover:bg-muted'
                    "
                    @click="chartType = 'line'"
                  >
                    <LineChart class="h-4 w-4" />
                  </button>
                </div>
                <Select v-model="trendDays" @update:model-value="handleTrendDaysChange">
                  <SelectTrigger class="w-[100px]"><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="7">近7天</SelectItem>
                    <SelectItem value="14">近14天</SelectItem>
                    <SelectItem value="30">近30天</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <Tabs default-value="users" class="w-full">
              <TabsList class="grid w-full grid-cols-3">
                <TabsTrigger value="users">用户增长</TabsTrigger>
                <TabsTrigger value="journeys">文化之旅完成</TabsTrigger>
                <TabsTrigger value="chains">印记上链</TabsTrigger>
              </TabsList>
              <TabsContent value="users" class="pt-4">
                <div v-if="loading" class="h-[200px] flex items-center justify-center">
                  <Skeleton class="h-full w-full" />
                </div>
                <div v-else-if="userChartData.length > 0">
                  <SimpleChart
                    :data="userChartData"
                    :type="chartType"
                    color="#3b82f6"
                    :height="200"
                  />
                </div>
                <div v-else class="text-center text-muted-foreground py-12">暂无数据</div>
              </TabsContent>
              <TabsContent value="journeys" class="pt-4">
                <div v-if="loading" class="h-[200px] flex items-center justify-center">
                  <Skeleton class="h-full w-full" />
                </div>
                <div v-else-if="journeyChartData.length > 0">
                  <SimpleChart
                    :data="journeyChartData"
                    :type="chartType"
                    color="#8b5cf6"
                    :height="200"
                  />
                </div>
                <div v-else class="text-center text-muted-foreground py-12">暂无数据</div>
              </TabsContent>
              <TabsContent value="chains" class="pt-4">
                <div v-if="loading" class="h-[200px] flex items-center justify-center">
                  <Skeleton class="h-full w-full" />
                </div>
                <div v-else-if="chainChartData.length > 0">
                  <SimpleChart
                    :data="chainChartData"
                    :type="chartType"
                    color="#f97316"
                    :height="200"
                  />
                </div>
                <div v-else class="text-center text-muted-foreground py-12">暂无数据</div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>

        <!-- 快捷入口 -->
        <Card>
          <CardHeader>
            <CardTitle>快捷入口</CardTitle>
            <CardDescription>常用功能快速访问</CardDescription>
          </CardHeader>
          <CardContent>
            <div class="grid grid-cols-2 gap-3">
              <Button
                v-for="link in quickLinks"
                :key="link.path"
                variant="outline"
                class="h-auto py-4 flex-col gap-2 hover:border-primary/50"
                @click="goTo(link.path)"
              >
                <component :is="link.icon" :class="['h-5 w-5', link.color]" />
                <span class="text-xs">{{ link.title }}</span>
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </main>
  </div>
</template>
