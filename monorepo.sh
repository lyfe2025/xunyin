#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
WEB_DIR="$ROOT/web"
SERVER_DIR="$ROOT/server-nestjs"
PID_DIR="$ROOT/.run"

mkdir -p "$PID_DIR"

ESC="$(printf '\033')"
BOLD="${ESC}[1m"
RESET="${ESC}[0m"
FG_GREEN="${ESC}[32m"
FG_RED="${ESC}[31m"
FG_YELLOW="${ESC}[33m"
FG_BLUE="${ESC}[34m"
FG_CYAN="${ESC}[36m"
FG_GRAY="${ESC}[90m"

# 允许通过环境变量覆盖端口（运行命令时可用 WEB_PORT=xxxx / SERVER_PORT=xxxx）
OVERRIDE_WEB_PORT="${WEB_PORT:-}"
OVERRIDE_SERVER_PORT="${SERVER_PORT:-}"

if [ -n "$NO_COLOR" ] || [ ! -t 1 ]; then
  BOLD=""; RESET=""; FG_GREEN=""; FG_RED=""; FG_YELLOW=""; FG_BLUE=""; FG_CYAN=""; FG_GRAY=""
fi

get_cols() {
  local c
  c=$(tput cols 2>/dev/null || echo 80)
  echo "$c"
}

