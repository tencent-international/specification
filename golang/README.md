# Golang 開發規範

## 📁 命名規範

### 包名規範
- 統一使用小寫字母
- 儘量避免多個詞組，如必須使用多個詞組則不加連接符
- **範例**: `user`, `authservice`, `eventbus`

### 文件名規範
- 統一使用小寫字母
- 多個詞組間用 `_` 連接
- 按功能能力劃分文件，一個文件專注於一組密切相關的結構體、接口、函數（高內聚）
- **範例**: `user_service.go`, `auth_provider.go`, `event_handler.go`

## 🏗️ 實例化規範

### 新建實例
- 使用 `New` 開頭，格式為 `NewXxx()`
- 既是 Builder 又實現了相關功能的可省略 Builder 結尾

### 定義規範
- 用 `Spec` 結尾，格式為 `NewXxxSpec()`
- 必須是沒有任何能力，不產生任何副作用的情況
- **範例**: `ConfigSpec`, `NewConfigSpec()`

### 功能實例
- 帶功能的實例推薦 `er` 結尾
- 如果是透過 `Spec` 產生功能實例，用 `Use` 作動詞
- **範例**: `MethodCaller`, `ConfigProvider`, `NewConfigSpec().Use().Get()`

## 📡 事件與消息規範

### 事件變數
- 使用過去式動作 + Event
- **範例**: `UserLoggedInEvent`, `OrderCreatedEvent`
```go
var UserLoggedInEvent = event.New[UserLoggedIn]()
```

### 消息體
- 無後綴或使用 `Message` 後綴
- **範例**: `UserData`, `OrderMessage`

## 🌐 API 定義規範

### RESTful API
- 變數以 `Endpoint` 結尾
- 入參用 `Request` 後綴
- 出參用 `Response` 後綴
- 如果出入參本身描述的是「業務數據實體」而非"命令/請求/回應包裹"，則可以不加後綴

**範例**:
```go
var RefreshTokenEndpoint = api.NewEndpoint[RefreshTokenRequest, TokenPair]()
var GetUserEndpoint = api.NewEndpoint[GetUserRequest, UserData]()
```

### RPC 定義
- 變數以 `MethodSpec` 結尾
- 入參用 `Cmd` 後綴
- 出參用 `Result` 後綴
- 免後綴規則同上

**範例**:
```go
var GenerateTokenPairMethodSpec = rpc.NewMethodSpec[GenerateTokenCmd, TokenPair]("generate-token")
var GetUserMethodSpec = rpc.NewMethodSpec[GetUserCmd, UserData]("get-user")
```


## 工具

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
