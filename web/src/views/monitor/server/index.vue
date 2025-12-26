<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Separator } from '@/components/ui/separator'
import { getServer, type ServerInfo } from '@/api/monitor/server'
import { Loader2, Cpu, Database, HardDrive, RefreshCw, Monitor, Activity } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { toast } from '@/components/ui/toast'

const loading = ref(true)
const server = ref<ServerInfo | null>(null)
const autoRefresh = ref(true)
const refreshInterval = ref<ReturnType<typeof setInterval> | null>(null)
const lastUpdateTime = ref<string>('')

// CPU 总使用率
const cpuTotalUsage = computed(() => {
  if (!server.value) return 0
  const used = Number(server.value.cpu.used) || 0
  const sys = Number(server.value.cpu.sys) || 0
  return Math.min(100, Math.max(0, used + sys))
})

// 根据使用率返回颜色类
function getUsageColor(usage: number): string {
  if (usage >= 90) return 'text-red-500'
  if (usage >= 70) return 'text-yellow-500'
  return 'text-green-500'
}

function getProgressVariant(usage: number): string {
  if (usage >= 90) return 'bg-red-500'
  if (usage >= 70) return 'bg-yellow-500'
  return ''
}

async function getData() {
  loading.value = true
  try {
    const res = await getServer()
    server.value = res
    lastUpdateTime.value = new Date().toLocaleTimeString('zh-CN')
  } catch (error) {
    toast({
      title: '获取服务器信息失败',
      description: '请检查网络连接或稍后重试',
      variant: 'destructive',
    })
  } finally {
    loading.value = false
  }
}

function toggleAutoRefresh() {
  autoRefresh.value = !autoRefresh.value
  if (autoRefresh.value) {
    startAutoRefresh()
    toast({ title: '已开启自动刷新', description: '每 5 秒更新一次' })
  } else {
    stopAutoRefresh()
    toast({ title: '已关闭自动刷新' })
  }
}

function startAutoRefresh() {
  if (refreshInterval.value) return
  refreshInterval.value = setInterval(() => {
    getData()
  }, 5000)
}

function stopAutoRefresh() {
  if (refreshInterval.value) {
    clearInterval(refreshInterval.value)
    refreshInterval.value = null
  }
}

onMounted(() => {
  getData()
  if (autoRefresh.value) {
    startAutoRefresh()
  }
})