repeat_char() {
  local ch="$1"; local n="$2"
  local out=""
  while [ ${#out} -lt "$n" ]; do out="$out$ch"; done
  echo "$out"
}

center_line() {
  local text="$1"; local cols
  cols=$(get_cols)
  local len=${#text}
  local pad=$(( (cols - len) / 2 ))
  [ "$pad" -lt 0 ] && pad=0
  printf "%*s%s\n" "$pad" "" "$text"
}

hr() {
  local cols
  cols=$(get_cols)
  printf "%s\n" "$(repeat_char '─' "$cols")"
}

kv_line() {
  local label="$1"; local value="$2"
  printf "  %-8s: %s\n" "$label" "$value"
}

is_port_in_use() {
  lsof -ti ":$1" >/dev/null 2>&1
}

# 从 env 文件读取变量值（忽略注释与空格，去除引号）
read_env_var_from_file() {
  local file="$1"
  local var="$2"
  [ -f "$file" ] || return 1
  local line
  line=$(grep -E "^${var}[[:space:]]*=" "$file" | tail -n 1 || true)
  [ -n "$line" ] || return 1
  local val
  val=$(echo "$line" | sed -E "s/^${var}[[:space:]]*=[[:space:]]*//" | tr -d '"' | tr -d "'")
  [ -n "$val" ] || return 1
  echo "$val"
  return 0
}

# 获取前端端口：按优先级读取 .env.development.local -> .env.development -> .env.local -> .env
get_web_port() {
  if [ -n "$OVERRIDE_WEB_PORT" ]; then echo "$OVERRIDE_WEB_PORT"; return 0; fi
  local files=(
    "$WEB_DIR/.env.development.local"
    "$WEB_DIR/.env.development"
    "$WEB_DIR/.env.local"
    "$WEB_DIR/.env"
  )
  local val
  for f in "${files[@]}"; do
    val=$(read_env_var_from_file "$f" "VITE_PORT" || true)
    if [ -n "$val" ]; then echo "$val"; return 0; fi
  done
  echo 5173
}

get_web_port_info() {
  if [ -n "$OVERRIDE_WEB_PORT" ]; then echo "$OVERRIDE_WEB_PORT|ENV"; return 0; fi
  local files=(
    "$WEB_DIR/.env.development.local"
    "$WEB_DIR/.env.development"
    "$WEB_DIR/.env.local"
    "$WEB_DIR/.env"
  )
  local val
  for f in "${files[@]}"; do
    val=$(read_env_var_from_file "$f" "VITE_PORT" || true)
    if [ -n "$val" ]; then echo "$val|$f"; return 0; fi
  done
  echo "5173|default"
}

# 获取后端端口：读取 server-nestjs/.env.local -> .env 的 PORT，默认 3000
get_server_port() {
  if [ -n "$OVERRIDE_SERVER_PORT" ]; then echo "$OVERRIDE_SERVER_PORT"; return 0; fi
  local files=(
    "$SERVER_DIR/.env.local"
    "$SERVER_DIR/.env"
  )
  local val
  for f in "${files[@]}"; do
    val=$(read_env_var_from_file "$f" "PORT" || true)
    if [ -n "$val" ]; then echo "$val"; return 0; fi
  done
  echo 3000
}

get_server_port_info() {
  if [ -n "$OVERRIDE_SERVER_PORT" ]; then echo "$OVERRIDE_SERVER_PORT|ENV"; return 0; fi
  local files=(
    "$SERVER_DIR/.env.local"
    "$SERVER_DIR/.env"
  )
  local val
  for f in "${files[@]}"; do
    val=$(read_env_var_from_file "$f" "PORT" || true)
    if [ -n "$val" ]; then echo "$val|$f"; return 0; fi
  done
  echo "3000|default"
}

log_mtime() {
  local file="$1"
  if [ -f "$file" ]; then
    stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file"
  else
    echo "-"
  fi
}

pid_uptime_raw() {
  local pid="$1"
  if [ -n "$pid" ] && is_running "$pid"; then
    ps -p "$pid" -o etime= 2>/dev/null | tr -d ' '
  else
    echo "-"
  fi
}

fmt_uptime() {
  local etime="$1"
  if [ -z "$etime" ] || [ "$etime" = "-" ]; then echo "-"; return 0; fi
  local days=0 hh=0 mm=0 ss=0 rest
  if [[ "$etime" == *-* ]]; then
    days=${etime%%-*}
    rest=${etime#*-}
  else
    rest="$etime"
  fi
  hh=${rest%%:*}
  rest=${rest#*:}
  mm=${rest%%:*}
  ss=${rest#*:}
  local total_hours=$((10#$days*24+10#$hh))
  echo "${total_hours} 小时 ${mm} 分钟"
}

shorten_source() {
  local src="$1"
  if [ "$src" = "ENV" ] || [ "$src" = "default" ]; then echo "$src"; return 0; fi
  local base parent
  base=$(basename "$src")
  parent=$(basename "$(dirname "$src")")
  echo "${parent}/${base}"
}

status_badge() {
  case "$1" in
    运行中)
      printf "${FG_GREEN}● 运行中${RESET}"
      ;;
    未运行)
      printf "${FG_RED}○ 未运行${RESET}"
      ;;
    *)
      printf "%s" "$1"
      ;;
  esac
}

wait_for_port() {
  local port="$1"
  local name="$2"
  local i=0
  local sp='|/-\\'
  while ! is_port_in_use "$port" && [ $i -lt 60 ]; do
    printf "\r${FG_YELLOW}%s 启动中... %c${RESET}" "$name" "${sp:i%4:1}"
    sleep 0.2
    i=$((i+1))
  done
  if is_port_in_use "$port"; then
    printf "\r${FG_GREEN}%s 启动成功${RESET}\n" "$name"
  else
    printf "\r${FG_RED}%s 启动超时${RESET}\n" "$name"
  fi
}

kill_by_port() {
  local port="$1"
  local pids
  pids="$(lsof -ti ":$port" || true)"
  if [ -n "$pids" ]; then
    # 先尝试优雅终止
    echo "$pids" | xargs -r kill -TERM 2>/dev/null || true
    sleep 1
    # 检查是否还有进程存活，如果有则强制杀掉
    pids="$(lsof -ti ":$port" || true)"
    if [ -n "$pids" ]; then
      echo "$pids" | xargs -r kill -9 2>/dev/null || true
      sleep 1
    fi
  fi
}

read_pid() {
  [ -f "$PID_DIR/$1" ] && cat "$PID_DIR/$1" || echo ""
}

write_pid() {
  echo "$2" > "$PID_DIR/$1"
}

remove_pid() {
  rm -f "$PID_DIR/$1" || true
}

is_running() {
  local pid="$1"
  [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1
}

start_web() {
  local WEB_PORT
  WEB_PORT="$(get_web_port)"
  if is_port_in_use "$WEB_PORT"; then kill_by_port "$WEB_PORT"; fi
  (cd "$WEB_DIR" && nohup npm run dev >"$PID_DIR/web-dev.log" 2>&1 & echo $! > "$PID_DIR/web-dev.pid")
  wait_for_port "$WEB_PORT" "前端"
  printf "${FG_CYAN}  ➜ 前端访问地址: ${BOLD}http://localhost:${WEB_PORT}${RESET}\n"
  printf "${FG_CYAN}  ➜ 安全入口地址: ${BOLD}http://localhost:${WEB_PORT}/login${RESET}\n"
}

start_server() {
  local SERVER_PORT
  SERVER_PORT="$(get_server_port)"
  if is_port_in_use "$SERVER_PORT"; then kill_by_port "$SERVER_PORT"; fi
  (cd "$SERVER_DIR" && nohup npm run start:dev >"$PID_DIR/server-dev.log" 2>&1 & echo $! > "$PID_DIR/server-dev.pid")
  wait_for_port "$SERVER_PORT" "后端"
  printf "${FG_CYAN}  ➜ 后端 API 地址: ${BOLD}http://localhost:${SERVER_PORT}${RESET}\n"
  printf "${FG_CYAN}  ➜ API 文档地址: ${BOLD}http://localhost:${SERVER_PORT}/api-docs${RESET}\n"
}

stop_web() {
  local pid WEB_PORT
  WEB_PORT="$(get_web_port)"
  pid="$(read_pid web-dev.pid)"
  if is_running "$pid"; then kill -TERM "$pid" || true; sleep 1; kill -KILL "$pid" || true; fi
  remove_pid web-dev.pid
  kill_by_port "$WEB_PORT"
  printf "${FG_BLUE}前端已停止${RESET}\n"
}

stop_server() {
  local pid SERVER_PORT
  SERVER_PORT="$(get_server_port)"
  pid="$(read_pid server-dev.pid)"
  # 先杀掉记录的 PID
  if is_running "$pid"; then
    kill -TERM "$pid" 2>/dev/null || true
    sleep 1
    kill -9 "$pid" 2>/dev/null || true
  fi
  remove_pid server-dev.pid
  # 再确保端口上没有残留进程
  kill_by_port "$SERVER_PORT"
  sleep 1
  printf "${FG_BLUE}后端已停止${RESET}\n"
}

restart_web() { stop_web; start_web; }
restart_server() { stop_server; start_server; }

start_all() { start_server; start_web; }
stop_all() { stop_web; stop_server; }
restart_all() { stop_all; start_all; }

status_all() {
  local wpid spid WEB_PORT SERVER_PORT
  WEB_PORT="$(get_web_port)"
  SERVER_PORT="$(get_server_port)"
  wpid="$(read_pid web-dev.pid)"
  spid="$(read_pid server-dev.pid)"
  local wstatus sstatus
  if is_running "$wpid" || is_port_in_use "$WEB_PORT"; then wstatus="运行中"; else wstatus="未运行"; fi
  if is_running "$spid" || is_port_in_use "$SERVER_PORT"; then sstatus="运行中"; else sstatus="未运行"; fi
  
  echo ""
  hr
  if [ "$wstatus" = "运行中" ]; then
    printf "${FG_GREEN}前端状态：%s${RESET} (pid: %s, port: %s)\n" "$wstatus" "${wpid:-'-'}" "$WEB_PORT"
    printf "${FG_CYAN}  ➜ 访问地址: ${BOLD}http://localhost:${WEB_PORT}${RESET}\n"
    printf "${FG_CYAN}  ➜ 安全入口: ${BOLD}http://localhost:${WEB_PORT}/login${RESET}\n"
  else
    printf "${FG_RED}前端状态：%s${RESET} (pid: %s, port: %s)\n" "$wstatus" "${wpid:-'-'}" "$WEB_PORT"
  fi
  
  if [ "$sstatus" = "运行中" ]; then
    printf "${FG_GREEN}后端状态：%s${RESET} (pid: %s, port: %s)\n" "$sstatus" "${spid:-'-'}" "$SERVER_PORT"
    printf "${FG_CYAN}  ➜ API 地址: ${BOLD}http://localhost:${SERVER_PORT}${RESET}\n"
    printf "${FG_CYAN}  ➜ API 文档: ${BOLD}http://localhost:${SERVER_PORT}/api-docs${RESET}\n"
  else
    printf "${FG_RED}后端状态：%s${RESET} (pid: %s, port: %s)\n" "$sstatus" "${spid:-'-'}" "$SERVER_PORT"
  fi
  hr
  echo ""
}

# 跟随日志输出，模拟前台运行效果（Ctrl+C 退出日志跟随，服务仍在运行）
attach_logs() {
  local target="$1"
  set +e
  case "$target" in
    web)
      if [ -f "$PID_DIR/web-dev.log" ]; then
        echo "— 正在跟随前端日志 (Ctrl+C 退出) —"
        tail -f "$PID_DIR/web-dev.log"
      else
        echo "未找到前端日志文件：$PID_DIR/web-dev.log"
      fi
      ;;
    server)
      if [ -f "$PID_DIR/server-dev.log" ]; then
        echo "— 正在跟随后端日志 (Ctrl+C 退出) —"
        tail -f "$PID_DIR/server-dev.log"
      else
        echo "未找到后端日志文件：$PID_DIR/server-dev.log"
      fi
      ;;
    all)
      local files=()
      [ -f "$PID_DIR/web-dev.log" ] && files+=("$PID_DIR/web-dev.log")
      [ -f "$PID_DIR/server-dev.log" ] && files+=("$PID_DIR/server-dev.log")
      if [ ${#files[@]} -gt 0 ]; then
        echo "— 正在跟随前后端日志 (Ctrl+C 退出) —"
        tail -f "${files[@]}"
      else
        echo "未找到任何日志文件"
      fi
      ;;
  esac
  set -e
  echo "已退出日志跟随，服务仍在运行"
}

type_check() { (cd "$WEB_DIR" && npm run type-check); }
validate_server() { (cd "$SERVER_DIR" && npm run validate); }
migrate_dev() { (cd "$SERVER_DIR" && npx prisma migrate dev && npx prisma generate); }
studio() { (cd "$SERVER_DIR" && npx prisma studio); }
reset_db() {
  printf "${FG_YELLOW}⚠️  警告: 此操作将删除所有数据并重置数据库到初始状态!${RESET}\n"
  read -rp "确认重置数据库? (y/N): " confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    printf "${FG_BLUE}正在重置数据库...${RESET}\n"
    # 显式加载 .env 文件，确保 DATABASE_URL 正确传递给 Prisma
    (
      set -a
      source "$SERVER_DIR/.env"
      set +a
      cd "$SERVER_DIR" && npx prisma migrate reset --force && npx prisma generate && npx prisma db seed
    )
    printf "${FG_GREEN}数据库已重置并重新初始化${RESET}\n"
    
    # 检查后端是否在运行，如果是则自动重启以刷新数据库连接池
    local SERVER_PORT spid
    SERVER_PORT="$(get_server_port)"
    spid="$(read_pid server-dev.pid)"
    if is_running "$spid" || is_port_in_use "$SERVER_PORT"; then
      printf "${FG_YELLOW}检测到后端正在运行，正在重启以刷新数据库连接...${RESET}\n"
      restart_server
    fi
  else
    printf "${FG_BLUE}已取消重置操作${RESET}\n"
  fi
}
smoke_tests() {
  (cd "$SERVER_DIR" && bash test-login.sh)
  (cd "$SERVER_DIR" && bash test-getinfo.sh)
  (cd "$SERVER_DIR" && bash test-getrouters.sh)
  (cd "$SERVER_DIR" && bash test-user.sh)
  (cd "$SERVER_DIR" && bash test-role.sh)
  (cd "$SERVER_DIR" && bash test-dept.sh)
  (cd "$SERVER_DIR" && bash test-menu.sh)
}

# 生成更新日志静态文件 (commits.json)
gen_commits() {
  printf "${FG_BLUE}正在生成 commits.json...${RESET}\n"
  (cd "$ROOT" && git log -100 --format='COMMIT_START%H|%h|%s|%aI|%an|%B|COMMIT_END' | node -e '
const fs = require("fs");
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  const commits = input.split("COMMIT_START").filter(Boolean).map(block => {
    const endIdx = block.indexOf("|COMMIT_END");
    const content = block.substring(0, endIdx);
    const parts = content.split("|");
    const [sha, shortSha, message, date, author, ...rest] = parts;
    const fullMessage = rest.join("|").trim();
    const type = message.match(/^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)[(:]/)?.[1] || "other";
    const result = { sha, shortSha, message, type, date, author };
    if (fullMessage && fullMessage !== message) {
      result.fullMessage = fullMessage;
    }
    return result;
  });
  console.log(JSON.stringify(commits, null, 2));
});
' > "$SERVER_DIR/commits.json")
  printf "${FG_GREEN}✓ 已生成 %s${RESET}\n" "$SERVER_DIR/commits.json"
}

# ============================================================
# Flutter 移动端打包命令
# ============================================================

FLUTTER_DIR="$ROOT/app_flutter"

check_flutter() {
  if ! command -v flutter &> /dev/null; then
    printf "${FG_RED}✗ Flutter 未安装${RESET}\n"
    printf "${FG_YELLOW}请访问 https://flutter.dev 安装 Flutter${RESET}\n"
    return 1
  fi
  return 0
}

flutter_build_android() {
  check_flutter || return 1
  printf "${FG_BLUE}正在构建 Android APK...${RESET}\n"
  (cd "$FLUTTER_DIR" && flutter build apk --release)
  local apk_path="$FLUTTER_DIR/build/app/outputs/flutter-apk/app-release.apk"
  if [ -f "$apk_path" ]; then
    local size=$(du -h "$apk_path" | cut -f1)
    printf "${FG_GREEN}✓ Android APK 构建成功${RESET}\n"
    printf "${FG_CYAN}  ➜ 文件路径: ${BOLD}%s${RESET}\n" "$apk_path"
    printf "${FG_CYAN}  ➜ 文件大小: ${BOLD}%s${RESET}\n" "$size"
  else
    printf "${FG_RED}✗ Android APK 构建失败${RESET}\n"
    return 1
  fi
}

flutter_build_ios() {
  check_flutter || return 1
  printf "${FG_BLUE}正在构建 iOS IPA (无签名)...${RESET}\n"
  (cd "$FLUTTER_DIR" && flutter build ios --release --no-codesign)
  
  # 创建 IPA 包
  local payload_dir="$FLUTTER_DIR/build/ios/iphoneos/Payload"
  local app_path="$FLUTTER_DIR/build/ios/iphoneos/Runner.app"
  local ipa_path="$FLUTTER_DIR/build/ios/iphoneos/xunyin_unsigned.ipa"
  
  if [ -d "$app_path" ]; then
    printf "${FG_BLUE}正在打包 IPA...${RESET}\n"
    rm -rf "$payload_dir"
    mkdir -p "$payload_dir"
    cp -r "$app_path" "$payload_dir/"
    (cd "$FLUTTER_DIR/build/ios/iphoneos" && zip -r xunyin_unsigned.ipa Payload > /dev/null 2>&1)
    
    if [ -f "$ipa_path" ]; then
      local size=$(du -h "$ipa_path" | cut -f1)
      printf "${FG_GREEN}✓ iOS IPA 构建成功 (无签名)${RESET}\n"
      printf "${FG_CYAN}  ➜ 文件路径: ${BOLD}%s${RESET}\n" "$ipa_path"
      printf "${FG_CYAN}  ➜ 文件大小: ${BOLD}%s${RESET}\n" "$size"
      printf "${FG_YELLOW}  ⚠ 注意: 此 IPA 未签名，需要重新签名后才能安装到设备${RESET}\n"
    else
      printf "${FG_RED}✗ IPA 打包失败${RESET}\n"
      return 1
    fi
  else
    printf "${FG_RED}✗ iOS 构建失败${RESET}\n"
    return 1
  fi
}

flutter_build_all() {
  check_flutter || return 1
  printf "${FG_BLUE}正在构建 Android 和 iOS 双端...${RESET}\n"
  hr
  
  # 构建 Android
  flutter_build_android
  local android_result=$?
  
  hr
  
  # 构建 iOS
  flutter_build_ios
  local ios_result=$?
  
  hr
  
  # 汇总结果
  printf "${FG_CYAN}[构建汇总]${RESET}\n"
  if [ $android_result -eq 0 ]; then
    printf "${FG_GREEN}✓ Android APK: %s${RESET}\n" "$FLUTTER_DIR/build/app/outputs/flutter-apk/app-release.apk"
  else
    printf "${FG_RED}✗ Android APK: 构建失败${RESET}\n"
  fi
  
  if [ $ios_result -eq 0 ]; then
    printf "${FG_GREEN}✓ iOS IPA: %s${RESET}\n" "$FLUTTER_DIR/build/ios/iphoneos/xunyin_unsigned.ipa"
  else
    printf "${FG_RED}✗ iOS IPA: 构建失败${RESET}\n"
  fi
  hr
}

# ============================================================
# Docker 部署命令
# ============================================================

check_docker() {
  if ! command -v docker &> /dev/null; then
    printf "${FG_RED}✗ Docker 未安装${RESET}\n"
    return 1
  fi
  if ! docker info &> /dev/null; then
    printf "${FG_RED}✗ Docker 未运行${RESET}\n"
    return 1
  fi
  return 0
}

docker_infra_up() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose up -d postgres redis${RESET}\n"
  docker-compose up -d postgres redis
  printf "${FG_GREEN}✓ 基础设施已启动 (PostgreSQL + Redis)${RESET}\n"
}

docker_up() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose up -d${RESET}\n"
  docker-compose up -d
  printf "${FG_GREEN}✓ 全部服务已启动${RESET}\n"
  docker-compose ps
}

docker_up_build() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose up -d --build${RESET}\n"
  docker-compose up -d --build
  printf "${FG_GREEN}✓ 全部服务已构建并启动${RESET}\n"
  docker-compose ps
}

docker_build_server() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose build server${RESET}\n"
  docker-compose build server
  printf "${FG_GREEN}✓ 后端镜像构建完成${RESET}\n"
}

