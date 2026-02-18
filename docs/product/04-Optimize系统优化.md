# Optimize - 系统优化功能

## 功能概述

执行系统维护任务，重建数据库和缓存，刷新系统服务，进行安全加固，提升系统性能和稳定性。

## 核心价值

- **性能提升**：重建索引和缓存，加快系统响应
- **稳定性增强**：修复配置问题，清理损坏的数据
- **安全加固**：启用防火墙和Gatekeeper
- **问题诊断**：检查系统健康状况

## 优化类别

### 1. 系统检查（System Checks）

#### 更新检查
- 检查macOS系统更新
- 检查App Store应用更新
- 提示用户安装更新

#### 健康检查
- 磁盘空间检查
- 内存使用检查
- CPU负载检查
- 温度检查
- 电池健康检查

#### 安全检查
- 防火墙状态
- Gatekeeper状态
- FileVault状态
- Touch ID配置
- 系统完整性保护（SIP）

#### 配置检查
- 启动项检查
- Launch Agent/Daemon检查
- 系统偏好设置检查

### 2. 安全修复（Security Fixes）

#### 启用防火墙
**操作**：
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

**效果**：
- 阻止未授权的入站连接
- 保护网络安全

#### 启用Gatekeeper
**操作**：
```bash
sudo spctl --master-enable
```

**效果**：
- 只允许运行已签名的应用
- 防止恶意软件

#### 配置Touch ID for sudo
**操作**：
- 修改 `/etc/pam.d/sudo`
- 添加 `auth sufficient pam_tid.so`

**效果**：
- 使用Touch ID代替密码
- 提升安全性和便利性

### 3. 性能优化（Performance Optimization）

#### 重建启动服务数据库
**操作**：
```bash
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
```

**效果**：
- 修复"打开方式"菜单
- 加快应用启动
- 修复文件关联

#### 重建Spotlight索引
**操作**：
```bash
sudo mdutil -E /
```

**效果**：
- 修复搜索问题
- 加快文件查找
- 清理损坏的索引

#### 清理字体缓存
**操作**：
```bash
sudo atsutil databases -remove
```

**效果**：
- 修复字体显示问题
- 加快字体加载

#### 重建dyld缓存
**操作**：
```bash
sudo update_dyld_shared_cache -force
```

**效果**：
- 加快应用启动
- 修复动态库问题

**注意**：
- 需要3-5分钟
- 180秒超时保护

#### 清理DNS缓存
**操作**：
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

**效果**：
- 修复网络连接问题
- 清理过期DNS记录

#### 重置网络服务
**操作**：
```bash
sudo ifconfig en0 down
sudo ifconfig en0 up
```

**效果**：
- 修复网络问题
- 重置网络配置

#### 刷新Finder
**操作**：
```bash
killall Finder
```

**效果**：
- 修复Finder显示问题
- 刷新文件列表

#### 刷新Dock
**操作**：
```bash
killall Dock
```

**效果**：
- 修复Dock显示问题
- 刷新应用列表

#### 清理诊断日志
**操作**：
- 删除 `/Library/Logs/DiagnosticReports`
- 删除 `~/Library/Logs/DiagnosticReports`

**效果**：
- 回收磁盘空间
- 清理旧的崩溃报告

#### 清理系统日志
**操作**：
```bash
sudo rm -rf /var/log/*.log
sudo rm -rf /var/log/*.out
```

**效果**：
- 回收磁盘空间
- 清理旧的系统日志

#### 清理交换文件
**操作**：
```bash
sudo rm -rf /private/var/vm/swapfile*
sudo dynamic_pager -F /private/var/vm/swapfile
```

**效果**：
- 回收磁盘空间
- 重置虚拟内存

### 4. 数据库优化（Database Optimization）

#### 优化Mail数据库
**操作**：
```bash
sqlite3 ~/Library/Mail/V*/MailData/Envelope\ Index VACUUM
```

**效果**：
- 加快Mail启动
- 减少数据库大小
- 修复邮件搜索

#### 优化Safari数据库
**操作**：
```bash
sqlite3 ~/Library/Safari/History.db VACUUM
```

**效果**：
- 加快Safari启动
- 减少数据库大小

