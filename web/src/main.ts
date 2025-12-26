import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import directive from './directive' // directive
import './style.css'
import './permission' // 路由守卫（内部会等待配置加载）

const app = createApp(App)

app.use(createPinia())
app.use(router)
directive(app)

app.mount('#app')