docker_build_web() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose build web${RESET}\n"
  docker-compose build web
  printf "${FG_GREEN}✓ 前端镜像构建完成${RESET}\n"
}

docker_down() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose down${RESET}\n"
  docker-compose down
  printf "${FG_GREEN}✓ 全部服务已停止${RESET}\n"
}

docker_restart() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose restart${RESET}\n"
  docker-compose restart
  printf "${FG_GREEN}✓ 全部服务已重启${RESET}\n"
  docker-compose ps
}

docker_ps() {
  check_docker || return 1
  printf "${FG_BLUE}执行: docker-compose ps${RESET}\n"
  docker-compose ps
}

docker_logs() {
  check_docker || return 1
  echo "选择要查看的服务日志:"
  echo "  1) 全部服务"
  echo "  2) 后端 (server)"
  echo "  3) 前端 (web)"
  echo "  4) PostgreSQL"
  echo "  5) Redis"
  read -rp "请选择 [1-5]: " choice
  case "$choice" in
    1) printf "${FG_BLUE}执行: docker-compose logs -f${RESET}\n"; docker-compose logs -f ;;
    2) printf "${FG_BLUE}执行: docker-compose logs -f server${RESET}\n"; docker-compose logs -f server ;;
    3) printf "${FG_BLUE}执行: docker-compose logs -f web${RESET}\n"; docker-compose logs -f web ;;
    4) printf "${FG_BLUE}执行: docker-compose logs -f postgres${RESET}\n"; docker-compose logs -f postgres ;;
    5) printf "${FG_BLUE}执行: docker-compose logs -f redis${RESET}\n"; docker-compose logs -f redis ;;
    *) printf "${FG_RED}无效选项${RESET}\n" ;;
  esac
}

