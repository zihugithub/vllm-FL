#!/bin/bash
set -euo pipefail  # 开启严格模式：报错即退出、未定义变量报错、管道错误传递

# ===================== 配置参数（集中管理，便于修改）=====================
SCCACHE_VERSION="0.8.1"
SCCACHE_ARCH="x86_64-unknown-linux-musl"
SCCACHE_DOWNLOAD_URL="https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${SCCACHE_ARCH}.tar.gz"
SCCACHE_INSTALL_PATH="/usr/bin/sccache"
# curl 优化：增加静默模式（减少冗余输出）、显示进度条，保留原有的超时/重试
CURL_OPTS="--connect-timeout 120 --max-time 600 --retry 5 --retry-delay 60 --silent --show-error --progress-bar -L"
# 解压后的临时目录（通过变量复用，避免硬编码写错）
SCCACHE_TMP_DIR="sccache-v${SCCACHE_VERSION}-${SCCACHE_ARCH}"

# 检查 curl 命令是否存在（依赖 curl 下载）
if ! command -v curl &> /dev/null; then
    echo "❌ 错误：未找到 curl 命令，请先安装 curl！"
    exit 1
fi

# 检查 tar 命令是否存在（依赖 tar 解压）
if ! command -v tar &> /dev/null; then
    echo "❌ 错误：未找到 tar 命令，请先安装 tar！"
    exit 1
fi

# ===================== 核心操作：下载并解压 =====================
echo "🔽 正在下载 sccache v${SCCACHE_VERSION}（架构：${SCCACHE_ARCH}）..."
if ! curl ${CURL_OPTS} "${SCCACHE_DOWNLOAD_URL}" | tar xz; then
    echo "❌ 错误：sccache 下载或解压失败！请检查网络或下载链接是否有效。"
    # 清理可能的半解压目录
    [ -d "${SCCACHE_TMP_DIR}" ] && rm -rf "${SCCACHE_TMP_DIR}"
    exit 1
fi

# 检查解压后的可执行文件是否存在（避免解压失败但无报错的情况）
if [ ! -f "${SCCACHE_TMP_DIR}/sccache" ]; then
    echo "❌ 错误：解压成功，但未找到可执行文件 ${SCCACHE_TMP_DIR}/sccache！"
    rm -rf "${SCCACHE_TMP_DIR}"
    exit 1
fi

# ===================== 安装并授权 =====================
echo "📦 正在安装 sccache 到 ${SCCACHE_INSTALL_PATH}..."
mv "${SCCACHE_TMP_DIR}/sccache" "${SCCACHE_INSTALL_PATH}"
# 显式设置可执行权限（覆盖原有权限，确保能运行）
chmod 755 "${SCCACHE_INSTALL_PATH}"

# ===================== 清理临时文件 =====================
echo "🧹 清理解压临时目录..."
rm -rf "${SCCACHE_TMP_DIR}"

# ===================== 配置环境变量（适配 GitHub Actions + 本地环境）=====================
echo "⚙️ 配置 sccache 环境变量..."
if [ -n "${GITHUB_ENV:-}" ]; then
    echo "SCCACHE_DIR=/root/.cache/sccache" >> "${GITHUB_ENV}"
    echo "RUSTC_WRAPPER=$(which sccache)" >> "${GITHUB_ENV}"
else
    echo "ℹ️ 本地环境建议添加以下环境变量到 ~/.bashrc 或 /etc/profile："
    echo "  export SCCACHE_DIR=/root/.cache/sccache"
    echo "  export RUSTC_WRAPPER=$(which sccache)"
fi

# ===================== 验证安装 =====================
echo -n "✅ 安装完成！sccache 版本："
sccache --version | head -n1
