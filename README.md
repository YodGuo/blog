## 支持以环境变量的方式初始化配置文件的 docker 版本

------------------------------

[dockerhub 地址](https://hub.docker.com/r/miacis/halo)

[配置参考](https://docs.halo.run/getting-started/config/#mysql-1)

## 快速开始

### 镜像构建

```bash
docker build -t halo .

# 指定版本
docker build --build-arg HALO_VERSION=1.4.3 -t halo .

# 指定加速器（由于国内直接通过 github 下载非常缓慢，通过此选项可以使用加速器下载）
docker build --build-arg HALO_VERSION='1.4.3' --build-arg GITHUB_PROXY='https://ghproxy.com/' -t halo .
```

### docker 启动

```bash
docker run \
  --name halo \
  --restart=always \
  -p 8090:8090 \
  -v ~/.halo:/root/.halo \
  -e HALO_DATABASE='MYSQL' \
  -e HALO_SERVER_PORT='8090' \
  -e HALO_SERVER_COMPRESSION_ENABLED='false' \
  -e HALO_SPRING_DATASOURCE_DRIVER_CLASS_NAME='com.mysql.cj.jdbc.Driver' \
  -e HALO_SPRING_DATASOURCE_URL='jdbc:mysql://127.0.0.1:3306/halodb?characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true' \
  -e HALO_SPRING_DATASOURCE_USERNAME='root' \
  -e HALO_SPRING_DATASOURCE_PASSWORD='123456' \
  -e HALO_HALO_ADMIN_PATH='admin' \
  -e HALO_HALO_CACHE='memory' \
  -d miacis/halo
```

## 变量使用说明

所有的配置项以 `HALO_` 开始，后面按照配置项层级依次使用 `_` 连接，**并且需要将配置项中的 `-` 替换为 `_`**，使用 `-` 的变量名称将被丢弃！

目前只支持 3 个层级的配置项。

在使用环境变量初始化时，配置项并未区分大小写，示例中仅仅是为了美观。

### 个别变量说明

- > HALO_DATABASE='MYSQL'

  此项设置数据库类型，支持的选项为 `H2`/`MYSQL`，默认 `H2`。

- > HALO_SPRING_DATASOURCE_DRIVER_CLASS_NAME='com.mysql.cj.jdbc.Driver'

  如果处理结果超过 3 级的配置项，会将前两项拆分，剩余内容作为一个配置项。

  以上变量初始化在配置文件内如下：

  ```yaml
  spring:
    datasource:
      driver-class-name: com.mysql.cj.jdbc.driver
  ```