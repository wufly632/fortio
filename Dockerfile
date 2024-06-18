# Build the binaries in larger image
FROM dockerhub.wufly.top/library/golang:1.21-alpine AS build
# 设置环境变量
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOPROXY=https://goproxy.cn,direct

# 将工作目录设置为 /app
WORKDIR /app

# 将 go.mod 和 go.sum 复制到工作目录
COPY go.mod go.sum ./

# 下载所有依赖。它们会保存在缓存中，以加快后续的构建速度
RUN go mod download

# 复制项目的所有源码到工作目录
COPY . .

# 构建 Go 应用程序
RUN go build -o main .

# 第二阶段：运行阶段
FROM alpine:latest

# 创建一个非root用户以运行应用程序
RUN adduser -D nonroot

# 将工作目录设置为 /root/
WORKDIR /root/

# 从构建阶段复制构建的二进制文件到运行阶段
COPY --from=build /app/main .

# 切换到非root用户
USER nonroot

# 定义外部可以访问的端口
EXPOSE 8080
EXPOSE 8081

# 启动 Go 应用程序
CMD ["./main server"]