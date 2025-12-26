<script setup lang="ts">
import { Construction } from 'lucide-vue-next'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'

defineProps<{
  title: string
  description?: string
}>()
</script>

<template>
  <div class="p-6 flex items-center justify-center h-[50vh]">
    <Card class="w-full max-w-md text-center">
      <CardHeader>
        <div class="flex justify-center mb-4">
          <Construction class="h-12 w-12 text-muted-foreground" />
        </div>
        <CardTitle>{{ title }}</CardTitle>
        <CardDescription>
          {{ description || '该模块正在开发中，敬请期待...' }}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <p class="text-sm text-muted-foreground">Phase 3/4 Feature</p>
      </CardContent>
    </Card>
  </div>
</template>