docker_restart_service() {
  check_docker || return 1
  echo "选择要重启的服务:"
  echo "  1) 后端 (server)"
  echo "  2) 前端 (web)"
  echo "  3) PostgreSQL"
  echo "  4) Redis"
  read -rp "请选择 [1-4]: " choice
  case "$choice" in
    1) printf "${FG_BLUE}执行: docker-compose restart server${RESET}\n"; docker-compose restart server ;;
    2) printf "${FG_BLUE}执行: docker-compose restart web${RESET}\n"; docker-compose restart web ;;
    3) printf "${FG_BLUE}执行: docker-compose restart postgres${RESET}\n"; docker-compose restart postgres ;;
    4) printf "${FG_BLUE}执行: docker-compose restart redis${RESET}\n"; docker-compose restart redis ;;
    *) printf "${FG_RED}无效选项${RESET}\n" ;;
  esac
}

print_menu() {
  local WEB_PORT SERVER_PORT wpid spid wstatus sstatus
  local WEB_INFO SERVER_INFO WEB_SRC SERVER_SRC WEB_LOG SERVER_LOG WEB_UP SERVER_UP
  WEB_INFO="$(get_web_port_info)"; SERVER_INFO="$(get_server_port_info)"
  WEB_PORT="${WEB_INFO%|*}"; WEB_SRC="${WEB_INFO#*|}"
  SERVER_PORT="${SERVER_INFO%|*}"; SERVER_SRC="${SERVER_INFO#*|}"
  wpid="$(read_pid web-dev.pid)"; spid="$(read_pid server-dev.pid)"
  if is_running "$wpid" || is_port_in_use "$WEB_PORT"; then wstatus="运行中"; else wstatus="未运行"; fi
  if is_running "$spid" || is_port_in_use "$SERVER_PORT"; then sstatus="运行中"; else sstatus="未运行"; fi
  WEB_LOG_PATH="$PID_DIR/web-dev.log"; SERVER_LOG_PATH="$PID_DIR/server-dev.log"
  WEB_UP="$(fmt_uptime "$(pid_uptime_raw "$wpid")")"; SERVER_UP="$(fmt_uptime "$(pid_uptime_raw "$spid")")"
  center_line "${BOLD}${FG_CYAN}Xunyin Admin 控制台${RESET}"
  hr
  printf -- "${FG_CYAN}[前端]${RESET}\n"
  kv_line "状态" "$(status_badge "$wstatus")"
  kv_line "PID" "${wpid:-'-'}"
  kv_line "端口" "$WEB_PORT (source: $(shorten_source "$WEB_SRC"))"
  kv_line "Uptime" "$WEB_UP"
  kv_line "Log" "$(shorten_source "$WEB_LOG_PATH") (更新时间: $(log_mtime "$WEB_LOG_PATH"))"
  hr
  printf -- "${FG_CYAN}[后端]${RESET}\n"
  kv_line "状态" "$(status_badge "$sstatus")"
  kv_line "PID" "${spid:-'-'}"
  kv_line "端口" "$SERVER_PORT (source: $(shorten_source "$SERVER_SRC"))"
  kv_line "Uptime" "$SERVER_UP"
  kv_line "Log" "$(shorten_source "$SERVER_LOG_PATH") (更新时间: $(log_mtime "$SERVER_LOG_PATH"))"
  hr
  printf -- "${FG_CYAN}[本地开发]${RESET}\n"
  printf -- "${FG_CYAN}1${RESET}.  一键启动 前端+后端              ${FG_GRAY}pnpm dev${RESET}\n"
  printf -- "${FG_CYAN}2${RESET}.  一键停止 前端+后端\n"
  printf -- "${FG_CYAN}3${RESET}.  一键重启 前端+后端\n"
  printf -- "${FG_CYAN}4${RESET}.  同步数据库迁移                  ${FG_GRAY}pnpm prisma migrate dev${RESET}\n"
  printf -- "${FG_CYAN}5${RESET}.  打开 Prisma Studio              ${FG_GRAY}pnpm prisma studio${RESET}\n"
  printf -- "${FG_CYAN}6${RESET}.  前端类型检查                    ${FG_GRAY}pnpm type-check${RESET}\n"
  printf -- "${FG_CYAN}7${RESET}.  后端代码校验                    ${FG_GRAY}pnpm validate${RESET}\n"
  printf -- "${FG_CYAN}8${RESET}.  后端快速 API 冒烟测试\n"
  printf -- "${FG_RED}9${RESET}.  重置数据库到初始状态 (危险)      ${FG_GRAY}pnpm prisma migrate reset${RESET}\n"
  hr
  printf -- "${FG_CYAN}[Docker 部署]${RESET}\n"
  printf -- "${FG_CYAN}10${RESET}. 启动基础设施 (PG+Redis)         ${FG_GRAY}docker-compose up -d postgres redis${RESET}\n"
  printf -- "${FG_CYAN}11${RESET}. 启动全部服务                    ${FG_GRAY}docker-compose up -d${RESET}\n"
  printf -- "${FG_CYAN}12${RESET}. 构建并启动全部                  ${FG_GRAY}docker-compose up -d --build${RESET}\n"
  printf -- "${FG_CYAN}13${RESET}. 仅构建后端镜像                  ${FG_GRAY}docker-compose build server${RESET}\n"
  printf -- "${FG_CYAN}14${RESET}. 仅构建前端镜像                  ${FG_GRAY}docker-compose build web${RESET}\n"
  printf -- "${FG_CYAN}15${RESET}. 停止全部服务                    ${FG_GRAY}docker-compose down${RESET}\n"
  printf -- "${FG_CYAN}16${RESET}. 重启全部服务                    ${FG_GRAY}docker-compose restart${RESET}\n"
  printf -- "${FG_CYAN}17${RESET}. 重启指定服务                    ${FG_GRAY}docker-compose restart [service]${RESET}\n"
  printf -- "${FG_CYAN}18${RESET}. 查看服务状态                    ${FG_GRAY}docker-compose ps${RESET}\n"
  printf -- "${FG_CYAN}19${RESET}. 查看服务日志                    ${FG_GRAY}docker-compose logs -f [service]${RESET}\n"
  hr
  printf -- "${FG_CYAN}[工具]${RESET}\n"
  printf -- "${FG_CYAN}20${RESET}. 生成更新日志静态文件            ${FG_GRAY}git log -> commits.json${RESET}\n"
  hr
  printf -- "${FG_CYAN}[移动端打包]${RESET}\n"
  printf -- "${FG_CYAN}21${RESET}. 构建 Android APK                ${FG_GRAY}flutter build apk --release${RESET}\n"
  printf -- "${FG_CYAN}22${RESET}. 构建 iOS IPA (无签名)           ${FG_GRAY}flutter build ios --no-codesign${RESET}\n"
  printf -- "${FG_CYAN}23${RESET}. 构建双端 (Android + iOS)        ${FG_GRAY}flutter build all${RESET}\n"
  hr
  printf -- "${FG_CYAN}0${RESET}.  退出\n"
}

