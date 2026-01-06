<script setup lang="ts">
import { computed, watch, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useMenuStore } from '@/stores/modules/menu'
import { useThemeStore } from '@/stores/theme'
import { cn } from '@/lib/utils'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion'
import * as icons from 'lucide-vue-next'

const route = useRoute()
const menuStore = useMenuStore()
const themeStore = useThemeStore()

// 菜单项高度样式
const menuItemStyle = computed(() => ({
  height: `${themeStore.sidebarItemHeight}px`,
}))

const menuList = computed(() => menuStore.menuList)

const isActive = (path: string) => route.path === path

// 当前展开的菜单项
const expandedItem = ref<string>('')

// 根据当前路由找到对应的父菜单索引
function findActiveMenuIndex(): string {
  const currentPath = route.path
  for (let i = 0; i < menuList.value.length; i++) {
    const menu = menuList.value[i]
    // 检查是否匹配父路由
    if (currentPath.startsWith(menu.path)) {
      return `item-${i}`
    }
    // 检查子路由
    if (menu.children) {
      for (const child of menu.children) {
        const childPath = child.path.startsWith('/') ? child.path : `${menu.path}/${child.path}`
        if (currentPath === childPath || currentPath.startsWith(childPath + '/')) {
          return `item-${i}`
        }
      }
    }
  }
  return ''
}

// 监听路由变化，自动展开对应菜单
watch(
  () => route.path,
  () => {
    const activeIndex = findActiveMenuIndex()
    if (activeIndex) {
      expandedItem.value = activeIndex
    }
  },
  { immediate: true },
)

// 监听菜单数据加载完成
watch(
  () => menuList.value,
  () => {
    if (menuList.value.length > 0 && !expandedItem.value) {
      expandedItem.value = findActiveMenuIndex()
    }
  },
  { immediate: true },
)

// 将 kebab-case 转换为 PascalCase
function toPascalCase(str: string): string {
  if (!str) return ''
  return str
    .split('-')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join('')
}

// 动态获取图标组件
function getIcon(iconName: string) {
  if (!iconName) return icons.Settings
  const pascalName = toPascalCase(iconName)
  return (icons as any)[pascalName] || icons.Settings
}
</script>

<template>
  <Accordion type="single" collapsible class="w-full" v-model="expandedItem">
    <AccordionItem
      v-for="(item, index) in menuList"
      :key="item.path"
      :value="`item-${index}`"
      class="border-b-0"
    >
      <AccordionTrigger
        class="hover:no-underline hover:text-primary text-muted-foreground px-3 rounded-lg hover:bg-muted/50"
        :style="menuItemStyle"
      >
        <div class="flex items-center gap-3">
          <component :is="getIcon(item.meta.icon)" class="h-5 w-5" />
          <span class="font-medium">{{ item.meta.title }}</span>
        </div>
      </AccordionTrigger>
      <AccordionContent class="pb-0 pl-4 space-y-1 mt-1">
        <router-link
          v-for="child in item.children"
          :key="child.path"
          :to="child.path.startsWith('/') ? child.path : `${item.path}/${child.path}`"
          :class="
            cn(
              'flex items-center gap-3 rounded-lg px-3 text-sm transition-all hover:text-primary',
              isActive(child.path.startsWith('/') ? child.path : `${item.path}/${child.path}`)
                ? 'bg-muted text-primary'
                : 'text-muted-foreground',
            )
          "
          :style="menuItemStyle"
        >
          <component :is="getIcon(child.meta.icon)" class="h-4 w-4" />
          {{ child.meta.title }}
        </router-link>
      </AccordionContent>
    </AccordionItem>
  </Accordion>
</template>
