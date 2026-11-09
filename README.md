# Navidrome for TerraMaster TOS 7

TOS 7 App Center package for [Navidrome](https://www.navidrome.org).

一个把 [Navidrome](https://www.navidrome.org) 打包上架到 TOS 7 应用中心的 Docker 应用（单容器、单数据卷、SQLite，零外部依赖）。

---

## What it does / 这是什么

Navidrome scans a folder of your own music files and serves it as a
streaming library with a modern web UI and a Subsonic/OpenSubsonic API,
so mobile players, desktop clients and browsers can all use one library.

- Web UI on host port `10029` -> container `4533`
- Reads your existing files and tags, keeps its database in one SQLite file
- Runs as a non-root user, no privileged mode, no host networking
- Compatible with Subsonic / OpenSubsonic clients (DSub, Symfonium, play:Sub, ...)

## Package contents / 包内文件

```
navidrome.tar.gz
├── config.ini            # TOS application metadata
├── navidrome.lang           # 14 languages (zh-cn, zh-hk, en-us, ... pt-pt)
├── navidrome.svg            # application icon (SVG, transparent)
└── docker-compose.yml    # container definition
```

## docker-compose.yml

```yaml
# TOS 7 Docker application - Navidrome
# Rules: Docker Hub image with a LOCKED version tag; non-root user;
#        no privileged mode, no host networking; data persisted via bind mounts.
# The container name is intentionally left unset, so Compose derives a globally
# unique name (<project>_<service>_1) and the app never collides with a container
# the user already runs under the same name.

version: "3.8"

services:
  navidrome:
    image: deluan/navidrome:0.64.2
    restart: unless-stopped
    user: "1000:1000"
    ports:
      - "10029:4533"
    # Host path `/data` is the platform's documented absolute form: TOS maps it
    # to /Volume<N>/DockerAppData/<appid>/data at install time (spec 9.3, rule 4).
    # Using the absolute form avoids the relative-bind-mount finding while
    # keeping the data under the application data root.
    # `/music` is resolved the same way, to /Volume<N>/DockerAppData/navidrome/music.
    # It is read only: Navidrome never rewrites your files.
    volumes:
      - /data:/data
      - /music:/music:ro
    environment:
      - TZ=Asia/Shanghai
      - ND_MUSICFOLDER=/music
      - ND_DATAFOLDER=/data
      - ND_PORT=4533
    healthcheck:
      test: ["CMD-SHELL", "(command -v curl >/dev/null && curl -fsS http://localhost:4533/ping) || (command -v wget >/dev/null && wget -q -O /dev/null http://localhost:4533/ping) || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

x-app-meta:
  web:
    port: 10029
    protocol: http
```

`music/` is mounted read-only (`/music` on the host, resolved to `/Volume<N>/DockerAppData/navidrome/music`): Navidrome only reads your files, it never rewrites them. Copy your library into that folder.

## Build / 打包

```sh
./build.sh          # writes navidrome.tar.gz + navidrome.tar.gz.sha256
```

## Data location / 数据位置

TOS places the bind mounts under `/Volume<N>/DockerAppData/navidrome/`; the
`data/` folder holds everything that must survive an update or a
reinstall (database, attachments, configuration).

## Upstream / 上游

- Project: https://github.com/navidrome/navidrome
- Docker image: https://hub.docker.com/r/deluan/navidrome
- License: GPL-3.0 (see LICENSE / NOTICE in this repository)

## Notes / 注意

Put your music files into the music/ folder of the application data directory, then open the web UI and create the first account - the first registered user becomes the administrator. Docker Engine must be installed and enabled from the TOS App Center.

请先把音乐文件放入应用数据目录下的 music/ 文件夹，然后打开网页界面创建第一个账号，首位注册的用户即为管理员。需先在应用中心安装并启用 DockerEngine。