run_by_id() {
  case "$1" in
    1) start_all; attach_logs all ;;
    2) stop_all ;;
    3) restart_all; attach_logs all ;;
    4) migrate_dev ;;
    5) studio ;;
    6) type_check ;;
    7) validate_server ;;
    8) smoke_tests ;;
    9) reset_db ;;
    10) docker_infra_up ;;
    11) docker_up ;;
    12) docker_up_build ;;
    13) docker_build_server ;;
    14) docker_build_web ;;
    15) docker_down ;;
    16) docker_restart ;;
    17) docker_restart_service ;;
    18) docker_ps ;;
    19) docker_logs ;;
    20) gen_commits ;;
    21) flutter_build_android ;;
    22) flutter_build_ios ;;
    23) flutter_build_all ;;
    0) exit 0 ;;
    *) echo "无效的选项" ;;
  esac
}

interactive() {
  print_menu
  while true; do
    read -rp "请输入数字选择：" num
    run_by_id "$num"
    [ "$num" = "0" ] && break
    print_menu
  done
}

main() {
  if [ "$1" = "--list" ]; then
    print_menu
    exit 0
  fi
  if [ "$1" = "--action" ] && [ -n "$2" ]; then
    run_by_id "$2"
    exit 0
  fi
  interactive
}

main "$@"
