#!/bin/bash

SCCACHE_VERSION="0.8.1"
SCCACHE_ARCH="x86_64-unknown-linux-musl"
SCCACHE_DOWNLOAD_URL="https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${SCCACHE_ARCH}.tar.gz"
SCCACHE_INSTALL_PATH="/usr/bin/sccache"

CURL_OPTS="--connect-timeout 120 --max-time 600 --retry 5 --retry-delay 60"

SCCACHE_TMP_DIR="sccache-v${SCCACHE_VERSION}-${SCCACHE_ARCH}"

if ! command -v curl &> /dev/null; then
    echo "❌ 错误：未找到 curl 命令，请先安装 curl！"
    exit 1
fi

if ! command -v tar &> /dev/null; then
    echo "❌ 错误：未找到 tar 命令，请先安装 tar！"
    exit 1
fi

echo "🔽 正在下载 sccache v${SCCACHE_VERSION}（架构：${SCCACHE_ARCH}）..."
if ! curl ${CURL_OPTS} "${SCCACHE_DOWNLOAD_URL}" | tar xz; then
    echo "❌ 错误：sccache 下载或解压失败！请检查网络或下载链接是否有效。"
    # 清理可能的半解压目录
    [ -d "${SCCACHE_TMP_DIR}" ] && rm -rf "${SCCACHE_TMP_DIR}"
    exit 1
fi

if [ ! -f "${SCCACHE_TMP_DIR}/sccache" ]; then
    echo "❌ 错误：解压成功，但未找到可执行文件 ${SCCACHE_TMP_DIR}/sccache！"
    rm -rf "${SCCACHE_TMP_DIR}"
    exit 1
fi

echo "📦 正在安装 sccache 到 ${SCCACHE_INSTALL_PATH}..."
mv "${SCCACHE_TMP_DIR}/sccache" "${SCCACHE_INSTALL_PATH}"

chmod 755 "${SCCACHE_INSTALL_PATH}"

echo "🧹 清理解压临时目录..."
rm -rf "${SCCACHE_TMP_DIR}"


echo "⚙️ 配置 sccache 环境变量..."
if [ -n "${GITHUB_ENV:-}" ]; then
    echo "SCCACHE_DIR=/root/.cache/sccache" >> "${GITHUB_ENV}"
    echo "RUSTC_WRAPPER=$(which sccache)" >> "${GITHUB_ENV}"
fi

echo -n "✅ 安装完成！sccache 版本："
sccache --version | head -n1
