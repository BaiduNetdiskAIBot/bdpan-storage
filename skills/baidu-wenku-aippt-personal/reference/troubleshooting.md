# 故障排除指南

本指南涵盖了使用百度文库 AI PPT 生成功能时的常见问题和解决方案。

---

## 认证问题

### Token 过期

**症状：**
```
错误: Token 过期
Error: Token expired
```

**解决方案：**
```bash
bdpan logout
bash ${CLAUDE_SKILL_DIR}/scripts/login.sh
```

> 登录安全约束详见 [SKILL.md](../SKILL.md) 的「安全约束」章节。

### WebView 无法打开

**症状：** 登录过程中浏览器或 WebView 窗口未出现。

**解决方案：**
工具会自动降级到 OOB（Out-of-Band）模式，按以下步骤操作：

1. 复制控制台显示的授权链接：
   ```
   https://openapi.baidu.com/oauth/...?device_code=xxxxx
   ```

2. 在浏览器中打开该链接

3. 完成授权后，浏览器会显示授权码

4. 复制授权码并粘贴到命令行提示处

5. 按回车确认

### 授权后登录失败

**症状：** 授权页面完成但登录仍然失败。

**解决方案：**
```bash
# 清除配置并重试
rm ~/.config/bdpan/config.json
bash ${CLAUDE_SKILL_DIR}/scripts/login.sh
```

---

## AI PPT 生成问题

### PPT 生成超时

**症状：** 执行 `bdpan aippt` 后长时间无响应或超时。

**解决方案：**
1. 检查网络连接是否正常
2. 重试生成命令（服务端可能暂时繁忙）
3. 如果持续超时，稍后再试

### 生成结果为空或报错

**症状：** 命令执行后没有返回 PPT 文件路径或显示错误信息。

**解决方案：**
1. 确认已登录：`bdpan whoami`
2. 检查输入描述是否足够详细（建议超过 10 个字）
3. 避免输入包含特殊字符（引号需要正确转义）
4. 如果 Token 过期，重新登录后再试

### 参数值无效

**症状：** 提示参数值不在允许范围内。

**解决方案：**
确认参数取值在以下枚举范围内：
- **page**: 1-10、11-20、21-30、31-40、40+
- **style**: 默认、创意趣味、年终总结、卡通手绘、扁平简约、文艺清新、中国风、企业商务、未来科技、文化艺术
- **scene**: 默认、晚会表彰、传统节日、婚姻爱情、生日祝福、医学科普、建筑报告、工作总结、年终总结、工作汇报
- **color**: 默认、绿色、蓝色、紫色、橙色、黄色、红色、黑色、白色

---

## 安装问题

### 命令未找到

**症状：** `bdpan: command not found`

**解决方案：**
```bash
# 重新运行安装脚本
bash ${CLAUDE_SKILL_DIR}/scripts/install.sh

# 或者检查 ~/.local/bin 是否在 PATH 中
echo $PATH

# 如果缺失则添加到 PATH（添加到 ~/.zshrc 或 ~/.bashrc）
export PATH="$HOME/.local/bin:$PATH"
```

### 下载了错误的架构

**症状：** 二进制文件无法运行或提示 "exec format error"

**解决方案：**
```bash
# 删除现有二进制文件
rm ~/.local/bin/bdpan

# 重新安装
bash ${CLAUDE_SKILL_DIR}/scripts/install.sh
```

---

## 平台特定问题

### macOS

#### Gatekeeper 阻止

**症状：** 无法打开应用，因为它来自身份不明的开发者。

**解决方案：**
```bash
xattr -d com.apple.quarantine ~/.local/bin/bdpan
```

### Linux

#### 缺少依赖

**症状：** 二进制文件运行失败，提示缺少库。

**解决方案：**
安装所需依赖（特定于发行版）：
```bash
# Debian/Ubuntu
sudo apt-get install libc6

# Fedora/RHEL
sudo dnf install glibc
```

### Windows (WSL)

#### 路径问题

**症状：** Windows 路径无法正常工作。

**解决方案：**
在 WSL 中始终使用 Unix 风格路径：
```bash
# 正确
bdpan aippt "主题描述" "标题" "11-20" "默认" "默认" "默认"

# 错误（Windows 路径风格）
# 不适用于 bdpan aippt
```

---

## 获取帮助

### 检查版本

```bash
bdpan version
```

### 获取命令帮助

```bash
bdpan --help
bdpan aippt --help
```

### 启用调试模式

```bash
# 检查配置文件是否存在及权限
ls -la ~/.config/bdpan/

# 检查登录状态和 Token 有效期
bdpan whoami
```

> **⛔ 安全警告：** 切勿使用 `cat` 查看配置文件内容，配置文件中包含 access_token 等敏感凭据，打印到终端或对话中可能导致泄露。
