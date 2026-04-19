#!/usr/bin/env bash

set -euo pipefail

export HOME=/root
export USER=root
export LOGNAME=root
export PATH="/opt/TurboVNC/bin:/opt/VirtualGL/bin:${PATH}"

display_number="${VNC_DISPLAY#:}"

# 更可靠的清理逻辑
cleanup_display() {
  local display="$1"
  local display_num="${display#:}"

  # 尝试正常关闭
  /opt/TurboVNC/bin/vncserver -kill "${display}" 2>/dev/null || true

  # 强制清理锁文件
  rm -f "/tmp/.X${display_num}-lock" "/tmp/.X11-unix/X${display_num}"

  # 清理可能残留的进程
  pkill -f "Xvnc ${display}" 2>/dev/null || true

  # 等待端口释放
  local port=$((5900 + display_num))
  for i in {1..5}; do
    if ! command -v lsof >/dev/null 2>&1 || ! lsof -i ":${port}" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
}

cleanup_display "${VNC_DISPLAY}"

cat > /root/.vnc/xstartup.turbovnc <<'EOF'
#!/usr/bin/env bash
exec /opt/container/xfce-session.sh
EOF
chmod +x /root/.vnc/xstartup.turbovnc

args=(
  "${VNC_DISPLAY}"
  -fg
  -geometry "${VNC_GEOMETRY}"
  -depth "${VNC_DEPTH}"
  -wm xfce
  -novnc "${VNC_NOVNC_DIR}"
  -localhost no
)

if [[ -n "${VNC_EXTRA_ARGS:-}" ]]; then
  read -r -a extra_args <<< "${VNC_EXTRA_ARGS}"
  args+=("${extra_args[@]}")
fi

exec /opt/TurboVNC/bin/vncserver "${args[@]}"
