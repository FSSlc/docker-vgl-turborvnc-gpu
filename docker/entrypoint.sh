#!/usr/bin/env bash

set -euo pipefail

export HOME=/root
export USER=root
export LOGNAME=root
export SHELL=/bin/bash
export PATH="/opt/TurboVNC/bin:/opt/VirtualGL/bin:${PATH}"
export VNC_DISPLAY="${VNC_DISPLAY:-:1}"
export VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
export VNC_DEPTH="${VNC_DEPTH:-24}"
export VNC_PASSWORD="${VNC_PASSWORD:-root}"
export VNC_RESET_PASSWORD="${VNC_RESET_PASSWORD:-1}"
export VNC_NOVNC_DIR="${VNC_NOVNC_DIR:-/opt/noVNC}"
export VNC_EXTRA_ARGS="${VNC_EXTRA_ARGS:-}"
export VGL_DISPLAY="${VGL_DISPLAY:-egl0}"
export VGL_COMPRESS="${VGL_COMPRESS:-proxy}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-root}"
export DISPLAY="${DISPLAY:-${VNC_DISPLAY}}"

mkdir -p "${XDG_RUNTIME_DIR}" /root/.vnc
chmod 700 "${XDG_RUNTIME_DIR}" /root/.vnc

if [[ "${1:-start}" != "start" ]]; then
  exec "$@"
fi

if [[ ! -s /root/.vnc/passwd || "${VNC_RESET_PASSWORD}" == "1" ]]; then
  # 验证密码长度 (至少 6 位)
  if [[ ${#VNC_PASSWORD} -lt 6 ]]; then
    echo "ERROR: VNC_PASSWORD must be at least 6 characters" >&2
    exit 1
  fi

  # 安全地设置密码
  if ! /opt/TurboVNC/bin/vncpasswd -f <<<"${VNC_PASSWORD}" > /root/.vnc/passwd 2>/dev/null; then
    echo "ERROR: Failed to set VNC password" >&2
    exit 1
  fi

  chmod 600 /root/.vnc/passwd

  # 验证密码文件
  if [[ ! -s /root/.vnc/passwd ]]; then
    echo "ERROR: VNC password file is empty" >&2
    exit 1
  fi

  echo "VNC password configured successfully"
fi

# 清除环境变量中的密码
unset VNC_PASSWORD

echo "Starting desktop on ${VNC_DISPLAY} with ${VNC_GEOMETRY}x${VNC_DEPTH}, VGL_DISPLAY=${VGL_DISPLAY}"

exec /opt/container/vnc-start.sh
