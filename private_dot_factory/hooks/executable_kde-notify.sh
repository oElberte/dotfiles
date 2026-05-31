#!/usr/bin/env bash
set -u

input="$(cat)"

if [ "${DROID_DISABLE_NOTIFICATIONS:-}" = "true" ]; then
  exit 0
fi

event="$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null || true)"
message="$(jq -r '.message // empty' <<<"$input" 2>/dev/null || true)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null || true)"
session_id="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null || true)"
transcript_path="$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null || true)"
project="$(basename "${cwd:-Droid}")"

is_subagent_session() {
  local path="$1"
  [ -n "$path" ] || return 1
  [ -r "$path" ] || return 1

  head -n 1 "$path" 2>/dev/null | jq -e '
    .type == "session_start" and (
      has("callingSessionId") or
      ((.title // "") | startswith("# Task Tool Invocation")) or
      ((.sessionTitle // "") | test("^[^:]+: "))
    )
  ' >/dev/null 2>&1
}

if is_subagent_session "$transcript_path"; then
  log_dir="/home/dev/.factory/logs"
  mkdir -p "$log_dir" 2>/dev/null || true
  printf '%s\t%s\t%s\t%s\n' "$(date -Is)" "$event" "suppressed-subagent" "${transcript_path##*/}" >>"$log_dir/kde-notify.log" 2>/dev/null || true
  exit 0
fi

case "$event" in
  Notification)
    title="Droid needs attention"
    urgency="critical"
    expire="0"
    body="${message:-Droid is waiting for your input.}"
    sound="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"
    ;;
  Stop)
    title="Droid finished"
    urgency="normal"
    expire="15000"
    body="${message:-Task completed in ${project:-current session}.}"
    sound="/usr/share/sounds/freedesktop/stereo/complete.oga"
    ;;
  SessionEnd)
    title="Droid session ended"
    urgency="low"
    expire="10000"
    reason="$(jq -r '.reason // "unknown"' <<<"$input" 2>/dev/null || true)"
    body="Session ended: $reason"
    sound="/usr/share/sounds/freedesktop/stereo/complete.oga"
    ;;
  *)
    exit 0
    ;;
esac

if [ -n "$session_id" ]; then
  body="$body"$'\n'"Session: ${session_id:0:8}"
fi

log_dir="/home/dev/.factory/logs"
mkdir -p "$log_dir" 2>/dev/null || true
log_body="${body//$'\n'/ | }"
printf '%s\t%s\t%s\t%s\n' "$(date -Is)" "$event" "$title" "$log_body" >>"$log_dir/kde-notify.log" 2>/dev/null || true

if [ "${DROID_NOTIFY_DRY_RUN:-}" = "true" ]; then
  exit 0
fi

notify_current_user() {
  notify-send "$title" "$body" \
    --app-name="Droid" \
    --urgency="$urgency" \
    --expire-time="$expire" \
    --icon=dialog-information >/dev/null 2>&1 || true
}

notify_other_user() {
  local user="$1"
  local uid
  uid="$(id -u "$user" 2>/dev/null || true)"
  [ -n "$uid" ] || return 1
  [ -S "/run/user/$uid/bus" ] || return 1

  sudo -n -u "$user" \
    XDG_RUNTIME_DIR="/run/user/$uid" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
    notify-send "$title" "$body" \
      --app-name="Droid" \
      --urgency="$urgency" \
      --expire-time="$expire" \
      --icon=dialog-information >/dev/null 2>&1
}

enqueue_other_user() {
  local user="$1"
  local queue_dir="${DROID_NOTIFY_QUEUE_BASE:-/var/tmp/droid-notify-$user}/inbox"
  local safe_session="${session_id:-no-session}"
  local tmp final

  mkdir -p "$queue_dir" 2>/dev/null || return 0
  tmp="$queue_dir/.${safe_session}.$$.$RANDOM.json"
  final="$queue_dir/${safe_session}.$$.$RANDOM.json"

  umask 007
  jq -n \
    --arg event "$event" \
    --arg title "$title" \
    --arg body "$body" \
    --arg urgency "$urgency" \
    --arg expire "$expire" \
    --arg sound "${sound:-}" \
    --arg session_id "$session_id" \
    --arg cwd "$cwd" \
    --arg timestamp "$(date -Is)" \
    '{
      event: $event,
      title: $title,
      body: $body,
      urgency: $urgency,
      expire: $expire,
      sound: $sound,
      session_id: $session_id,
      cwd: $cwd,
      timestamp: $timestamp
    }' >"$tmp" 2>/dev/null && mv "$tmp" "$final" 2>/dev/null || rm -f "$tmp" 2>/dev/null || true
}

notify_current_user

IFS=',' read -r -a extra_users <<<"${DROID_NOTIFY_EXTRA_USERS:-elberte}"
for user in "${extra_users[@]}"; do
  user="${user//[[:space:]]/}"
  if [ -n "$user" ] && [ "$user" != "$(id -un)" ]; then
    notify_other_user "$user" || enqueue_other_user "$user"
  fi
done

if [ -n "${sound:-}" ] && [ -r "$sound" ]; then
  paplay "$sound" >/dev/null 2>&1 || true
fi

exit 0
