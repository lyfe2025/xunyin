<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { useToast } from '@/components/ui/toast/use-toast'
import RichTextEditor from '@/components/common/RichTextEditor.vue'
import { Save, RefreshCw, FileText, Shield } from 'lucide-vue-next'
import { getAgreement, updateAgreement, type Agreement } from '@/api/app-config/agreement'

const { toast } = useToast()

const loading = ref(false)
const submitLoading = ref(false)
const activeTab = ref('user_agreement')

// 用户协议
const userAgreement = reactive({
  title: '',
  content: '',
  version: '',
})

// 隐私政策
const privacyPolicy = reactive({
  title: '',
  content: '',
  version: '',
})

// 获取协议内容
async function getData() {
  loading.value = true
  try {
    const [userRes, privacyRes] = await Promise.all([
      getAgreement('user_agreement'),
      getAgreement('privacy_policy'),
    ])

    Object.assign(userAgreement, {
      title: userRes.data.title || '用户协议',
      content: userRes.data.content || '',
      version: userRes.data.version || '1.0',
    })

    Object.assign(privacyPolicy, {
      title: privacyRes.data.title || '隐私政策',
      content: privacyRes.data.content || '',
      version: privacyRes.data.version || '1.0',
    })
  } finally {
    loading.value = false
  }
}

// 保存用户协议
async function handleSaveUserAgreement() {
  submitLoading.value = true
  try {
    await updateAgreement('user_agreement', userAgreement)
    toast({ title: '用户协议保存成功' })
  } finally {
    submitLoading.value = false
  }
}

// 保存隐私政策
async function handleSavePrivacyPolicy() {
  submitLoading.value = true
  try {
    await updateAgreement('privacy_policy', privacyPolicy)
    toast({ title: '隐私政策保存成功' })
  } finally {
    submitLoading.value = false
  }
}

// 重置
function handleReset() {
  getData()
  toast({ title: '已重置' })
}

onMounted(() => {
  getData()
})
</script>

<template>
  <div class="p-4 sm:p-6 space-y-4">
    <!-- 页面标题 -->
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-xl sm:text-2xl font-bold tracking-tight">协议管理</h2>
        <p class="text-muted-foreground">编辑用户协议和隐私政策内容</p>
      </div>
      <Button variant="outline" @click="handleReset" :disabled="loading">
        <RefreshCw class="h-4 w-4 mr-2" />重置
      </Button>
    </div>

    <Tabs v-model="activeTab">
      <TabsList>
        <TabsTrigger value="user_agreement">
          <FileText class="h-4 w-4 mr-2" />用户协议
        </TabsTrigger>
        <TabsTrigger value="privacy_policy"> <Shield class="h-4 w-4 mr-2" />隐私政策 </TabsTrigger>
      </TabsList>

      <!-- 用户协议 -->
      <TabsContent value="user_agreement">
        <Card>
          <CardHeader>
            <CardTitle>用户协议</CardTitle>
            <CardDescription>编辑 APP 用户协议内容，支持富文本格式</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>协议标题</Label>
                <Input v-model="userAgreement.title" placeholder="用户协议" />
              </div>
              <div class="grid gap-2">
                <Label>版本号</Label>
                <Input v-model="userAgreement.version" placeholder="1.0" />
              </div>
            </div>
            <div class="grid gap-2">
              <Label>协议内容</Label>
              <RichTextEditor
                v-model="userAgreement.content"
                placeholder="请输入用户协议内容..."
                min-height="500px"
              />
            </div>
            <div class="flex justify-end">
              <Button @click="handleSaveUserAgreement" :disabled="submitLoading">
                <Save class="h-4 w-4 mr-2" />{{ submitLoading ? '保存中...' : '保存用户协议' }}
              </Button>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- 隐私政策 -->
      <TabsContent value="privacy_policy">
        <Card>
          <CardHeader>
            <CardTitle>隐私政策</CardTitle>
            <CardDescription>编辑 APP 隐私政策内容，支持富文本格式</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>协议标题</Label>
                <Input v-model="privacyPolicy.title" placeholder="隐私政策" />
              </div>
              <div class="grid gap-2">
                <Label>版本号</Label>
                <Input v-model="privacyPolicy.version" placeholder="1.0" />
              </div>
            </div>
            <div class="grid gap-2">
              <Label>协议内容</Label>
              <RichTextEditor
                v-model="privacyPolicy.content"
                placeholder="请输入隐私政策内容..."
                min-height="500px"
              />
            </div>
            <div class="flex justify-end">
              <Button @click="handleSavePrivacyPolicy" :disabled="submitLoading">
                <Save class="h-4 w-4 mr-2" />{{ submitLoading ? '保存中...' : '保存隐私政策' }}
              </Button>
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  </div>
</template>