onUnmounted(() => {
  stopAutoRefresh()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">服务监控</h2>
        <p class="text-muted-foreground">
          监控服务器 CPU、内存、Node.js 进程等运行状态
        </p>
      </div>
      <div class="flex items-center gap-2">
        <span v-if="lastUpdateTime" class="text-xs text-muted-foreground">
          更新于 {{ lastUpdateTime }}
        </span>
        <Button 
          :variant="autoRefresh ? 'default' : 'outline'" 
          size="sm"
          @click="toggleAutoRefresh"
        >
          <Activity class="mr-2 h-4 w-4" :class="{ 'animate-pulse': autoRefresh }" />
          {{ autoRefresh ? '自动刷新中' : '自动刷新' }}
        </Button>
        <Button variant="outline" size="sm" @click="getData" :disabled="loading">
          <RefreshCw class="mr-2 h-4 w-4" :class="{ 'animate-spin': loading }" />
          刷新
        </Button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading && !server" class="flex items-center justify-center h-[400px]">
      <Loader2 class="w-8 h-8 animate-spin text-primary" />
    </div>

    <div v-else-if="server" class="space-y-6">
      <!-- CPU & Memory Row -->
      <div class="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle class="text-sm font-medium">CPU</CardTitle>
            <Cpu class="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div class="text-xl sm:text-2xl font-bold">{{ server.cpu.cpuNum }} 核心</div>
            <p class="text-xs text-muted-foreground mt-1">
              用户: {{ Number(server.cpu.used).toFixed(1) }}% | 系统: {{ Number(server.cpu.sys).toFixed(1) }}%
            </p>
            <div class="mt-4 space-y-2">
              <div class="flex justify-between text-xs">
                <span>总使用率</span>
                <span :class="getUsageColor(cpuTotalUsage)">{{ cpuTotalUsage.toFixed(1) }}%</span>
              </div>
              <Progress 
                :model-value="cpuTotalUsage" 
                :class="getProgressVariant(cpuTotalUsage)"
              />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle class="text-sm font-medium">内存</CardTitle>
            <Database class="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div class="text-xl sm:text-2xl font-bold">{{ Number(server.mem.total).toFixed(1) }} GB</div>
            <p class="text-xs text-muted-foreground mt-1">
              已用: {{ Number(server.mem.used).toFixed(1) }} GB | 剩余: {{ Number(server.mem.free).toFixed(1) }} GB
            </p>
            <div class="mt-4 space-y-2">
              <div class="flex justify-between text-xs">
                <span>使用率</span>
                <span :class="getUsageColor(Number(server.mem.usage))">{{ Number(server.mem.usage).toFixed(1) }}%</span>
              </div>
              <Progress 
                :model-value="Number(server.mem.usage)" 
                :class="getProgressVariant(Number(server.mem.usage))"
              />
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Server Info -->
      <Card>
        <CardHeader>
          <div class="flex items-center gap-2">
            <Monitor class="h-5 w-5 text-muted-foreground" />
            <CardTitle>服务器信息</CardTitle>
          </div>
          <CardDescription>服务器及 Node.js 运行环境信息</CardDescription>
        </CardHeader>
        <CardContent class="grid gap-6 md:grid-cols-2">
          <div class="space-y-4">
            <h4 class="text-sm font-medium text-muted-foreground">服务器信息</h4>
            <div class="grid grid-cols-2 gap-2 text-sm">
              <span class="text-muted-foreground">服务器名称:</span>
              <span>{{ server.sys.computerName }}</span>
              <span class="text-muted-foreground">服务器IP:</span>
              <span>{{ server.sys.computerIp }}</span>
              <span class="text-muted-foreground">操作系统:</span>
              <span>{{ server.sys.osName }} {{ server.sys.osArch }}</span>
              <span class="text-muted-foreground">项目路径:</span>
              <span class="truncate" :title="server.sys.userDir">{{ server.sys.userDir }}</span>
            </div>
          </div>
           
          <div>
            <h4 class="text-sm font-medium text-muted-foreground mb-4">Node.js 信息</h4>
            <div class="grid grid-cols-2 gap-2 text-sm">
              <span class="text-muted-foreground">运行环境:</span>
              <span>{{ server.jvm.name }}</span>
              <span class="text-muted-foreground">版本:</span>
              <span>{{ server.jvm.version }}</span>
              <span class="text-muted-foreground">启动时间:</span>
              <span>{{ server.jvm.startTime }}</span>
              <span class="text-muted-foreground">运行时长:</span>
              <span class="text-green-600 font-medium">{{ server.jvm.runTime }}</span>
            </div>
          </div>
        </CardContent>
      </Card>
      
      <!-- Node.js Memory -->
      <Card>
        <CardHeader>
          <CardTitle>Node.js 进程内存</CardTitle>
          <CardDescription>V8 堆内存使用情况（堆内存会根据应用负载动态扩展，默认最大约 1.4GB - 4GB）</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="space-y-4">
            <div class="grid grid-cols-3 gap-4 text-center">
              <div>
                <div class="text-sm font-medium text-muted-foreground">当前堆总量</div>
                <div class="text-xl font-bold">{{ Number(server.jvm.total) }} MB</div>
              </div>
              <div>
                <div class="text-sm font-medium text-muted-foreground">已使用</div>
                <div class="text-xl font-bold" :class="getUsageColor(Number(server.jvm.usage))">
                  {{ (Number(server.jvm.total) - Number(server.jvm.free)).toFixed(0) }} MB
                </div>
              </div>
              <div>
                <div class="text-sm font-medium text-muted-foreground">剩余</div>
                <div class="text-xl font-bold text-green-600">{{ Number(server.jvm.free) }} MB</div>
              </div>
            </div>
            <div class="space-y-2">
              <div class="flex justify-between text-xs">
                <span>使用率</span>
                <span :class="getUsageColor(Number(server.jvm.usage))">{{ Number(server.jvm.usage) }}%</span>
              </div>
              <Progress 
                :model-value="Number(server.jvm.usage)" 
                class="h-2"
                :class="getProgressVariant(Number(server.jvm.usage))"
              />
            </div>
            <p class="text-xs text-muted-foreground mt-2">
              💡 堆总量为 V8 引擎当前分配的内存，会随负载自动增长。可通过 --max-old-space-size 参数调整上限。
            </p>
          </div>
        </CardContent>
      </Card>

      <!-- Disk Info -->
      <Card v-if="server.sysFiles && server.sysFiles.length > 0">
        <CardHeader>
          <div class="flex items-center gap-2">
            <HardDrive class="h-5 w-5 text-muted-foreground" />
            <CardTitle>磁盘状态</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <div class="space-y-6">
            <div v-for="(file, index) in server.sysFiles" :key="index" class="space-y-2">
              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div class="flex items-center gap-2">
                  <HardDrive class="h-4 w-4 text-muted-foreground" />
                  <span class="font-medium text-sm">{{ file.dirName }}</span>
                  <span class="text-xs text-muted-foreground">({{ file.typeName }})</span>
                </div>
                <span class="text-sm text-muted-foreground">{{ file.used }} / {{ file.total }}</span>
              </div>
              <Progress 
                :model-value="Number(file.usage)" 
                class="h-2"
                :class="getProgressVariant(Number(file.usage))"
              />
              <div class="flex justify-end text-xs" :class="getUsageColor(Number(file.usage))">
                已用 {{ file.usage }}%
              </div>
              <Separator v-if="index < server.sysFiles.length - 1" class="mt-4" />
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Empty Disk State -->
      <Card v-else>
        <CardHeader>
          <div class="flex items-center gap-2">
            <HardDrive class="h-5 w-5 text-muted-foreground" />
            <CardTitle>磁盘状态</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <div class="text-center py-8 text-muted-foreground">
            <HardDrive class="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>暂无磁盘信息</p>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
