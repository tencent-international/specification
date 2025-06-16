# 🔍 Golang 代码规范工具配置

### 复制以下文件至项目根目录
- `.editorconfig` - Go 统一代码格式
- `.golangci.yml` - Go 代码检查配置

### 安装 golangci-lint
```shell
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.8
```

### 执行代码检查
```shell
golangci-lint run --config .golangci.yml
```