#### 优化Photos数据库
**操作**：
```bash
sqlite3 ~/Pictures/Photos\ Library.photoslibrary/database/photos.db VACUUM
```

**效果**：
- 加快Photos启动
- 减少数据库大小

**注意**：
- 需要关闭Photos应用
- 20秒超时保护

## 使用方式

### 基础用法
```bash
mo optimize                 # 交互式优化
mo optimize --dry-run       # 预览优化计划
mo optimize --debug         # 详细日志模式
```

### 白名单管理
```bash
mo optimize --whitelist     # 管理白名单
```

### 白名单格式
位置：`~/.config/mole/whitelist_optimize`

格式：
```
# 一行一个优化项ID
firewall
gatekeeper
spotlight
dyld_cache
```

## 优化流程

1. **检查阶段**
   - 运行所有系统检查
   - 收集系统信息
   - 识别问题

2. **建议阶段**
   - 生成优化建议
   - 显示每个建议的效果
   - 应用白名单过滤

3. **确认阶段**
   - 显示优化计划
   - 用户确认

4. **执行阶段**
   - 按顺序执行优化
   - 显示实时进度
   - 记录操作日志

5. **完成阶段**
   - 显示优化结果
   - 显示系统状态

## 安全机制

### 权限管理
- 用户级操作：无需sudo
- 系统级操作：请求sudo
- 会话保活：防止重复输入密码

### 超时保护
- dyld缓存重建：180秒
- 数据库优化：20秒
- 网络操作：5秒

### 错误处理
- 捕获所有错误
- 记录错误日志
- 继续执行其他优化

### 回滚机制
- 备份关键配置
- 支持恢复原始状态

## 优化结果

### 典型结果
```
System: 5/32 GB RAM | 333/460 GB Disk (72%) | Uptime 6d

  ✓ Rebuild system databases and clear caches
  ✓ Reset network services
  ✓ Refresh Finder and Dock
  ✓ Clean diagnostic and crash logs
  ✓ Remove swap files and restart dynamic pager
  ✓ Rebuild launch services and spotlight index

====================================================================
System optimization completed
====================================================================
```

### 日志记录
位置：`~/.config/mole/operations.log`

格式：
```
[timestamp] [optimize] [action] [details]
```

## 性能影响

### 立即生效
- DNS缓存清理
- Finder/Dock刷新
- 网络服务重置

### 需要重启应用
- 启动服务数据库
- 字体缓存

### 需要重启系统
- dyld缓存重建（可选）
- 内核扩展更新

## 常见问题

### Q: 优化会影响我的数据吗？
A: 不会。只优化系统缓存和数据库，不影响用户数据。

### Q: 优化需要多长时间？
A: 通常1-3分钟，dyld缓存重建可能需要3-5分钟。

### Q: 多久优化一次？
A: 建议每月一次，或遇到性能问题时。

### Q: 优化后需要重启吗？
A: 大部分优化不需要重启，但重启可以让所有优化生效。

## Mac应用开发建议

### UI设计

1. **检查界面**
   - 显示系统健康分数
   - 显示各项检查结果
   - 使用颜色标识问题严重程度

2. **优化建议界面**
   - 显示所有优化建议
   - 显示每个建议的效果
   - 支持勾选/取消勾选

3. **执行界面**
   - 显示优化进度
   - 显示当前操作
   - 显示预计剩余时间

4. **结果界面**
   - 显示优化结果
   - 显示前后对比
   - 支持查看日志

### 功能增强

1. **定时优化**：支持定期自动优化
2. **智能建议**：根据系统状态推荐优化
3. **性能监控**：持续监控系统性能
4. **优化历史**：记录每次优化的结果
5. **一键优化**：一键执行所有推荐优化

### 技术实现

1. **系统检查**：使用系统API获取状态
2. **权限管理**：使用SMJobBless请求权限
3. **后台执行**：使用后台线程执行优化
4. **进度更新**：实时更新优化进度
5. **通知中心**：优化完成后发送通知

### 用户体验优化

1. **快速检查**：使用缓存加速检查
2. **实时反馈**：显示每个操作的效果
3. **安全提示**：提示需要sudo的操作
4. **撤销功能**：支持撤销某些优化
5. **帮助文档**：提供每个优化的详细说明
