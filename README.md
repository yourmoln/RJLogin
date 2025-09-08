# RJLogin OpenWrt 插件

一个用于OpenWrt的自动登录插件，可以定时执行网络认证登录。

## 功能特点

- 支持Web界面配置（LuCI）
- 定时自动执行登录（基于cron）
- 完整的日志记录
- 支持启用/禁用控制
- 可配置执行时间

## 文件结构

```
openwrt/
├── Makefile                                    # 编译配置文件
└── files/
    ├── etc/
    │   ├── config/rjlogin                     # 配置文件
    │   └── init.d/rjlogin.sh                  # 启动脚本
    └── usr/
        ├── lib/lua/luci/
        │   ├── controller/rjlogin.lua         # LuCI控制器
        │   └── model/cbi/rjlogin.lua          # LuCI表单页面
        └── sbin/
            ├── rjlogin                        # 主执行脚本
            └── rjlogin-test                   # 测试脚本
```

## 配置说明

### Web界面配置
1. 登录OpenWrt管理界面
2. 进入 "服务" -> "RJLogin Client"
3. 配置以下参数：
   - **启用**: 是否启用自动登录
   - **用户名**: 登录用户名
   - **密码**: 登录密码
   - **执行时间**: 每天执行的时间（格式：HH:MM）
   - **登录URL**: 登录接口地址
   - **Referer**: HTTP Referer头

### 配置文件
配置文件位置：`/etc/config/rjlogin`

```
config server
    option enable '1'
    option username 'your_username'
    option password 'your_password'
    option time '06:00'
    option url 'http://10.10.12.13/eportal/InterFace.do?method=login'
    option referer 'http://10.10.12.13/eportal/index.jsp'
```

## 安装使用

1. 将整个 `openwrt` 目录复制到 OpenWrt 编译环境的 `package` 目录下
2. 运行编译命令：
   ```bash
   make package/rjlogin/compile V=s
   ```
3. 安装生成的 ipk 包到路由器
4. 在Web界面进行配置

## 手动控制

### 启动/停止服务
```bash
/etc/init.d/rjlogin start    # 启动服务
/etc/init.d/rjlogin stop     # 停止服务
/etc/init.d/rjlogin restart  # 重启服务
```

### 手动执行登录
```bash
/usr/sbin/rjlogin
```

### 测试功能
```bash
/usr/sbin/rjlogin-test
```

### 查看日志
```bash
tail -f /var/log/rjlogin.log
```

### 查看定时任务
```bash
cat /etc/crontabs/root | grep rjlogin
```

## 原理说明

1. **定时执行**: 使用cron定时任务在指定时间执行登录
2. **配置管理**: 使用UCI系统管理配置
3. **Web界面**: 通过LuCI提供Web配置界面
4. **服务管理**: 通过procd管理服务生命周期

## 故障排除

### 检查服务状态
```bash
/etc/init.d/rjlogin status
```

### 检查配置
```bash
uci show rjlogin
```

### 查看系统日志
```bash
logread | grep rjlogin
```

### 手动测试curl命令
```bash
# 检查网络连通性
ping 10.10.12.13

# 手动执行curl测试
/usr/sbin/rjlogin-test
```

## 依赖项

- curl: 用于发送HTTP请求
- cron: 用于定时执行
- luci: Web管理界面

## 注意事项

1. 确保路由器可以访问目标登录服务器
2. 登录URL和参数可能需要根据实际环境调整
3. 密码会明文存储在配置文件中，注意安全
4. 建议定期检查日志确认登录状态

## 自定义修改

如果需要适配其他登录接口，主要修改以下文件：
- `/usr/sbin/rjlogin`: 修改curl命令和参数
- `/usr/lib/lua/luci/model/cbi/rjlogin.lua`: 添加新的配置项

## 版本信息

- 版本: 1.0.0
- 维护者: yourmoln
- 许可证: GPL