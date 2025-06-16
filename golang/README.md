只需将本目录下的 .golangci.yml 和 .editorconfig 复制到项目根目录。

.golangci.yml：Go 代码检查配置。
.editorconfig：Go 统一代码格式。

### 安装 golangci-lint
```shell
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.8
```

### 执行代码检查
```shell
golangci-lint run --config .golangci.yml
```
