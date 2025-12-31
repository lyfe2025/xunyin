import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcrypt';

const connectionString = process.env.DATABASE_URL;

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Start seeding ...');

  // 1. Init Dept (层级结构)
  const ensureDept = async (data: {
    deptName: string;
    orderNum?: number;
    status?: '0' | '1';
    parentId?: bigint | null;
    leader?: string;
    phone?: string;
    email?: string;
  }) => {
    const existed = await prisma.sysDept.findFirst({
      where: { deptName: data.deptName, delFlag: '0' },
    });
    let ancestors = '0';
    if (data.parentId) {
      const parent = await prisma.sysDept.findUnique({
        where: { deptId: data.parentId },
      });
      if (parent) {
        ancestors = `${parent.ancestors || '0'},${data.parentId}`;
      }
    }
    if (existed) {
      return prisma.sysDept.update({
        where: { deptId: existed.deptId },
        data: {
          ...data,
          ancestors,
        },
      });
    }
    return prisma.sysDept.create({
      data: {
        deptName: data.deptName,
        orderNum: data.orderNum ?? 0,
        status: data.status ?? '0',
        parentId: data.parentId ?? null,
        leader: data.leader ?? '',
        phone: data.phone ?? '',
        email: data.email ?? '',
        ancestors,
      },
    });
  };

  const rootDept = await ensureDept({
    deptName: '总公司',
    orderNum: 0,
    status: '0',
    parentId: null,
    leader: '张总',
  });
  const techDept = await ensureDept({
    deptName: '技术部',
    orderNum: 1,
    parentId: rootDept.deptId,
    leader: '李工',
  });
  const devDept = await ensureDept({
    deptName: '研发一部',
    orderNum: 2,
    parentId: techDept.deptId,
    leader: '王工',
  });
  const testDept = await ensureDept({
    deptName: '测试一部',
    orderNum: 3,
    parentId: techDept.deptId,
    leader: '赵工',
  });
  await ensureDept({
    deptName: '人事部',
    orderNum: 4,
    parentId: rootDept.deptId,
    leader: '刘姐',
  });
  await ensureDept({
    deptName: '财务部',
    orderNum: 5,
    parentId: rootDept.deptId,
    leader: '钱会',
  });
  const eastBranch = await ensureDept({
    deptName: '华东分公司',
    orderNum: 6,
    parentId: rootDept.deptId,
    leader: '孙总',
  });
  await ensureDept({
    deptName: '上海办事处',
    orderNum: 7,
    parentId: eastBranch.deptId,
    leader: '周主任',
  });
  await ensureDept({
    deptName: '杭州办事处',
    orderNum: 8,
    parentId: eastBranch.deptId,
    leader: '吴主任',
  });
  console.log('Initialized department hierarchy');

  // 2. Init Roles (管理后台角色体系 - 幂等,所有角色启用状态)
  const ensureRole = async (data: {
    roleKey: string;
    roleName: string;
    roleSort: number;
    status?: '0' | '1';
    dataScope?: '1' | '2' | '3' | '4';
    menuCheckStrictly?: boolean;
    deptCheckStrictly?: boolean;
    remark?: string;
  }) => {
    const existed = await prisma.sysRole.findFirst({
      where: { roleKey: data.roleKey, delFlag: '0' },
    });
    if (existed) {
      return prisma.sysRole.update({
        where: { roleId: existed.roleId },
        data: {
          roleName: data.roleName,
          roleSort: data.roleSort,
          status: data.status ?? '0',
          dataScope: data.dataScope ?? '1',
          menuCheckStrictly: data.menuCheckStrictly ?? true,
          deptCheckStrictly: data.deptCheckStrictly ?? true,
          remark: data.remark,
        },
      });
    }
    return prisma.sysRole.create({
      data: {
        roleName: data.roleName,
        roleKey: data.roleKey,
        roleSort: data.roleSort,
        status: data.status ?? '0',
        dataScope: data.dataScope ?? '1',
        menuCheckStrictly: data.menuCheckStrictly ?? true,
        deptCheckStrictly: data.deptCheckStrictly ?? true,
        remark: data.remark,
      },
    });
  };

  const adminRole = await ensureRole({
    roleKey: 'admin',
    roleName: '超级管理员',
    roleSort: 1,
    status: '0',
    dataScope: '1',
    remark: '拥有系统所有权限',
  });
  console.log(`Ensured admin role with id: ${adminRole.roleId}`);

  const systemAdminRole = await ensureRole({
    roleKey: 'system_admin',
    roleName: '系统管理员',
    roleSort: 2,
    status: '0',
    dataScope: '2',
    remark: '负责系统管理模块',
  });

  const monitorAdminRole = await ensureRole({
    roleKey: 'monitor_admin',
    roleName: '监控管理员',
    roleSort: 3,
    status: '0',
    dataScope: '1',
    remark: '负责系统监控模块',
  });

  const commonUserRole = await ensureRole({
    roleKey: 'common_user',
    roleName: '普通用户',
    roleSort: 4,
    status: '0',
    dataScope: '3',
    remark: '只读权限,无增删改权限',
  });
  console.log('Ensured all admin roles');

  // 3. 初始化用户（使用 bcrypt 加密密码，保持与服务层一致 - 幂等）
  const ensureUser = async (data: {
    userName: string;
    nickName: string;
    password: string;
    deptId: bigint;
    status?: '0' | '1';
    email?: string;
    phonenumber?: string;
    sex?: '0' | '1' | '2';
    remark?: string;
  }) => {
    const existed = await prisma.sysUser.findFirst({
      where: { userName: data.userName, delFlag: '0' },
    });
    if (existed) {
      // 存在则更新(但不更新密码,避免覆盖用户修改的密码)
      return prisma.sysUser.update({
        where: { userId: existed.userId },
        data: {
          nickName: data.nickName,
          deptId: data.deptId,
          status: data.status ?? '0',
          email: data.email,
          phonenumber: data.phonenumber,
          sex: data.sex,
          remark: data.remark,
        },
      });
    }
    return prisma.sysUser.create({
      data: {
        userName: data.userName,
        nickName: data.nickName,
        password: data.password,
        status: data.status ?? '0',
        deptId: data.deptId,
        email: data.email,
        phonenumber: data.phonenumber,
        sex: data.sex,
        remark: data.remark,
      },
    });
  };

  const salt = await bcrypt.genSalt(10);
  // 默认密码与文档保持一致
  const hashedPassword = await bcrypt.hash('admin123', salt);

  const adminUser = await ensureUser({
    userName: 'admin',
    nickName: '超级管理员',
    password: hashedPassword,
    deptId: rootDept.deptId,
    email: 'admin@example.com',
    phonenumber: '13800000000',
    sex: '0',
    remark: '系统超级管理员账号',
  });
  console.log(`Ensured admin user with id: ${adminUser.userId}`);

  const systemAdminUser = await ensureUser({
    userName: 'system_admin',
    nickName: '系统管理员',
    password: hashedPassword,
    deptId: techDept.deptId,
    email: 'system@example.com',
    phonenumber: '13800000001',
    sex: '0',
    remark: '负责系统管理',
  });

  const monitorAdminUser = await ensureUser({
    userName: 'monitor_admin',
    nickName: '监控管理员',
    password: hashedPassword,
    deptId: devDept.deptId,
    email: 'monitor@example.com',
    phonenumber: '13800000002',
    sex: '1',
    remark: '负责系统监控',
  });

  const commonUser = await ensureUser({
    userName: 'user',
    nickName: '普通用户',
    password: hashedPassword,
    deptId: testDept.deptId,
    email: 'user@example.com',
    phonenumber: '13800000003',
    sex: '1',
    remark: '普通用户账号',
  });
  console.log('Ensured all users');

  // 4. Link User and Role (幂等)
  const ensureUserRole = async (userId: bigint, roleId: bigint) => {
    const existed = await prisma.sysUserRole.findFirst({
      where: { userId, roleId },
    });
    if (!existed) {
      await prisma.sysUserRole.create({
        data: { userId, roleId },
      });
    }
  };

  await ensureUserRole(adminUser.userId, adminRole.roleId);
  await ensureUserRole(systemAdminUser.userId, systemAdminRole.roleId);
  await ensureUserRole(monitorAdminUser.userId, monitorAdminRole.roleId);
  await ensureUserRole(commonUser.userId, commonUserRole.roleId);
  console.log('Linked all users and roles');

  // 5. 初始化基础菜单（存在则跳过，避免重复）
  const ensureMenu = async (data: {
    menuName: string;
    path: string;
    component: string;
    orderNum: number;
    menuType: 'M' | 'C' | 'F';
    visible?: '0' | '1';
    status?: '0' | '1';
    icon?: string;
    isFrame?: number;
    parentId?: bigint | null;
    perms?: string | null;
  }) => {
    const existed = await prisma.sysMenu.findFirst({
      where: { path: data.path },
    });
    if (existed) {
      return prisma.sysMenu.update({ where: { menuId: existed.menuId }, data });
    }
    return prisma.sysMenu.create({ data });
  };

  const ensureButton = async (data: {
    menuName: string;
    parentId: bigint;
    perms: string;
    orderNum?: number;
  }) => {
    const existed = await prisma.sysMenu.findFirst({
      where: { perms: data.perms },
    });
    if (existed) return existed;
    return prisma.sysMenu.create({
      data: {
        menuName: data.menuName,
        parentId: data.parentId,
        orderNum: data.orderNum ?? 0,
        menuType: 'F',
        visible: '1',
        status: '0',
        perms: data.perms,
        isFrame: 1,
        path: '',
        icon: '#',
      },
    });
  };

  const getMenuByPath = async (parentId: bigint, path: string) => {
    return prisma.sysMenu.findFirst({
      where: { parentId, path },
    });
  };

  const systemDir = await ensureMenu({
    menuName: '系统管理',
    path: 'system',
    component: 'Layout',
    orderNum: 2,
    menuType: 'M',
    visible: '0',
    status: '0',
    icon: 'settings',
    isFrame: 1,
    parentId: null,
  });
  await ensureMenu({
    menuName: '用户管理',
    parentId: systemDir.menuId,
    path: 'user',
    component: 'system/user/index',
    orderNum: 1,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:user:list',
    icon: 'user',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '角色管理',
    parentId: systemDir.menuId,
    path: 'role',
    component: 'system/role/index',
    orderNum: 2,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:role:list',
    icon: 'users',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '菜单管理',
    parentId: systemDir.menuId,
    path: 'menu',
    component: 'system/menu/index',
    orderNum: 3,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:menu:list',
    icon: 'menu',
    isFrame: 1,
  });

  // system: 其余模块补充
  await ensureMenu({
    menuName: '部门管理',
    parentId: systemDir.menuId,
    path: 'dept',
    component: 'system/dept/index',
    orderNum: 4,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:dept:list',
    icon: 'building-2',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '岗位管理',
    parentId: systemDir.menuId,
    path: 'post',
    component: 'system/post/index',
    orderNum: 5,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:post:list',
    icon: 'badge-check',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '字典管理',
    parentId: systemDir.menuId,
    path: 'dict',
    component: 'system/dict/index',
    orderNum: 6,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:dict:list',
    icon: 'book-a',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '参数设置',
    parentId: systemDir.menuId,
    path: 'config',
    component: 'system/config/index',
    orderNum: 7,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:config:list',
    icon: 'settings-2',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '系统设置',
    parentId: systemDir.menuId,
    path: 'setting',
    component: 'system/setting/index',
    orderNum: 8,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:setting:view',
    icon: 'sliders-vertical',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '通知公告',
    parentId: systemDir.menuId,
    path: 'notice',
    component: 'system/notice/index',
    orderNum: 9,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'system:notice:list',
    icon: 'megaphone',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '更新日志',
    parentId: systemDir.menuId,
    path: 'changelog',
    component: 'system/changelog/index',
    orderNum: 10,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: null,
    icon: 'scroll-text',
    isFrame: 1,
  });

  const monitorDir = await ensureMenu({
    menuName: '系统监控',
    path: 'monitor',
    component: 'Layout',
    orderNum: 3,
    menuType: 'M',
    visible: '0',
    status: '0',
    icon: 'monitor',
    isFrame: 1,
    parentId: null,
  });
  await ensureMenu({
    menuName: '在线用户',
    parentId: monitorDir.menuId,
    path: 'online',
    component: 'monitor/online/index',
    orderNum: 1,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:online:list',
    icon: 'user-check',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '操作日志',
    parentId: monitorDir.menuId,
    path: 'operlog',
    component: 'monitor/operlog/index',
    orderNum: 2,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:operlog:list',
    icon: 'list',
    isFrame: 1,
  });

  // monitor: 其余模块补充
  await ensureMenu({
    menuName: '登录日志',
    parentId: monitorDir.menuId,
    path: 'logininfor',
    component: 'monitor/logininfor/index',
    orderNum: 3,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:logininfor:list',
    icon: 'log-in',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '定时任务',
    parentId: monitorDir.menuId,
    path: 'job',
    component: 'monitor/job/index',
    orderNum: 4,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:job:list',
    icon: 'alarm-clock',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '服务监控',
    parentId: monitorDir.menuId,
    path: 'server',
    component: 'monitor/server/index',
    orderNum: 5,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:server:list',
    icon: 'server',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '缓存监控',
    parentId: monitorDir.menuId,
    path: 'cache',
    component: 'monitor/cache/index',
    orderNum: 6,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:cache:view',
    icon: 'database-backup',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '数据监控',
    parentId: monitorDir.menuId,
    path: 'druid',
    component: 'monitor/druid/index',
    orderNum: 7,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'monitor:druid:view',
    icon: 'database',
    isFrame: 1,
  });

  const toolDir = await ensureMenu({
    menuName: '系统工具',
    path: 'tool',
    component: 'Layout',
    orderNum: 4,
    menuType: 'M',
    visible: '0',
    status: '0',
    icon: 'wrench',
    isFrame: 1,
    parentId: null,
  });
  await ensureMenu({
    menuName: '接口文档',
    parentId: toolDir.menuId,
    path: 'swagger',
    component: 'tool/swagger/index',
    orderNum: 2,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'tool:swagger:view',
    icon: 'file-text',
    isFrame: 1,
  });

  // tool: 其余模块补充
  await ensureMenu({
    menuName: '表单构建',
    parentId: toolDir.menuId,
    path: 'build',
    component: 'tool/build/index',
    orderNum: 3,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'tool:build:view',
    icon: 'factory',
    isFrame: 1,
  });

  // 按钮权限补充（F）
  const userMenu = await getMenuByPath(systemDir.menuId, 'user');
  if (userMenu) {
    await ensureButton({
      menuName: '用户查询',
      parentId: userMenu.menuId,
      perms: 'system:user:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '用户新增',
      parentId: userMenu.menuId,
      perms: 'system:user:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '用户修改',
      parentId: userMenu.menuId,
      perms: 'system:user:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '用户删除',
      parentId: userMenu.menuId,
      perms: 'system:user:remove',
      orderNum: 4,
    });
    await ensureButton({
      menuName: '重置密码',
      parentId: userMenu.menuId,
      perms: 'system:user:resetPwd',
      orderNum: 5,
    });
    await ensureButton({
      menuName: '用户导出',
      parentId: userMenu.menuId,
      perms: 'system:user:export',
      orderNum: 6,
    });
    await ensureButton({
      menuName: '用户导入',
      parentId: userMenu.menuId,
      perms: 'system:user:import',
      orderNum: 7,
    });
  }
  const roleMenu = await getMenuByPath(systemDir.menuId, 'role');
  if (roleMenu) {
    await ensureButton({
      menuName: '角色查询',
      parentId: roleMenu.menuId,
      perms: 'system:role:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '角色新增',
      parentId: roleMenu.menuId,
      perms: 'system:role:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '角色修改',
      parentId: roleMenu.menuId,
      perms: 'system:role:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '角色删除',
      parentId: roleMenu.menuId,
      perms: 'system:role:remove',
      orderNum: 4,
    });
  }
  const menuMenu = await getMenuByPath(systemDir.menuId, 'menu');
  if (menuMenu) {
    await ensureButton({
      menuName: '菜单查询',
      parentId: menuMenu.menuId,
      perms: 'system:menu:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '菜单新增',
      parentId: menuMenu.menuId,
      perms: 'system:menu:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '菜单修改',
      parentId: menuMenu.menuId,
      perms: 'system:menu:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '菜单删除',
      parentId: menuMenu.menuId,
      perms: 'system:menu:remove',
      orderNum: 4,
    });
  }
  const deptMenu = await getMenuByPath(systemDir.menuId, 'dept');
  if (deptMenu) {
    await ensureButton({
      menuName: '部门查询',
      parentId: deptMenu.menuId,
      perms: 'system:dept:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '部门新增',
      parentId: deptMenu.menuId,
      perms: 'system:dept:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '部门修改',
      parentId: deptMenu.menuId,
      perms: 'system:dept:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '部门删除',
      parentId: deptMenu.menuId,
      perms: 'system:dept:remove',
      orderNum: 4,
    });
  }
  const postMenu = await getMenuByPath(systemDir.menuId, 'post');
  if (postMenu) {
    await ensureButton({
      menuName: '岗位查询',
      parentId: postMenu.menuId,
      perms: 'system:post:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '岗位新增',
      parentId: postMenu.menuId,
      perms: 'system:post:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '岗位修改',
      parentId: postMenu.menuId,
      perms: 'system:post:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '岗位删除',
      parentId: postMenu.menuId,
      perms: 'system:post:remove',
      orderNum: 4,
    });
  }
  const dictMenu = await getMenuByPath(systemDir.menuId, 'dict');
  if (dictMenu) {
    await ensureButton({
      menuName: '字典查询',
      parentId: dictMenu.menuId,
      perms: 'system:dict:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '字典新增',
      parentId: dictMenu.menuId,
      perms: 'system:dict:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '字典修改',
      parentId: dictMenu.menuId,
      perms: 'system:dict:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '字典删除',
      parentId: dictMenu.menuId,
      perms: 'system:dict:remove',
      orderNum: 4,
    });
  }
  const configMenu = await getMenuByPath(systemDir.menuId, 'config');
  if (configMenu) {
    await ensureButton({
      menuName: '参数查询',
      parentId: configMenu.menuId,
      perms: 'system:config:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '参数新增',
      parentId: configMenu.menuId,
      perms: 'system:config:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '参数修改',
      parentId: configMenu.menuId,
      perms: 'system:config:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '参数删除',
      parentId: configMenu.menuId,
      perms: 'system:config:remove',
      orderNum: 4,
    });
  }
  const noticeMenu = await getMenuByPath(systemDir.menuId, 'notice');
  if (noticeMenu) {
    await ensureButton({
      menuName: '公告查询',
      parentId: noticeMenu.menuId,
      perms: 'system:notice:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '公告新增',
      parentId: noticeMenu.menuId,
      perms: 'system:notice:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '公告修改',
      parentId: noticeMenu.menuId,
      perms: 'system:notice:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '公告删除',
      parentId: noticeMenu.menuId,
      perms: 'system:notice:remove',
      orderNum: 4,
    });
  }

  // 系统设置按钮
  const settingMenu = await getMenuByPath(systemDir.menuId, 'setting');
  if (settingMenu) {
    await ensureButton({
      menuName: '设置修改',
      parentId: settingMenu.menuId,
      perms: 'system:setting:edit',
      orderNum: 1,
    });
  }

  const jobMenu = await getMenuByPath(monitorDir.menuId, 'job');
  if (jobMenu) {
    await ensureButton({
      menuName: '任务查询',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '任务新增',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '任务修改',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '任务删除',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:remove',
      orderNum: 4,
    });
    await ensureButton({
      menuName: '状态变更',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:changeStatus',
      orderNum: 5,
    });
    await ensureButton({
      menuName: '立即执行',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:run',
      orderNum: 6,
    });
    await ensureButton({
      menuName: '查看日志',
      parentId: jobMenu.menuId,
      perms: 'monitor:job:log',
      orderNum: 7,
    });
  }
  const cacheMenu = await getMenuByPath(monitorDir.menuId, 'cache');
  if (cacheMenu) {
    await ensureButton({
      menuName: '清理指定',
      parentId: cacheMenu.menuId,
      perms: 'monitor:cache:clearName',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '清理全部',
      parentId: cacheMenu.menuId,
      perms: 'monitor:cache:clearAll',
      orderNum: 2,
    });
  }
  const onlineMenu = await getMenuByPath(monitorDir.menuId, 'online');
  if (onlineMenu) {
    await ensureButton({
      menuName: '用户查询',
      parentId: onlineMenu.menuId,
      perms: 'monitor:online:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '强退用户',
      parentId: onlineMenu.menuId,
      perms: 'monitor:online:forceLogout',
      orderNum: 2,
    });
  }
  const operlogMenu = await getMenuByPath(monitorDir.menuId, 'operlog');
  if (operlogMenu) {
    await ensureButton({
      menuName: '日志查询',
      parentId: operlogMenu.menuId,
      perms: 'monitor:operlog:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '日志删除',
      parentId: operlogMenu.menuId,
      perms: 'monitor:operlog:remove',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '日志导出',
      parentId: operlogMenu.menuId,
      perms: 'monitor:operlog:export',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '日志清空',
      parentId: operlogMenu.menuId,
      perms: 'monitor:operlog:clear',
      orderNum: 4,
    });
  }
  const logininforMenu = await getMenuByPath(monitorDir.menuId, 'logininfor');
  if (logininforMenu) {
    await ensureButton({
      menuName: '日志查询',
      parentId: logininforMenu.menuId,
      perms: 'monitor:logininfor:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '日志删除',
      parentId: logininforMenu.menuId,
      perms: 'monitor:logininfor:remove',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '日志导出',
      parentId: logininforMenu.menuId,
      perms: 'monitor:logininfor:export',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '日志清空',
      parentId: logininforMenu.menuId,
      perms: 'monitor:logininfor:clear',
      orderNum: 4,
    });
    await ensureButton({
      menuName: '账户解锁',
      parentId: logininforMenu.menuId,
      perms: 'monitor:logininfor:unlock',
      orderNum: 5,
    });
  }

  // ============ 寻印管理菜单 ============
  const xunyinDir = await ensureMenu({
    menuName: '寻印管理',
    path: 'xunyin',
    component: 'Layout',
    orderNum: 1,
    menuType: 'M',
    visible: '0',
    status: '0',
    icon: 'map-pin',
    isFrame: 1,
    parentId: null,
  });

  // 寻印子菜单
  await ensureMenu({
    menuName: '城市管理',
    parentId: xunyinDir.menuId,
    path: 'city',
    component: 'xunyin/city/index',
    orderNum: 1,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:city:list',
    icon: 'building',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '文化之旅管理',
    parentId: xunyinDir.menuId,
    path: 'journey',
    component: 'xunyin/journey/index',
    orderNum: 2,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:journey:list',
    icon: 'route',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '探索点管理',
    parentId: xunyinDir.menuId,
    path: 'point',
    component: 'xunyin/point/index',
    orderNum: 3,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:point:list',
    icon: 'map-pin-check',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: '印记管理',
    parentId: xunyinDir.menuId,
    path: 'seal',
    component: 'xunyin/seal/index',
    orderNum: 4,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:seal:list',
    icon: 'stamp',
    isFrame: 1,
  });
  await ensureMenu({
    menuName: 'App用户管理',
    parentId: xunyinDir.menuId,
    path: 'appuser',
    component: 'xunyin/appuser/index',
    orderNum: 5,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:appuser:list',
    icon: 'smartphone',
    isFrame: 1,
  });
  // 用户进度管理
  await ensureMenu({
    menuName: '用户进度',
    parentId: xunyinDir.menuId,
    path: 'progress',
    component: 'xunyin/progress/index',
    orderNum: 6,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:progress:list',
    icon: 'list-checks',
    isFrame: 1,
  });

  // 用户印记管理
  await ensureMenu({
    menuName: '用户印记',
    parentId: xunyinDir.menuId,
    path: 'user-seal',
    component: 'xunyin/user-seal/index',
    orderNum: 7,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:userseal:list',
    icon: 'award',
    isFrame: 1,
  });

  await ensureMenu({
    menuName: '数据统计',
    parentId: xunyinDir.menuId,
    path: 'stats',
    component: 'xunyin/dashboard/index',
    orderNum: 8,
    menuType: 'C',
    visible: '0',
    status: '0',
    perms: 'xunyin:stats:view',
    icon: 'chart-bar',
    isFrame: 1,
  });

  // 寻印按钮权限
  const cityMenu = await getMenuByPath(xunyinDir.menuId, 'city');
  if (cityMenu) {
    await ensureButton({
      menuName: '城市查询',
      parentId: cityMenu.menuId,
      perms: 'xunyin:city:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '城市新增',
      parentId: cityMenu.menuId,
      perms: 'xunyin:city:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '城市修改',
      parentId: cityMenu.menuId,
      perms: 'xunyin:city:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '城市删除',
      parentId: cityMenu.menuId,
      perms: 'xunyin:city:remove',
      orderNum: 4,
    });
  }
  const journeyMenu = await getMenuByPath(xunyinDir.menuId, 'journey');
  if (journeyMenu) {
    await ensureButton({
      menuName: '文化之旅查询',
      parentId: journeyMenu.menuId,
      perms: 'xunyin:journey:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '文化之旅新增',
      parentId: journeyMenu.menuId,
      perms: 'xunyin:journey:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '文化之旅修改',
      parentId: journeyMenu.menuId,
      perms: 'xunyin:journey:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '文化之旅删除',
      parentId: journeyMenu.menuId,
      perms: 'xunyin:journey:remove',
      orderNum: 4,
    });
  }
  const pointMenu = await getMenuByPath(xunyinDir.menuId, 'point');
  if (pointMenu) {
    await ensureButton({
      menuName: '探索点查询',
      parentId: pointMenu.menuId,
      perms: 'xunyin:point:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '探索点新增',
      parentId: pointMenu.menuId,
      perms: 'xunyin:point:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '探索点修改',
      parentId: pointMenu.menuId,
      perms: 'xunyin:point:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '探索点删除',
      parentId: pointMenu.menuId,
      perms: 'xunyin:point:remove',
      orderNum: 4,
    });
  }
  const sealMenu = await getMenuByPath(xunyinDir.menuId, 'seal');
  if (sealMenu) {
    await ensureButton({
      menuName: '印记查询',
      parentId: sealMenu.menuId,
      perms: 'xunyin:seal:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: '印记新增',
      parentId: sealMenu.menuId,
      perms: 'xunyin:seal:add',
      orderNum: 2,
    });
    await ensureButton({
      menuName: '印记修改',
      parentId: sealMenu.menuId,
      perms: 'xunyin:seal:edit',
      orderNum: 3,
    });
    await ensureButton({
      menuName: '印记删除',
      parentId: sealMenu.menuId,
      perms: 'xunyin:seal:remove',
      orderNum: 4,
    });
  }
  const appuserMenu = await getMenuByPath(xunyinDir.menuId, 'appuser');
  if (appuserMenu) {
    await ensureButton({
      menuName: 'App用户查询',
      parentId: appuserMenu.menuId,
      perms: 'xunyin:appuser:query',
      orderNum: 1,
    });
    await ensureButton({
      menuName: 'App用户修改',
      parentId: appuserMenu.menuId,
      perms: 'xunyin:appuser:edit',
      orderNum: 2,
    });
    await ensureButton({
      menuName: 'App用户禁用',
      parentId: appuserMenu.menuId,
      perms: 'xunyin:appuser:disable',
      orderNum: 3,
    });
  }
  const statsMenu = await getMenuByPath(xunyinDir.menuId, 'stats');
  if (statsMenu) {
    await ensureButton({
      menuName: '数据统计查看',
      parentId: statsMenu.menuId,
      perms: 'xunyin:stats:view',
      orderNum: 1,
    });
  }

  // 用户进度按钮权限
  const progressMenu = await getMenuByPath(xunyinDir.menuId, 'progress');
  if (progressMenu) {
    await ensureButton({
      menuName: '用户进度查询',
      parentId: progressMenu.menuId,
      perms: 'xunyin:progress:query',
      orderNum: 1,
    });
  }

  // 用户印记按钮权限
  const userSealMenu = await getMenuByPath(xunyinDir.menuId, 'user-seal');
  if (userSealMenu) {
    await ensureButton({
      menuName: '用户印记查询',
      parentId: userSealMenu.menuId,
      perms: 'xunyin:userseal:query',
      orderNum: 1,
    });
  }

  console.log('Initialized xunyin menus');

  // 6. 为不同角色分配菜单权限
  const allMenus = await prisma.sysMenu.findMany({
    select: { menuId: true, path: true, menuType: true, parentId: true },
  });

  if (allMenus.length > 0) {
    // 6.1 超级管理员 - 拥有所有权限
    await prisma.sysRoleMenu.createMany({
      data: allMenus.map((m) => ({
        roleId: adminRole.roleId,
        menuId: m.menuId,
      })),
      skipDuplicates: true,
    });
    console.log(`Linked role(admin) with ${allMenus.length} menus`);

    // 6.2 系统管理员 - 拥有系统管理模块的所有权限
    const systemMenu = allMenus.find((m) => m.path === 'system' && !m.parentId);
    if (systemMenu) {
      const systemMenuIds = allMenus
        .filter(
          (m) =>
            m.menuId === systemMenu.menuId ||
            m.parentId === systemMenu.menuId ||
            allMenus.some(
              (parent) =>
                parent.menuId === m.parentId &&
                parent.parentId === systemMenu.menuId,
            ),
        )
        .map((m) => m.menuId);

      await prisma.sysRoleMenu.createMany({
        data: systemMenuIds.map((menuId) => ({
          roleId: systemAdminRole.roleId,
          menuId,
        })),
        skipDuplicates: true,
      });
      console.log(
        `Linked role(system_admin) with ${systemMenuIds.length} menus`,
      );
    }

    // 6.3 监控管理员 - 拥有系统监控模块的所有权限
    const monitorMenu = allMenus.find(
      (m) => m.path === 'monitor' && !m.parentId,
    );
    const toolMenu = allMenus.find((m) => m.path === 'tool' && !m.parentId);
    const swaggerMenu = allMenus.find((m) => m.path === 'swagger');

    if (monitorMenu) {
      const monitorMenuIds = allMenus
        .filter(
          (m) =>
            m.menuId === monitorMenu.menuId ||
            m.parentId === monitorMenu.menuId ||
            allMenus.some(
              (parent) =>
                parent.menuId === m.parentId &&
                parent.parentId === monitorMenu.menuId,
            ),
        )
        .map((m) => m.menuId);

      // 添加工具菜单和接口文档
      if (toolMenu) monitorMenuIds.push(toolMenu.menuId);
      if (swaggerMenu) monitorMenuIds.push(swaggerMenu.menuId);

      await prisma.sysRoleMenu.createMany({
        data: monitorMenuIds.map((menuId) => ({
          roleId: monitorAdminRole.roleId,
          menuId,
        })),
        skipDuplicates: true,
      });
      console.log(
        `Linked role(monitor_admin) with ${monitorMenuIds.length} menus`,
      );
    }

    // 6.4 普通用户 - 只有查看权限,无增删改权限(只分配C类型菜单,不分配F类型按钮)
    const systemMenu2 = allMenus.find(
      (m) => m.path === 'system' && !m.parentId,
    );
    const monitorMenu2 = allMenus.find(
      (m) => m.path === 'monitor' && !m.parentId,
    );

    const commonUserMenuIds: bigint[] = [];
    if (systemMenu2) {
      commonUserMenuIds.push(systemMenu2.menuId);
      // 只添加系统管理下的C类型菜单
      allMenus
        .filter((m) => m.parentId === systemMenu2.menuId && m.menuType === 'C')
        .forEach((m) => commonUserMenuIds.push(m.menuId));
    }
    if (monitorMenu2) {
      commonUserMenuIds.push(monitorMenu2.menuId);
      // 只添加系统监控下的C类型菜单
      allMenus
        .filter((m) => m.parentId === monitorMenu2.menuId && m.menuType === 'C')
        .forEach((m) => commonUserMenuIds.push(m.menuId));
    }

    await prisma.sysRoleMenu.createMany({
      data: commonUserMenuIds.map((menuId) => ({
        roleId: commonUserRole.roleId,
        menuId,
      })),
      skipDuplicates: true,
    });
    console.log(
      `Linked role(common_user) with ${commonUserMenuIds.length} menus (read-only)`,
    );
  } else {
    console.log('No menus found to link with roles');
  }

  // 7. 初始化常用字典与配置（若不存在则创建）
  const dictTypesToSeed = [
    { dictName: '显示隐藏', dictType: 'sys_show_hide' },
    { dictName: '正常停用', dictType: 'sys_normal_disable' },
    { dictName: '是否', dictType: 'sys_yes_no' },
    { dictName: '用户性别', dictType: 'sys_user_sex' },
    { dictName: '任务状态', dictType: 'sys_job_status' },
    { dictName: '任务分组', dictType: 'sys_job_group' },
    { dictName: '通知类型', dictType: 'sys_notice_type' },
    { dictName: '通知状态', dictType: 'sys_notice_status' },
    { dictName: '操作类型', dictType: 'sys_oper_type' },
    { dictName: '通用状态', dictType: 'sys_common_status' },
    // 寻印业务字典类型
    { dictName: '任务类型', dictType: 'xunyin_task_type' },
    { dictName: '印记类型', dictType: 'xunyin_seal_type' },
    { dictName: '进度状态', dictType: 'xunyin_progress_status' },
    { dictName: '动态类型', dictType: 'xunyin_activity_type' },
    { dictName: '音频场景', dictType: 'xunyin_audio_context' },
    { dictName: '登录方式', dictType: 'xunyin_login_type' },
    { dictName: '性别', dictType: 'xunyin_gender' },
    { dictName: '照片滤镜', dictType: 'xunyin_photo_filter' },
    { dictName: '区块链', dictType: 'xunyin_chain_name' },
  ];
  for (const dt of dictTypesToSeed) {
    const exists = await prisma.sysDictType.findFirst({
      where: { dictType: dt.dictType },
    });
    if (!exists) {
      await prisma.sysDictType.create({
        data: { dictName: dt.dictName, dictType: dt.dictType, status: '0' },
      });
      console.log(`Created dictType: ${dt.dictType}`);
    }
  }

  // 字典数据
  const dictDataToSeed = [
    // 显示隐藏
    {
      dictType: 'sys_show_hide',
      dictLabel: '显示',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'sys_show_hide',
      dictLabel: '隐藏',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    // 正常停用
    {
      dictType: 'sys_normal_disable',
      dictLabel: '正常',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'sys_normal_disable',
      dictLabel: '停用',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    // 是否
    {
      dictType: 'sys_yes_no',
      dictLabel: '是',
      dictValue: 'Y',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'sys_yes_no',
      dictLabel: '否',
      dictValue: 'N',
      dictSort: 2,
      isDefault: 'N',
    },
    // 性别
    {
      dictType: 'sys_user_sex',
      dictLabel: '男',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'sys_user_sex',
      dictLabel: '女',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'sys_user_sex',
      dictLabel: '未知',
      dictValue: '2',
      dictSort: 3,
      isDefault: 'Y',
    },
    // 任务状态
    {
      dictType: 'sys_job_status',
      dictLabel: '正常',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'sys_job_status',
      dictLabel: '暂停',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    // 任务分组
    {
      dictType: 'sys_job_group',
      dictLabel: 'DEFAULT',
      dictValue: 'DEFAULT',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'sys_job_group',
      dictLabel: 'SYSTEM',
      dictValue: 'SYSTEM',
      dictSort: 2,
      isDefault: 'N',
    },
    // 通知类型
    {
      dictType: 'sys_notice_type',
      dictLabel: '通知',
      dictValue: '1',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'sys_notice_type',
      dictLabel: '公告',
      dictValue: '2',
      dictSort: 2,
      isDefault: 'N',
    },
    // 通知状态
    {
      dictType: 'sys_notice_status',
      dictLabel: '正常',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'sys_notice_status',
      dictLabel: '关闭',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    // 操作类型
    {
      dictType: 'sys_oper_type',
      dictLabel: '其它',
      dictValue: '0',
      dictSort: 0,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '新增',
      dictValue: '1',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '修改',
      dictValue: '2',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '删除',
      dictValue: '3',
      dictSort: 3,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '授权',
      dictValue: '4',
      dictSort: 4,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '导出',
      dictValue: '5',
      dictSort: 5,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '导入',
      dictValue: '6',
      dictSort: 6,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '强退',
      dictValue: '7',
      dictSort: 7,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '生成代码',
      dictValue: '8',
      dictSort: 8,
      isDefault: 'N',
    },
    {
      dictType: 'sys_oper_type',
      dictLabel: '清空数据',
      dictValue: '9',
      dictSort: 9,
      isDefault: 'N',
    },
    // 通用状态
    {
      dictType: 'sys_common_status',
      dictLabel: '成功',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'sys_common_status',
      dictLabel: '失败',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    // ============ 寻印业务字典数据 ============
    // 任务类型
    {
      dictType: 'xunyin_task_type',
      dictLabel: '手势识别',
      dictValue: 'gesture',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_task_type',
      dictLabel: '拍照探索',
      dictValue: 'photo',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_task_type',
      dictLabel: 'AR寻宝',
      dictValue: 'treasure',
      dictSort: 3,
      isDefault: 'N',
    },
    // 印记类型
    {
      dictType: 'xunyin_seal_type',
      dictLabel: '路线印记',
      dictValue: 'route',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_seal_type',
      dictLabel: '城市印记',
      dictValue: 'city',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_seal_type',
      dictLabel: '特殊印记',
      dictValue: 'special',
      dictSort: 3,
      isDefault: 'N',
    },
    // 进度状态
    {
      dictType: 'xunyin_progress_status',
      dictLabel: '进行中',
      dictValue: 'in_progress',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'xunyin_progress_status',
      dictLabel: '已完成',
      dictValue: 'completed',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_progress_status',
      dictLabel: '已放弃',
      dictValue: 'abandoned',
      dictSort: 3,
      isDefault: 'N',
    },
    // 动态类型
    {
      dictType: 'xunyin_activity_type',
      dictLabel: '获得印记',
      dictValue: 'seal_earned',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_activity_type',
      dictLabel: '完成文化之旅',
      dictValue: 'journey_completed',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_activity_type',
      dictLabel: '开始文化之旅',
      dictValue: 'journey_started',
      dictSort: 3,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_activity_type',
      dictLabel: '完成探索点',
      dictValue: 'point_completed',
      dictSort: 4,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_activity_type',
      dictLabel: '升级',
      dictValue: 'level_up',
      dictSort: 5,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_activity_type',
      dictLabel: '获得称号',
      dictValue: 'badge_earned',
      dictSort: 6,
      isDefault: 'N',
    },
    // 音频场景
    {
      dictType: 'xunyin_audio_context',
      dictLabel: '首页',
      dictValue: 'home',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_audio_context',
      dictLabel: '城市',
      dictValue: 'city',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_audio_context',
      dictLabel: '文化之旅',
      dictValue: 'journey',
      dictSort: 3,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_audio_context',
      dictLabel: '探索点',
      dictValue: 'point',
      dictSort: 4,
      isDefault: 'N',
    },
    // 登录方式
    {
      dictType: 'xunyin_login_type',
      dictLabel: '微信登录',
      dictValue: 'wechat',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'xunyin_login_type',
      dictLabel: '邮箱登录',
      dictValue: 'email',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_login_type',
      dictLabel: 'Google登录',
      dictValue: 'google',
      dictSort: 3,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_login_type',
      dictLabel: 'Apple登录',
      dictValue: 'apple',
      dictSort: 4,
      isDefault: 'N',
    },
    // 性别
    {
      dictType: 'xunyin_gender',
      dictLabel: '男',
      dictValue: '0',
      dictSort: 1,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_gender',
      dictLabel: '女',
      dictValue: '1',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_gender',
      dictLabel: '未知',
      dictValue: '2',
      dictSort: 3,
      isDefault: 'Y',
    },
    // 照片滤镜
    {
      dictType: 'xunyin_photo_filter',
      dictLabel: '原图',
      dictValue: 'original',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'xunyin_photo_filter',
      dictLabel: '复古',
      dictValue: 'vintage',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_photo_filter',
      dictLabel: '黑白',
      dictValue: 'mono',
      dictSort: 3,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_photo_filter',
      dictLabel: '暖色',
      dictValue: 'warm',
      dictSort: 4,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_photo_filter',
      dictLabel: '冷色',
      dictValue: 'cool',
      dictSort: 5,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_photo_filter',
      dictLabel: '胶片',
      dictValue: 'film',
      dictSort: 6,
      isDefault: 'N',
    },
    // 区块链
    {
      dictType: 'xunyin_chain_name',
      dictLabel: '蚂蚁链',
      dictValue: 'antchain',
      dictSort: 1,
      isDefault: 'Y',
    },
    {
      dictType: 'xunyin_chain_name',
      dictLabel: '长安链',
      dictValue: 'chainmaker',
      dictSort: 2,
      isDefault: 'N',
    },
    {
      dictType: 'xunyin_chain_name',
      dictLabel: '至信链',
      dictValue: 'zhixin',
      dictSort: 3,
      isDefault: 'N',
    },
  ];
  for (const dd of dictDataToSeed) {
    const exists = await prisma.sysDictData.findFirst({
      where: { dictType: dd.dictType, dictValue: dd.dictValue },
    });
    if (!exists) {
      await prisma.sysDictData.create({
        data: {
          dictType: dd.dictType,
          dictLabel: dd.dictLabel,
          dictValue: dd.dictValue,
          dictSort: dd.dictSort,
          isDefault: dd.isDefault,
          status: '0',
        },
      });
      console.log(`Created dictData: ${dd.dictType}/${dd.dictValue}`);
    }
  }

  // 系统配置
  const configsToSeed = [
    // 账户安全设置
    {
      configName: '初始密码',
      configKey: 'sys.account.initPassword',
      configValue: 'admin123',
      configType: 'Y',
    },
    {
      configName: '验证码开关',
      configKey: 'sys.account.captchaEnabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: '两步验证开关',
      configKey: 'sys.account.twoFactorEnabled',
      configValue: 'false',
      configType: 'Y',
    },

    // 网站信息设置
    {
      configName: '网站名称',
      configKey: 'sys.app.name',
      configValue: '寻印管理后台',
      configType: 'Y',
    },
    {
      configName: '网站描述',
      configKey: 'sys.app.description',
      configValue: '城市文化探索与数字印记收藏平台',
      configType: 'Y',
    },
    {
      configName: '版权信息',
      configKey: 'sys.app.copyright',
      configValue: '© 2025 Xunyin. All rights reserved.',
      configType: 'Y',
    },
    {
      configName: 'ICP备案号',
      configKey: 'sys.app.icp',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '联系邮箱',
      configKey: 'sys.app.email',
      configValue: 'admin@example.com',
      configType: 'Y',
    },
    // 邮件设置
    {
      configName: '邮件服务开关',
      configKey: 'sys.mail.enabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: 'SMTP服务器',
      configKey: 'sys.mail.host',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'SMTP端口',
      configKey: 'sys.mail.port',
      configValue: '465',
      configType: 'Y',
    },
    {
      configName: '邮箱账号',
      configKey: 'sys.mail.username',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '邮箱密码',
      configKey: 'sys.mail.password',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '发件人地址',
      configKey: 'sys.mail.from',
      configValue: '',
      configType: 'Y',
    },
    // 存储设置
    {
      configName: '存储类型',
      configKey: 'sys.storage.type',
      configValue: 'local',
      configType: 'Y',
    },
    {
      configName: '本地存储路径',
      configKey: 'sys.storage.local.path',
      configValue: './uploads',
      configType: 'Y',
    },
    {
      configName: 'OSS端点',
      configKey: 'sys.storage.oss.endpoint',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'OSS存储桶',
      configKey: 'sys.storage.oss.bucket',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'OSS AccessKey',
      configKey: 'sys.storage.oss.accessKey',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'OSS SecretKey',
      configKey: 'sys.storage.oss.secretKey',
      configValue: '',
      configType: 'Y',
    },
    // 网站Logo和图标
    {
      configName: '网站Logo',
      configKey: 'sys.app.logo',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '网站图标',
      configKey: 'sys.app.favicon',
      configValue: '',
      configType: 'Y',
    },

    // 安全入口
    {
      configName: '安全登录路径',
      configKey: 'sys.security.loginPath',
      configValue: '/login',
      configType: 'Y',
    },
    // 登录限制
    {
      configName: '登录失败次数',
      configKey: 'sys.login.maxRetry',
      configValue: '5',
      configType: 'Y',
    },
    {
      configName: '账户锁定时长',
      configKey: 'sys.login.lockTime',
      configValue: '10',
      configType: 'Y',
    },
    // 会话设置
    {
      configName: '会话超时时间',
      configKey: 'sys.session.timeout',
      configValue: '30',
      configType: 'Y',
    },
    // 邮件SSL
    {
      configName: 'SSL/TLS开关',
      configKey: 'sys.mail.ssl',
      configValue: 'true',
      configType: 'Y',
    },

    // ========== 三方登录配置 ==========
    // 微信登录
    {
      configName: '微信登录开关',
      configKey: 'oauth.wechat.enabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: '微信AppID',
      configKey: 'oauth.wechat.appId',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '微信AppSecret',
      configKey: 'oauth.wechat.appSecret',
      configValue: '',
      configType: 'Y',
    },
    // Google登录
    {
      configName: 'Google登录开关',
      configKey: 'oauth.google.enabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: 'Google Client ID',
      configKey: 'oauth.google.clientId',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'Google Client Secret',
      configKey: 'oauth.google.clientSecret',
      configValue: '',
      configType: 'Y',
    },
    // Apple登录
    {
      configName: 'Apple登录开关',
      configKey: 'oauth.apple.enabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: 'Apple Team ID',
      configKey: 'oauth.apple.teamId',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'Apple Client ID',
      configKey: 'oauth.apple.clientId',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'Apple Key ID',
      configKey: 'oauth.apple.keyId',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'Apple Private Key',
      configKey: 'oauth.apple.privateKey',
      configValue: '',
      configType: 'Y',
    },

    // ========== 地图配置 ==========
    // 高德地图
    {
      configName: '高德地图开关',
      configKey: 'map.amap.enabled',
      configValue: 'true',
      configType: 'Y',
    },
    {
      configName: '高德Web服务Key',
      configKey: 'map.amap.webKey',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '高德Android Key',
      configKey: 'map.amap.androidKey',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '高德iOS Key',
      configKey: 'map.amap.iosKey',
      configValue: '',
      configType: 'Y',
    },
    // 腾讯地图
    {
      configName: '腾讯地图开关',
      configKey: 'map.tencent.enabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: '腾讯地图Key',
      configKey: 'map.tencent.key',
      configValue: '',
      configType: 'Y',
    },
    // Google地图（海外）
    {
      configName: 'Google地图开关',
      configKey: 'map.google.enabled',
      configValue: 'false',
      configType: 'Y',
    },
    {
      configName: 'Google地图Key',
      configKey: 'map.google.key',
      configValue: '',
      configType: 'Y',
    },

    // ========== App配置 ==========
    {
      configName: 'App名称',
      configKey: 'app.name',
      configValue: '寻印',
      configType: 'Y',
    },
    {
      configName: 'App版本',
      configKey: 'app.version',
      configValue: '1.0.0',
      configType: 'Y',
    },
    {
      configName: '强制更新版本',
      configKey: 'app.forceUpdateVersion',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: 'App下载地址',
      configKey: 'app.downloadUrl',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '用户协议URL',
      configKey: 'app.userAgreementUrl',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '隐私政策URL',
      configKey: 'app.privacyPolicyUrl',
      configValue: '',
      configType: 'Y',
    },
    {
      configName: '用户协议内容',
      configKey: 'app.userAgreementContent',
      configValue: `<h1>用户服务协议</h1>
<p>欢迎使用寻印！在使用本应用前，请您仔细阅读以下协议条款。</p>

<h2>一、服务说明</h2>
<p>寻印是一款城市文化探索与数字印记收藏平台，为用户提供以下服务：</p>
<ul>
  <li>城市文化之旅探索</li>
  <li>探索点打卡与任务完成</li>
  <li>数字印记收集与展示</li>
  <li>个人探索记录管理</li>
</ul>

<h2>二、用户账号</h2>
<p>1. 您需要注册账号才能使用本应用的完整功能。</p>
<p>2. 您应妥善保管账号信息，因账号泄露造成的损失由您自行承担。</p>
<p>3. 禁止将账号转让、出借给他人使用。</p>

<h2>三、用户行为规范</h2>
<p>使用本应用时，您承诺：</p>
<ul>
  <li>遵守国家法律法规</li>
  <li>不发布违法、有害信息</li>
  <li>不干扰应用正常运行</li>
  <li>尊重其他用户权益</li>
</ul>

<h2>四、知识产权</h2>
<p>本应用的所有内容（包括但不限于文字、图片、音频、视频、软件）的知识产权归寻印所有，未经授权不得使用。</p>

<h2>五、免责声明</h2>
<p>1. 因不可抗力导致的服务中断，我们不承担责任。</p>
<p>2. 用户在探索过程中应注意人身安全，因用户自身原因造成的损失由用户自行承担。</p>

<h2>六、协议修改</h2>
<p>我们保留随时修改本协议的权利，修改后的协议将在应用内公布。继续使用本应用即表示您接受修改后的协议。</p>

<p><strong>如您对本协议有任何疑问，请联系我们。</strong></p>`,
      configType: 'Y',
    },
    {
      configName: '隐私政策内容',
      configKey: 'app.privacyPolicyContent',
      configValue: `<h1>隐私政策</h1>
<p>寻印非常重视您的隐私保护。本隐私政策说明我们如何收集、使用和保护您的个人信息。</p>

<h2>一、信息收集</h2>
<p>我们可能收集以下类型的信息：</p>

<h3>1. 您主动提供的信息</h3>
<ul>
  <li>注册信息：手机号、昵称、头像</li>
  <li>个人资料：性别、生日、个性签名</li>
</ul>

<h3>2. 自动收集的信息</h3>
<ul>
  <li>设备信息：设备型号、操作系统版本</li>
  <li>位置信息：用于探索点打卡功能（需您授权）</li>
  <li>使用记录：探索记录、印记收集记录</li>
</ul>

<h2>二、信息使用</h2>
<p>我们使用收集的信息用于：</p>
<ul>
  <li>提供、维护和改进我们的服务</li>
  <li>验证您的身份和位置</li>
  <li>记录您的探索进度和成就</li>
  <li>向您发送服务通知</li>
  <li>保障服务安全</li>
</ul>

<h2>三、信息共享</h2>
<p>我们不会向第三方出售您的个人信息。仅在以下情况下可能共享：</p>
<ul>
  <li>获得您的明确同意</li>
  <li>法律法规要求</li>
  <li>保护我们或用户的合法权益</li>
</ul>

<h2>四、信息安全</h2>
<p>我们采取多种安全措施保护您的信息：</p>
<ul>
  <li>数据加密传输和存储</li>
  <li>访问权限控制</li>
  <li>安全审计和监控</li>
</ul>

<h2>五、您的权利</h2>
<p>您有权：</p>
<ul>
  <li>访问和更正您的个人信息</li>
  <li>删除您的账号和数据</li>
  <li>撤回授权同意</li>
  <li>获取个人信息副本</li>
</ul>

<h2>六、未成年人保护</h2>
<p>我们非常重视未成年人的隐私保护。如果您是未成年人，请在监护人指导下使用本应用。</p>

<h2>七、政策更新</h2>
<p>我们可能会更新本隐私政策。更新后的政策将在应用内公布，请定期查阅。</p>

<h2>八、联系我们</h2>
<p>如您对本隐私政策有任何疑问，请通过以下方式联系我们：</p>
<p>邮箱：privacy@xunyin.app</p>

<p><em>最后更新日期：2025年1月</em></p>`,
      configType: 'Y',
    },
  ];
  for (const cfg of configsToSeed) {
    const exists = await prisma.sysConfig.findFirst({
      where: { configKey: cfg.configKey },
    });
    if (!exists) {
      await prisma.sysConfig.create({
        data: {
          configName: cfg.configName,
          configKey: cfg.configKey,
          configValue: cfg.configValue,
          configType: cfg.configType,
        },
      });
      console.log(`Created config: ${cfg.configKey}`);
    }
  }

  // 8. 岗位样例
  const posts = [
    { postCode: 'dev', postName: '开发', postSort: 1, status: '0' },
    { postCode: 'pm', postName: '产品经理', postSort: 2, status: '0' },
  ];
  for (const p of posts) {
    const exist = await prisma.sysPost.findFirst({
      where: { postCode: p.postCode },
    });
    if (!exist) {
      await prisma.sysPost.create({ data: p });
    }
  }

  // 9.1 绑定用户岗位（示例）：admin -> dev，user -> pm
  const devPost = await prisma.sysPost.findFirst({
    where: { postCode: 'dev' },
  });
  const pmPost = await prisma.sysPost.findFirst({
    where: { postCode: 'pm' },
  });
  if (devPost && pmPost) {
    await prisma.sysUserPost.createMany({
      data: [
        { userId: adminUser.userId, postId: devPost.postId },
        { userId: systemAdminUser.userId, postId: devPost.postId },
        { userId: monitorAdminUser.userId, postId: devPost.postId },
        { userId: commonUser.userId, postId: pmPost.postId },
      ],
      skipDuplicates: true,
    });
  }

  // 10. 公告样例
  const noticeExist = await prisma.sysNotice.findFirst({
    where: { noticeTitle: '系统维护' },
  });
  if (!noticeExist) {
    await prisma.sysNotice.create({
      data: {
        noticeTitle: '系统维护',
        noticeType: '2',
        noticeContent: '本周日凌晨进行系统维护。',
        status: '0',
      },
    });
  }

  // 11. 任务样例
  const jobExist = await prisma.sysJob.findFirst({
    where: { jobName: '示例任务' },
  });
  if (!jobExist) {
    await prisma.sysJob.create({
      data: {
        jobName: '示例任务',
        jobGroup: 'DEFAULT',
        invokeTarget: 'log:示例任务执行成功',
        cronExpression: '0/30 * * * * *',
        misfirePolicy: '3',
        concurrent: '1',
        status: '0',
      },
    });
  }

  // 11.1 任务日志样例
  const sampleJobLogCount = await prisma.sysJobLog.count();
  if (sampleJobLogCount === 0) {
    await prisma.sysJobLog.createMany({
      data: [
        {
          jobName: '示例任务',
          jobGroup: 'DEFAULT',
          invokeTarget: 'log:示例任务执行成功',
          jobMessage: '执行成功',
          status: '0',
        },
        {
          jobName: '示例任务',
          jobGroup: 'DEFAULT',
          invokeTarget: 'log:示例任务执行成功',
          jobMessage: '执行失败：模拟异常',
          status: '1',
          exceptionInfo: 'MockError: something wrong',
        },
      ],
      skipDuplicates: true,
    });
  }

  // 12. 登录日志样例
  const loginLogExist = await prisma.sysLoginLog.count();
  if (loginLogExist === 0) {
    await prisma.sysLoginLog.createMany({
      data: [
        {
          userName: 'admin',
          ipaddr: '127.0.0.1',
          browser: 'Chrome',
          os: 'macOS',
          status: '0',
          msg: '登录成功',
        },
        {
          userName: 'user',
          ipaddr: '127.0.0.1',
          browser: 'Chrome',
          os: 'macOS',
          status: '1',
          msg: '密码错误',
        },
      ],
      skipDuplicates: true,
    });
  }

  // 13. 操作日志样例
  const operLogCount = await prisma.sysOperLog.count();
  if (operLogCount === 0) {
    await prisma.sysOperLog.createMany({
      data: [
        {
          title: '部门管理',
          businessType: 1,
          method: 'DeptController.create',
          requestMethod: 'POST',
          operName: 'admin',
          deptName: '总公司',
          operUrl: '/system/dept',
          operIp: '127.0.0.1',
          operLocation: '内网',
          operParam: '{"deptName":"技术部"}',
          jsonResult: '{"code":200}',
          status: 0,
        },
        {
          title: '岗位管理',
          businessType: 3,
          method: 'PostController.remove',
          requestMethod: 'DELETE',
          operName: 'admin',
          deptName: '总公司',
          operUrl: '/system/post',
          operIp: '127.0.0.1',
          operLocation: '内网',
          operParam: '{"ids":"1,2"}',
          jsonResult: '{"code":200}',
          status: 0,
        },
      ],
      skipDuplicates: true,
    });
  }

  // ==================== 寻印业务初始数据 ====================

  // 检查是否已有城市数据
  const existingCities = await prisma.city.count();
  if (existingCities === 0) {
    console.log('Seeding xunyin business data...');

    // 创建城市
    const hangzhou = await prisma.city.create({
      data: {
        name: '杭州',
        province: '浙江省',
        latitude: 30.2741,
        longitude: 120.1551,
        description:
          '杭州，简称"杭"，是浙江省省会，素有"人间天堂"的美誉。西湖、灵隐寺、雷峰塔等名胜古迹闻名遐迩。',
        coverImage: '',
        explorerCount: 0,
        orderNum: 1,
        status: '0',
      },
    });
    console.log(`Created city: ${hangzhou.name}`);

    const suzhou = await prisma.city.create({
      data: {
        name: '苏州',
        province: '江苏省',
        latitude: 31.2989,
        longitude: 120.5853,
        description:
          '苏州，古称姑苏，是江苏省地级市。以园林著称，拙政园、留园等被列入世界文化遗产。',
        coverImage: '',
        explorerCount: 0,
        orderNum: 2,
        status: '0',
      },
    });
    console.log(`Created city: ${suzhou.name}`);

    const nanjing = await prisma.city.create({
      data: {
        name: '南京',
        province: '江苏省',
        latitude: 32.0603,
        longitude: 118.7969,
        description:
          '南京，简称"宁"，是江苏省省会，六朝古都，有着深厚的历史文化底蕴。',
        coverImage: '',
        explorerCount: 0,
        orderNum: 3,
        status: '0',
      },
    });
    console.log(`Created city: ${nanjing.name}`);

    // 创建福州
    const fuzhou = await prisma.city.create({
      data: {
        name: '福州',
        province: '福建省',
        latitude: 26.0745,
        longitude: 119.2965,
        description:
          '福州，别称榕城，是福建省省会，有着2200多年的建城史。三坊七巷、鼓山、西湖等名胜古迹众多，是中国历史文化名城。',
        coverImage: '',
        explorerCount: 0,
        orderNum: 4,
        status: '0',
      },
    });
    console.log(`Created city: ${fuzhou.name}`);

    // 创建杭州的文化之旅
    const westLakeJourney = await prisma.journey.create({
      data: {
        cityId: hangzhou.id,
        name: '西湖十景探秘',
        theme: '自然风光',
        description:
          '漫步西湖，探寻苏堤春晓、断桥残雪等十大经典景观，感受"欲把西湖比西子"的诗意之美。',
        coverImage: '',
        rating: 3,
        estimatedMinutes: 180,
        totalDistance: 8500,
        completedCount: 0,
        isLocked: false,
        orderNum: 1,
        status: '0',
      },
    });
    console.log(`Created journey: ${westLakeJourney.name}`);

    const lingyinJourney = await prisma.journey.create({
      data: {
        cityId: hangzhou.id,
        name: '灵隐禅踪',
        theme: '佛教文化',
        description:
          '探访千年古刹灵隐寺，感受飞来峰石刻艺术，体验禅宗文化的深邃与宁静。',
        coverImage: '',
        rating: 4,
        estimatedMinutes: 120,
        totalDistance: 3200,
        completedCount: 0,
        isLocked: false,
        orderNum: 2,
        status: '0',
      },
    });
    console.log(`Created journey: ${lingyinJourney.name}`);

    // 创建苏州的文化之旅
    const gardenJourney = await prisma.journey.create({
      data: {
        cityId: suzhou.id,
        name: '园林雅韵',
        theme: '古典园林',
        description:
          '游览拙政园、留园等世界文化遗产，领略"咫尺之内再造乾坤"的园林艺术。',
        coverImage: '',
        rating: 3,
        estimatedMinutes: 150,
        totalDistance: 5000,
        completedCount: 0,
        isLocked: false,
        orderNum: 1,
        status: '0',
      },
    });
    console.log(`Created journey: ${gardenJourney.name}`);

    // 创建福州的文化之旅 - 三坊七巷
    const sanfangqixiangJourney = await prisma.journey.create({
      data: {
        cityId: fuzhou.id,
        name: '三坊七巷寻古',
        theme: '历史街区',
        description:
          '漫步中国都市仅存的"里坊制度活化石"，探访林则徐、严复、冰心等名人故居，感受明清古建筑的独特魅力。',
        coverImage: '',
        rating: 4,
        estimatedMinutes: 150,
        totalDistance: 3500,
        completedCount: 0,
        isLocked: false,
        orderNum: 1,
        status: '0',
      },
    });
    console.log(`Created journey: ${sanfangqixiangJourney.name}`);

    // 创建福州的文化之旅 - 鼓山
    const gushanJourney = await prisma.journey.create({
      data: {
        cityId: fuzhou.id,
        name: '鼓山禅意行',
        theme: '佛教文化',
        description:
          '登临福州第一名山，参拜千年古刹涌泉寺，欣赏摩崖石刻，俯瞰榕城全景。',
        coverImage: '',
        rating: 4,
        estimatedMinutes: 180,
        totalDistance: 5000,
        completedCount: 0,
        isLocked: false,
        orderNum: 2,
        status: '0',
      },
    });
    console.log(`Created journey: ${gushanJourney.name}`);

    // 创建福州的文化之旅 - 闽江风光
    const minjiangJourney = await prisma.journey.create({
      data: {
        cityId: fuzhou.id,
        name: '闽江两岸',
        theme: '城市风光',
        description:
          '沿闽江漫步，欣赏中洲岛、解放大桥、烟台山等标志性景观，感受福州的现代与历史交融。',
        coverImage: '',
        rating: 3,
        estimatedMinutes: 120,
        totalDistance: 4000,
        completedCount: 0,
        isLocked: false,
        orderNum: 3,
        status: '0',
      },
    });
    console.log(`Created journey: ${minjiangJourney.name}`);

    // 创建西湖十景的探索点
    const westLakePoints = [
      {
        name: '苏堤春晓',
        latitude: 30.2456,
        longitude: 120.1423,
        taskType: 'photo',
        taskDescription: '在苏堤上拍摄一张春日美景照片',
        culturalBackground:
          '苏堤是北宋诗人苏轼任杭州知州时主持修建的堤坝，全长2.8公里。',
        culturalKnowledge:
          '苏堤春晓是西湖十景之首，每到春天，堤上桃红柳绿，景色宜人。',
        pointsReward: 100,
        orderNum: 1,
      },
      {
        name: '断桥残雪',
        latitude: 30.2589,
        longitude: 120.1512,
        taskType: 'gesture',
        taskDescription: '在断桥上做出"白娘子"的经典手势',
        targetGesture: 'heart',
        culturalBackground:
          '断桥是白娘子与许仙相遇的地方，承载着美丽的爱情传说。',
        culturalKnowledge:
          '断桥并非断裂之桥，而是因冬日雪后，桥面阳面雪融，阴面雪残，远望似断非断。',
        pointsReward: 120,
        orderNum: 2,
      },
      {
        name: '雷峰夕照',
        latitude: 30.2312,
        longitude: 120.1489,
        taskType: 'photo',
        taskDescription: '拍摄雷峰塔的夕阳剪影',
        culturalBackground: '雷峰塔始建于公元977年，因白娘子传说而闻名。',
        culturalKnowledge:
          '原塔于1924年倒塌，现塔为2002年重建，塔内保存有原塔遗址。',
        pointsReward: 100,
        orderNum: 3,
      },
      {
        name: '三潭印月',
        latitude: 30.2378,
        longitude: 120.1398,
        taskType: 'treasure',
        taskDescription: '找到三潭印月的AR宝藏',
        culturalBackground:
          '三潭印月是西湖中最大的岛屿，岛上有"我心相印亭"等景点。',
        culturalKnowledge:
          '三座石塔建于明代，每逢中秋，塔中点燃灯烛，与明月倒影相映成趣。',
        pointsReward: 150,
        orderNum: 4,
      },
    ];

    let prevDistance = 0;
    for (const point of westLakePoints) {
      await prisma.explorationPoint.create({
        data: {
          journeyId: westLakeJourney.id,
          name: point.name,
          latitude: point.latitude,
          longitude: point.longitude,
          taskType: point.taskType,
          taskDescription: point.taskDescription,
          targetGesture: point.targetGesture || null,
          culturalBackground: point.culturalBackground,
          culturalKnowledge: point.culturalKnowledge,
          distanceFromPrev: prevDistance,
          pointsReward: point.pointsReward,
          orderNum: point.orderNum,
          status: '0',
        },
      });
      prevDistance = 800 + Math.floor(Math.random() * 500);
    }
    console.log(
      `Created ${westLakePoints.length} exploration points for ${westLakeJourney.name}`,
    );

    // 创建灵隐禅踪的探索点
    const lingyinPoints = [
      {
        name: '飞来峰',
        latitude: 30.2398,
        longitude: 120.0912,
        taskType: 'photo',
        taskDescription: '拍摄飞来峰石刻造像',
        culturalBackground:
          '飞来峰有五代至宋元时期的石刻造像470余尊，是中国南方石窟艺术的瑰宝。',
        culturalKnowledge: '相传此峰是从印度灵鹫山飞来，故名飞来峰。',
        pointsReward: 100,
        orderNum: 1,
      },
      {
        name: '灵隐寺山门',
        latitude: 30.2412,
        longitude: 120.0934,
        taskType: 'gesture',
        taskDescription: '双手合十，做出礼佛手势',
        targetGesture: 'namaste',
        culturalBackground:
          '灵隐寺始建于东晋咸和元年（326年），是中国佛教禅宗十大古刹之一。',
        culturalKnowledge: '寺名取"仙灵所隐"之意，历史上曾多次毁建。',
        pointsReward: 120,
        orderNum: 2,
      },
      {
        name: '大雄宝殿',
        latitude: 30.2425,
        longitude: 120.0945,
        taskType: 'photo',
        taskDescription: '拍摄大雄宝殿全景',
        culturalBackground:
          '大雄宝殿内供奉释迦牟尼佛像，高24.8米，是中国最大的木雕坐式佛像之一。',
        culturalKnowledge: '殿内还有十八罗汉像，神态各异，栩栩如生。',
        pointsReward: 100,
        orderNum: 3,
      },
    ];

    prevDistance = 0;
    for (const point of lingyinPoints) {
      await prisma.explorationPoint.create({
        data: {
          journeyId: lingyinJourney.id,
          name: point.name,
          latitude: point.latitude,
          longitude: point.longitude,
          taskType: point.taskType,
          taskDescription: point.taskDescription,
          targetGesture: point.targetGesture || null,
          culturalBackground: point.culturalBackground,
          culturalKnowledge: point.culturalKnowledge,
          distanceFromPrev: prevDistance,
          pointsReward: point.pointsReward,
          orderNum: point.orderNum,
          status: '0',
        },
      });
      prevDistance = 300 + Math.floor(Math.random() * 200);
    }
    console.log(
      `Created ${lingyinPoints.length} exploration points for ${lingyinJourney.name}`,
    );

    // 创建三坊七巷的探索点
    const sanfangqixiangPoints = [
      {
        name: '南后街',
        latitude: 26.0856,
        longitude: 119.2936,
        taskType: 'photo',
        taskDescription: '拍摄南后街的古朴街景',
        culturalBackground:
          '南后街是三坊七巷的中轴线，全长约1000米，是福州传统商业街的代表。',
        culturalKnowledge:
          '南后街自古以来就是福州的商业中心，有"正阳门外琉璃厂，衣锦坊前南后街"之称。',
        pointsReward: 100,
        orderNum: 1,
      },
      {
        name: '林则徐纪念馆',
        latitude: 26.0842,
        longitude: 119.2928,
        taskType: 'gesture',
        taskDescription: '在林则徐塑像前做出敬礼手势',
        targetGesture: 'salute',
        culturalBackground:
          '林则徐是中国近代史上著名的民族英雄，虎门销烟的主持者。',
        culturalKnowledge:
          '林则徐故居位于文藻山，纪念馆内陈列着他的生平事迹和珍贵文物。',
        pointsReward: 120,
        orderNum: 2,
      },
      {
        name: '严复故居',
        latitude: 26.0867,
        longitude: 119.2941,
        taskType: 'photo',
        taskDescription: '拍摄严复故居的门楼',
        culturalBackground:
          '严复是中国近代著名的启蒙思想家、翻译家，《天演论》的译者。',
        culturalKnowledge: '严复故居位于郎官巷，是典型的福州传统民居建筑。',
        pointsReward: 100,
        orderNum: 3,
      },
      {
        name: '冰心故居',
        latitude: 26.0851,
        longitude: 119.2945,
        taskType: 'photo',
        taskDescription: '在冰心故居前留影',
        culturalBackground:
          '冰心是中国现代著名女作家，原名谢婉莹，代表作有《繁星》《春水》等。',
        culturalKnowledge: '冰心故居位于杨桥巷，她在这里度过了童年时光。',
        pointsReward: 100,
        orderNum: 4,
      },
      {
        name: '水榭戏台',
        latitude: 26.0863,
        longitude: 119.2932,
        taskType: 'treasure',
        taskDescription: '在水榭戏台找到AR宝藏',
        culturalBackground:
          '水榭戏台是三坊七巷内保存最完好的古戏台，建于清代。',
        culturalKnowledge:
          '戏台临水而建，观众可在对岸观看演出，是福州独特的戏曲文化载体。',
        pointsReward: 150,
        orderNum: 5,
      },
    ];

    prevDistance = 0;
    for (const point of sanfangqixiangPoints) {
      await prisma.explorationPoint.create({
        data: {
          journeyId: sanfangqixiangJourney.id,
          name: point.name,
          latitude: point.latitude,
          longitude: point.longitude,
          taskType: point.taskType,
          taskDescription: point.taskDescription,
          targetGesture: point.targetGesture || null,
          culturalBackground: point.culturalBackground,
          culturalKnowledge: point.culturalKnowledge,
          distanceFromPrev: prevDistance,
          pointsReward: point.pointsReward,
          orderNum: point.orderNum,
          status: '0',
        },
      });
      prevDistance = 200 + Math.floor(Math.random() * 150);
    }
    console.log(
      `Created ${sanfangqixiangPoints.length} exploration points for ${sanfangqixiangJourney.name}`,
    );

    // 创建鼓山的探索点
    const gushanPoints = [
      {
        name: '鼓山登山古道',
        latitude: 26.0712,
        longitude: 119.3856,
        taskType: 'photo',
        taskDescription: '拍摄古道石阶',
        culturalBackground:
          '鼓山登山古道始建于宋代，全长约3.5公里，共有2145级石阶。',
        culturalKnowledge: '古道沿途有众多摩崖石刻，是福州重要的文化遗产。',
        pointsReward: 100,
        orderNum: 1,
      },
      {
        name: '涌泉寺',
        latitude: 26.0689,
        longitude: 119.3912,
        taskType: 'gesture',
        taskDescription: '双手合十，做出礼佛手势',
        targetGesture: 'namaste',
        culturalBackground:
          '涌泉寺始建于唐建中四年（783年），是福建省著名的佛教古刹。',
        culturalKnowledge: '寺内有千年铁树、血经等珍贵文物，被誉为"闽刹之冠"。',
        pointsReward: 120,
        orderNum: 2,
      },
      {
        name: '喝水岩',
        latitude: 26.0695,
        longitude: 119.3923,
        taskType: 'photo',
        taskDescription: '拍摄喝水岩摩崖石刻',
        culturalBackground:
          '喝水岩是鼓山最著名的摩崖石刻群，有宋代以来的题刻200多处。',
        culturalKnowledge:
          '相传神僧喝退泉水，故名喝水岩。这里的石刻书法艺术价值极高。',
        pointsReward: 100,
        orderNum: 3,
      },
      {
        name: '鼓山之巅',
        latitude: 26.0678,
        longitude: 119.3945,
        taskType: 'photo',
        taskDescription: '在山顶拍摄福州全景',
        culturalBackground:
          '鼓山海拔969米，是福州市区最高峰，登顶可俯瞰整个榕城。',
        culturalKnowledge:
          '鼓山因山顶有一巨石如鼓，每当风雨大作，便有隆隆鼓声，故名鼓山。',
        pointsReward: 150,
        orderNum: 4,
      },
    ];

    prevDistance = 0;
    for (const point of gushanPoints) {
      await prisma.explorationPoint.create({
        data: {
          journeyId: gushanJourney.id,
          name: point.name,
          latitude: point.latitude,
          longitude: point.longitude,
          taskType: point.taskType,
          taskDescription: point.taskDescription,
          targetGesture: point.targetGesture || null,
          culturalBackground: point.culturalBackground,
          culturalKnowledge: point.culturalKnowledge,
          distanceFromPrev: prevDistance,
          pointsReward: point.pointsReward,
          orderNum: point.orderNum,
          status: '0',
        },
      });
      prevDistance = 500 + Math.floor(Math.random() * 300);
    }
    console.log(
      `Created ${gushanPoints.length} exploration points for ${gushanJourney.name}`,
    );

    // 创建闽江两岸的探索点
    const minjiangPoints = [
      {
        name: '中洲岛',
        latitude: 26.0523,
        longitude: 119.3012,
        taskType: 'photo',
        taskDescription: '拍摄中洲岛欧式建筑',
        culturalBackground:
          '中洲岛位于闽江中央，岛上建有欧式风格建筑群，是福州的地标之一。',
        culturalKnowledge:
          '中洲岛原为闽江中的沙洲，后经人工改造成为休闲观光岛。',
        pointsReward: 100,
        orderNum: 1,
      },
      {
        name: '烟台山',
        latitude: 26.0478,
        longitude: 119.3089,
        taskType: 'photo',
        taskDescription: '拍摄烟台山历史建筑',
        culturalBackground:
          '烟台山是福州近代史的见证，曾是各国领事馆和洋行的聚集地。',
        culturalKnowledge:
          '山上保存有大量近代西式建筑，是福州开埠历史的重要遗存。',
        pointsReward: 100,
        orderNum: 2,
      },
      {
        name: '解放大桥',
        latitude: 26.0534,
        longitude: 119.3045,
        taskType: 'gesture',
        taskDescription: '在桥上做出胜利手势',
        targetGesture: 'victory',
        culturalBackground:
          '解放大桥原名万寿桥，始建于元代，是福州最古老的跨江大桥。',
        culturalKnowledge: '现桥为1996年重建，保留了原桥的部分石构件。',
        pointsReward: 120,
        orderNum: 3,
      },
      {
        name: '闽江公园',
        latitude: 26.0512,
        longitude: 119.3123,
        taskType: 'treasure',
        taskDescription: '在闽江公园找到AR宝藏',
        culturalBackground: '闽江公园沿江而建，是福州市民休闲的好去处。',
        culturalKnowledge: '公园内有多处观景平台，可欣赏闽江两岸的城市风光。',
        pointsReward: 150,
        orderNum: 4,
      },
    ];

    prevDistance = 0;
    for (const point of minjiangPoints) {
      await prisma.explorationPoint.create({
        data: {
          journeyId: minjiangJourney.id,
          name: point.name,
          latitude: point.latitude,
          longitude: point.longitude,
          taskType: point.taskType,
          taskDescription: point.taskDescription,
          targetGesture: point.targetGesture || null,
          culturalBackground: point.culturalBackground,
          culturalKnowledge: point.culturalKnowledge,
          distanceFromPrev: prevDistance,
          pointsReward: point.pointsReward,
          orderNum: point.orderNum,
          status: '0',
        },
      });
      prevDistance = 400 + Math.floor(Math.random() * 200);
    }
    console.log(
      `Created ${minjiangPoints.length} exploration points for ${minjiangJourney.name}`,
    );

    // 创建印记
    const seals = [
      {
        type: 'route',
        name: '西湖探秘者',
        description: '完成西湖十景探秘路线，获得此印记',
        badgeTitle: '西湖探秘者',
        journeyId: westLakeJourney.id,
        cityId: null,
        orderNum: 1,
      },
      {
        type: 'route',
        name: '禅心悟道',
        description: '完成灵隐禅踪路线，获得此印记',
        badgeTitle: '禅心悟道',
        journeyId: lingyinJourney.id,
        cityId: null,
        orderNum: 2,
      },
      {
        type: 'route',
        name: '园林雅士',
        description: '完成园林雅韵路线，获得此印记',
        badgeTitle: '园林雅士',
        journeyId: gardenJourney.id,
        cityId: null,
        orderNum: 3,
      },
      {
        type: 'route',
        name: '坊巷寻踪',
        description: '完成三坊七巷寻古路线，获得此印记',
        badgeTitle: '坊巷寻踪者',
        journeyId: sanfangqixiangJourney.id,
        cityId: null,
        orderNum: 4,
      },
      {
        type: 'route',
        name: '鼓山禅心',
        description: '完成鼓山禅意行路线，获得此印记',
        badgeTitle: '鼓山禅心',
        journeyId: gushanJourney.id,
        cityId: null,
        orderNum: 5,
      },
      {
        type: 'route',
        name: '闽江行者',
        description: '完成闽江两岸路线，获得此印记',
        badgeTitle: '闽江行者',
        journeyId: minjiangJourney.id,
        cityId: null,
        orderNum: 6,
      },
      {
        type: 'city',
        name: '杭州印记',
        description: '完成杭州所有文化之旅，获得城市印记',
        badgeTitle: '杭州文化使者',
        journeyId: null,
        cityId: hangzhou.id,
        orderNum: 10,
      },
      {
        type: 'city',
        name: '苏州印记',
        description: '完成苏州所有文化之旅，获得城市印记',
        badgeTitle: '苏州文化使者',
        journeyId: null,
        cityId: suzhou.id,
        orderNum: 11,
      },
      {
        type: 'city',
        name: '南京印记',
        description: '完成南京所有文化之旅，获得城市印记',
        badgeTitle: '南京文化使者',
        journeyId: null,
        cityId: nanjing.id,
        orderNum: 12,
      },
      {
        type: 'city',
        name: '福州印记',
        description: '完成福州所有文化之旅，获得城市印记',
        badgeTitle: '榕城文化使者',
        journeyId: null,
        cityId: fuzhou.id,
        orderNum: 13,
      },
      {
        type: 'special',
        name: '江南水乡',
        description: '完成杭州和苏州的所有路线，获得特殊印记',
        badgeTitle: '江南水乡行者',
        journeyId: null,
        cityId: null,
        orderNum: 20,
      },
      {
        type: 'special',
        name: '闽都风华',
        description: '完成福州所有文化之旅，获得特殊印记',
        badgeTitle: '闽都风华探索者',
        journeyId: null,
        cityId: null,
        orderNum: 21,
      },
    ];

    for (const seal of seals) {
      await prisma.seal.create({
        data: {
          type: seal.type,
          name: seal.name,
          imageAsset: '',
          description: seal.description,
          badgeTitle: seal.badgeTitle,
          journeyId: seal.journeyId,
          cityId: seal.cityId,
          orderNum: seal.orderNum,
          status: '0',
        },
      });
    }
    console.log(`Created ${seals.length} seals`);

    // 创建示例 App 用户
    const demoUser = await prisma.appUser.create({
      data: {
        phone: '13800138000',
        nickname: '探索者小明',
        avatar: '',
        loginType: 'wechat',
        totalPoints: 520,
        status: '0',
      },
    });
    console.log(`Created demo app user: ${demoUser.nickname}`);

    // 创建第二个示例用户
    const demoUser2 = await prisma.appUser.create({
      data: {
        phone: '13900139000',
        nickname: '文化行者',
        avatar: '',
        loginType: 'email',
        totalPoints: 320,
        status: '0',
      },
    });
    console.log(`Created demo app user: ${demoUser2.nickname}`);

    // 创建第三个示例用户
    const demoUser3 = await prisma.appUser.create({
      data: {
        phone: '13700137000',
        nickname: '印记收藏家',
        avatar: '',
        loginType: 'wechat',
        totalPoints: 850,
        status: '0',
      },
    });
    console.log(`Created demo app user: ${demoUser3.nickname}`);

    // 获取已创建的印记
    const allSeals = await prisma.seal.findMany();
    const westLakeSeal = allSeals.find((s) => s.name === '西湖探秘者');
    const lingyinSeal = allSeals.find((s) => s.name === '禅心悟道');
    const hangzhouCitySeal = allSeals.find((s) => s.name === '杭州印记');

    // 创建用户进度数据
    // 用户1: 西湖十景探秘 - 已完成
    await prisma.journeyProgress.create({
      data: {
        userId: demoUser.id,
        journeyId: westLakeJourney.id,
        status: 'completed',
        startTime: new Date('2025-01-10T09:00:00Z'),
        completeTime: new Date('2025-01-10T15:30:00Z'),
        timeSpentMinutes: 390,
      },
    });

    // 用户1: 灵隐禅踪 - 进行中
    await prisma.journeyProgress.create({
      data: {
        userId: demoUser.id,
        journeyId: lingyinJourney.id,
        status: 'in_progress',
        startTime: new Date('2025-01-15T10:00:00Z'),
      },
    });

    // 用户2: 三坊七巷寻古 - 进行中
    await prisma.journeyProgress.create({
      data: {
        userId: demoUser2.id,
        journeyId: sanfangqixiangJourney.id,
        status: 'in_progress',
        startTime: new Date('2025-01-12T14:00:00Z'),
      },
    });

    // 用户3: 西湖十景探秘 - 已完成
    await prisma.journeyProgress.create({
      data: {
        userId: demoUser3.id,
        journeyId: westLakeJourney.id,
        status: 'completed',
        startTime: new Date('2025-01-05T08:00:00Z'),
        completeTime: new Date('2025-01-05T14:00:00Z'),
        timeSpentMinutes: 360,
      },
    });

    // 用户3: 灵隐禅踪 - 已完成
    await prisma.journeyProgress.create({
      data: {
        userId: demoUser3.id,
        journeyId: lingyinJourney.id,
        status: 'completed',
        startTime: new Date('2025-01-06T09:00:00Z'),
        completeTime: new Date('2025-01-06T12:00:00Z'),
        timeSpentMinutes: 180,
      },
    });

    // 用户3: 三坊七巷寻古 - 进行中
    await prisma.journeyProgress.create({
      data: {
        userId: demoUser3.id,
        journeyId: sanfangqixiangJourney.id,
        status: 'in_progress',
        startTime: new Date('2025-01-20T10:00:00Z'),
      },
    });

    console.log('Created journey progress data');

    // 创建用户印记数据
    // 用户1: 西湖探秘者印记 - 已上链
    if (westLakeSeal) {
      await prisma.userSeal.create({
        data: {
          userId: demoUser.id,
          sealId: westLakeSeal.id,
          earnedTime: new Date('2025-01-10T15:30:00Z'),
          isChained: true,
          chainName: 'antchain',
          txHash: '0x' + 'a'.repeat(64),
          blockHeight: BigInt(10234567),
          chainTime: new Date('2025-01-10T16:00:00Z'),
        },
      });
    }

    // 用户3: 西湖探秘者印记 - 已上链
    if (westLakeSeal) {
      await prisma.userSeal.create({
        data: {
          userId: demoUser3.id,
          sealId: westLakeSeal.id,
          earnedTime: new Date('2025-01-05T14:00:00Z'),
          isChained: true,
          chainName: 'antchain',
          txHash: '0x' + 'b'.repeat(64),
          blockHeight: BigInt(10234123),
          chainTime: new Date('2025-01-05T14:30:00Z'),
        },
      });
    }

    // 用户3: 禅心悟道印记 - 未上链
    if (lingyinSeal) {
      await prisma.userSeal.create({
        data: {
          userId: demoUser3.id,
          sealId: lingyinSeal.id,
          earnedTime: new Date('2025-01-06T12:00:00Z'),
          isChained: false,
        },
      });
    }

    // 用户3: 杭州城市印记 - 已上链
    if (hangzhouCitySeal) {
      await prisma.userSeal.create({
        data: {
          userId: demoUser3.id,
          sealId: hangzhouCitySeal.id,
          earnedTime: new Date('2025-01-06T12:30:00Z'),
          isChained: true,
          chainName: 'chainmaker',
          txHash: '0x' + 'c'.repeat(64),
          blockHeight: BigInt(10235000),
          chainTime: new Date('2025-01-06T13:00:00Z'),
        },
      });
    }

    console.log('Created user seal data');

    console.log('Xunyin business data seeding completed.');
  }

  console.log('Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
