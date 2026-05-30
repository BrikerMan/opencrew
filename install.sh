#!/usr/bin/env bash
set -euo pipefail

# opencrew installer
# Version: 20260530.01
# Source:  https://github.com/brikerman/opencrew
#
# What it does:
#   Default: installs into the CURRENT PROJECT (cwd) — only this project is affected
#   --global: installs globally — available in any directory
#   Skills are always installed to ~/.agents/skills/ (loaded by name, globally shared)
#   No workspace is deployed (artifacts land in the cwd where you launch opencode)
#   Compatible with macOS' stock bash 3.2
#
# Usage:
#   ./install.sh              # Project-level (default): writes ./.opencode/ and ./opencode.json
#   ./install.sh --global     # Global: writes ~/.config/opencode/
#   ./install.sh --full       # Default + disable webfetch/websearch (forces skilless)
#   ./install.sh --rollback   # Roll back the last install
#   ./install.sh --check      # Check current install state
#   ./install.sh --force      # Overwrite existing/modified files
#   ./install.sh --help

VERSION="20260530.01"

# ─── Paths / Args ──────────────────────────────────────────

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
RUNNING_FROM_STDIN=false
if [ "$SCRIPT_PATH" = "bash" ] || [ "$SCRIPT_PATH" = "-" ]; then
  RUNNING_FROM_STDIN=true
  SCRIPT_DIR=""
else
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
fi
SRC_AGENTS="${SCRIPT_DIR:+$SCRIPT_DIR/agents}"
SRC_SKILLS="${SCRIPT_DIR:+$SCRIPT_DIR/skills}"

# Skills are always global (loaded by name)
GLOBAL_SKILLS_DIR="$HOME/.agents/skills"

# Global paths
GLOBAL_AGENTS_DIR="$HOME/.config/opencode/agents"
GLOBAL_CONFIG="$HOME/.config/opencode/opencode.json"

# Project paths (relative to cwd)
PROJECT_DIR="$(pwd)"
PROJECT_AGENTS_DIR="$PROJECT_DIR/.opencode/agent"
PROJECT_CONFIG="$PROJECT_DIR/opencode.json"

# Mode
SCOPE="project"       # project | global
FORCE_MODE=false
FULL_MODE=false

BACKUP_BASE="$HOME/.config/opencode/backup-opencrew"

# Bootstrap (for curl | bash one-liner installs)
REPO_URL="${OPENCREW_REPO:-https://github.com/brikerman/opencrew.git}"
REPO_BRANCH="${OPENCREW_BRANCH:-main}"
CACHE_DIR="${OPENCREW_CACHE:-$HOME/.cache/opencrew}"

# ─── Metadata ──────────────────────────────────────────────

MANAGED_AGENTS=(lead coder qa researcher fixer butler)

MANAGED_SKILLS=(
  bm.brainstorming
  bm.verification
  bm.systematic-troubleshooting
  bm.voice-of-user
  bm.research
  bm.review-checklist
  bm.skill-improvement
  bm.project-mgmt
  bm.meeting
  bm.health
  bm.life-journal
  bm.wellness
  bm.communication
)

agent_mode() {
  case "$1" in
    lead|coder|qa) echo "primary" ;;
    researcher|fixer|butler) echo "subagent" ;;
  esac
}

agent_permission() {
  case "$1" in
    lead|coder|qa)        echo '{"*":"allow","task":{"*":"allow"}}' ;;
    researcher|fixer|butler) echo '{"write":"allow","edit":"allow","bash":"allow","task":"deny"}' ;;
  esac
}

agent_description() {
  case "$1" in
    lead)       echo "Lead — your AI chief of staff. Orchestrates everything: coding, research, writing, projects, meetings, life." ;;
    coder)      echo "Coder — engineering agent. Writes code, fixes bugs, refactors, builds UI." ;;
    qa)         echo "QA — quality gate. Tests, code review, doc review." ;;
    researcher) echo "Researcher — deep-research sub-agent. Prompt-scoped writes to ./research/ and ./working/research/." ;;
    fixer)      echo "Fixer — targeted-fix sub-agent. Prompt-scoped writes to listed files and fixer artifacts only." ;;
    butler)     echo "Butler — caretaker. Prompt-scoped writes to reports and working suggestions only." ;;
  esac
}

# ─── Colors ────────────────────────────────────────────────

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  C_RESET="$(tput sgr0)"; C_BOLD="$(tput bold)"; C_DIM="$(tput dim)"
  C_RED="$(tput setaf 1)"; C_GREEN="$(tput setaf 2)"; C_YELLOW="$(tput setaf 3)"
  C_BLUE="$(tput setaf 4)"; C_MAGENTA="$(tput setaf 5)"; C_CYAN="$(tput setaf 6)"
else
  C_RESET=""; C_BOLD=""; C_DIM=""
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_MAGENTA=""; C_CYAN=""
fi

info() { printf "%s[•]%s %s\n" "$C_CYAN" "$C_RESET" "$*"; }
ok()   { printf "%s[✓]%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf "%s[!]%s %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
err()  { printf "%s[✗]%s %s\n" "$C_RED" "$C_RESET" "$*"; }
step() { printf "\n%s%s━━━ %s ━━━%s\n" "$C_BOLD" "$C_BLUE" "$*" "$C_RESET"; }

safe_inc() { eval "$1=\$((\$$1 + 1))"; }

# Stats
STAT_AGENTS=0
STAT_AGENTS_SKIP=0
STAT_SKILLS=0
STAT_SKILLS_SKIP=0
STAT_REGISTERED=0
STAT_BUILTIN=0
STAT_SKILLESS_OK=false
STAT_FULL_TOGGLED=false

# ─── Banner ────────────────────────────────────────────────

print_banner() {
  cat <<EOF

${C_BOLD}${C_MAGENTA}┌────────────────────────────────────────────────────────────┐${C_RESET}
${C_BOLD}${C_MAGENTA}│${C_RESET}  ${C_BOLD}opencrew${C_RESET} ${C_DIM}v${VERSION}${C_RESET}                                    ${C_BOLD}${C_MAGENTA}│${C_RESET}
${C_BOLD}${C_MAGENTA}│${C_RESET}  ${C_DIM}your AI crew on top of opencode · 6 agents · 13 skills${C_RESET}    ${C_BOLD}${C_MAGENTA}│${C_RESET}
${C_BOLD}${C_MAGENTA}└────────────────────────────────────────────────────────────┘${C_RESET}

EOF
}

# ─── Scope-aware path selectors ───────────────────────────

current_agents_dir() {
  if [ "$SCOPE" = "global" ]; then echo "$GLOBAL_AGENTS_DIR"; else echo "$PROJECT_AGENTS_DIR"; fi
}
current_config() {
  if [ "$SCOPE" = "global" ]; then echo "$GLOBAL_CONFIG"; else echo "$PROJECT_CONFIG"; fi
}
current_backup_dir() {
  if [ "$SCOPE" = "global" ]; then echo "$BACKUP_BASE/global"; else echo "$BACKUP_BASE/project-$(echo "$PROJECT_DIR" | sed 's|/|_|g')"; fi
}

prompt_path_for_agent() {
  local agent="$1"
  if [ "$SCOPE" = "global" ]; then
    echo "{file:~/.config/opencode/agents/${agent}.md}"
  else
    echo "{file:./.opencode/agent/${agent}.md}"
  fi
}

# ─── Backup / Rollback ────────────────────────────────────

do_backup() {
  step "Backup"
  local b; b="$(current_backup_dir)"
  rm -rf "$b"
  mkdir -p "$b"
  : > "$b/manifest.txt"

  local cfg; cfg="$(current_config)"
  if [ -f "$cfg" ]; then
    cp "$cfg" "$b/opencode.json"
    echo "config:$cfg" >> "$b/manifest.txt"
  fi

  local ad; ad="$(current_agents_dir)"
  for agent in "${MANAGED_AGENTS[@]}"; do
    local dst="$ad/${agent}.md"
    if [ -f "$dst" ]; then
      cp "$dst" "$b/agent-${agent}.md"
      echo "agent:$dst" >> "$b/manifest.txt"
    fi
  done

  for skill in "${MANAGED_SKILLS[@]}"; do
    local dst="$GLOBAL_SKILLS_DIR/${skill}/SKILL.md"
    if [ -f "$dst" ]; then
      cp "$dst" "$b/skill-${skill}.md"
      echo "skill:$dst" >> "$b/manifest.txt"
    fi
  done

  ok "Backed up to ${C_DIM}${b}${C_RESET}"
}

do_rollback() {
  local glob_b="$BACKUP_BASE/global"
  local proj_b; proj_b="$BACKUP_BASE/project-$(echo "$(pwd)" | sed 's|/|_|g')"

  local b=""
  if [ "$SCOPE" = "global" ]; then
    b="$glob_b"
  else
    b="$proj_b"
  fi

  if [ ! -f "$b/manifest.txt" ]; then
    if [ "$SCOPE" = "global" ]; then
      err "No global backup found (${glob_b})"
    else
      err "No backup found for current project (${proj_b})"
      err "If you meant to roll back a global install, run: $0 --global --rollback"
    fi
    exit 1
  fi

  step "Rollback (${SCOPE})"
  while IFS=: read -r type path; do
    [ -z "${type:-}" ] && continue
    case "$type" in
      config)
        cp "$b/opencode.json" "$path"
        ok "Restored $path"
        ;;
      agent)
        local f; f="$(basename "$path")"
        if [ -f "$b/agent-$f" ]; then
          cp "$b/agent-$f" "$path"
          ok "Restored $path"
        else
          rm -f "$path"
          ok "Removed $path (didn't exist before install)"
        fi
        ;;
      skill)
        local sn; sn="$(basename "$(dirname "$path")")"
        if [ -f "$b/skill-$sn.md" ]; then
          mkdir -p "$(dirname "$path")"
          cp "$b/skill-$sn.md" "$path"
          ok "Restored $path"
        else
          rm -f "$path"
          ok "Removed $path (didn't exist before install)"
        fi
        ;;
      created)
        rm -f "$path"
        rmdir "$(dirname "$path")" 2>/dev/null || true
        rmdir "$(dirname "$(dirname "$path")")" 2>/dev/null || true
        ok "Removed $path"
        ;;
      created-skill)
        rm -f "$path"
        rmdir "$(dirname "$path")" 2>/dev/null || true
        ok "Removed $path"
        ;;
      created-config)
        rm -f "$path"
        ok "Removed $path"
        ;;
    esac
  done < "$b/manifest.txt"
  rm -rf "$b"
  echo
  ok "${C_BOLD}Rollback complete${C_RESET}"
  exit 0
}

preflight_install() {
  step "Preflight"

  if ! command -v jq >/dev/null 2>&1; then
    err "${C_BOLD}jq is required${C_RESET} to merge and verify opencode.json"
    err "Install jq, then re-run this installer:"
    err "  brew install jq"
    exit 1
  fi

  if [ ! -d "$SRC_AGENTS" ] || [ ! -d "$SRC_SKILLS" ]; then
    err "Installer source tree is incomplete: missing agents/ or skills/"
    exit 1
  fi

  ok "Requirements satisfied"
}

# ─── Install steps ─────────────────────────────────────────

step_install_agents() {
  local ad; ad="$(current_agents_dir)"
  local b; b="$(current_backup_dir)"
  step "Install Agents (6) → ${C_DIM}${ad}${C_RESET}"
  mkdir -p "$ad"
  local agent src dst pre_existed
  for agent in "${MANAGED_AGENTS[@]}"; do
    src="$SRC_AGENTS/${agent}.md"
    dst="$ad/${agent}.md"
    if [ ! -f "$src" ]; then
      warn "Source missing: $src"; continue
    fi
    if [ -f "$dst" ]; then pre_existed=true; else pre_existed=false; fi
    if [ "$pre_existed" = "true" ] && [ "$FORCE_MODE" = "false" ] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
      safe_inc STAT_AGENTS_SKIP
      continue
    fi
    cp "$src" "$dst"
    if [ "$pre_existed" = "false" ]; then
      echo "created:$dst" >> "$b/manifest.txt"
    fi
    printf "  %s✓%s %-12s %s%s%s\n" "$C_GREEN" "$C_RESET" "${agent}.md" "$C_DIM" "$(agent_mode "$agent")" "$C_RESET"
    safe_inc STAT_AGENTS
  done
  if [ "$STAT_AGENTS_SKIP" -gt 0 ] 2>/dev/null; then
    warn "$STAT_AGENTS_SKIP agents skipped (differ from source, use --force to overwrite)"
  fi
}

step_install_skills() {
  local b; b="$(current_backup_dir)"
  step "Install Skills (13) → ${C_DIM}${GLOBAL_SKILLS_DIR}${C_RESET}"
  mkdir -p "$GLOBAL_SKILLS_DIR"
  local skill src dst pre_existed
  for skill in "${MANAGED_SKILLS[@]}"; do
    src="$SRC_SKILLS/${skill}/SKILL.md"
    dst="$GLOBAL_SKILLS_DIR/${skill}/SKILL.md"
    if [ ! -f "$src" ]; then
      warn "Source missing: $src"; continue
    fi
    if [ -f "$dst" ]; then pre_existed=true; else pre_existed=false; fi
    if [ "$pre_existed" = "true" ] && [ "$FORCE_MODE" = "false" ] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
      safe_inc STAT_SKILLS_SKIP
      continue
    fi
    mkdir -p "$GLOBAL_SKILLS_DIR/${skill}"
    cp "$src" "$dst"
    if [ "$pre_existed" = "false" ]; then
      echo "created-skill:$dst" >> "$b/manifest.txt"
    fi
    printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "${skill}"
    safe_inc STAT_SKILLS
  done
  if [ "$STAT_SKILLS_SKIP" -gt 0 ] 2>/dev/null; then
    warn "$STAT_SKILLS_SKIP skills skipped (differ from source, use --force to overwrite)"
  fi
}

step_merge_config() {
  local cfg; cfg="$(current_config)"
  local b; b="$(current_backup_dir)"
  step "Merge config → ${C_DIM}${cfg}${C_RESET}"

  if [ ! -f "$cfg" ]; then
    mkdir -p "$(dirname "$cfg")"
    cat > "$cfg" <<'JSON'
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "lead"
}
JSON
    echo "created-config:$cfg" >> "$b/manifest.txt"
    ok "Created new config"
  fi

  jq 'if .agent == null then . + {"agent":{}} else . end' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"

  local agent exists mode perm desc prompt agent_json
  for agent in "${MANAGED_AGENTS[@]}"; do
    exists=$(jq --arg a "$agent" '.agent[$a] != null' "$cfg")
    mode="$(agent_mode "$agent")"
    perm="$(agent_permission "$agent")"
    desc="$(agent_description "$agent")"
    prompt="$(prompt_path_for_agent "$agent")"
    agent_json=$(jq -n \
      --arg desc "$desc" --arg mode "$mode" \
      --arg prompt "$prompt" --argjson perm "$perm" \
      '{description: $desc, mode: $mode, prompt: $prompt, permission: $perm}')

    if [ "$exists" = "false" ]; then
      jq --arg a "$agent" --argjson cfg "$agent_json" '.agent[$a] = $cfg' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
      printf "  %s✓%s registered %-12s %s%s%s\n" "$C_GREEN" "$C_RESET" "$agent" "$C_DIM" "$mode" "$C_RESET"
      safe_inc STAT_REGISTERED
    elif [ "$FORCE_MODE" = "true" ]; then
      jq --arg a "$agent" --argjson cfg "$agent_json" '.agent[$a] = $cfg' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
      printf "  %s✓%s refreshed  %-12s %s%s%s\n" "$C_GREEN" "$C_RESET" "$agent" "$C_DIM" "$mode" "$C_RESET"
      safe_inc STAT_REGISTERED
    else
      printf "  %s•%s %-12s %salready exists, skipped%s\n" "$C_DIM" "$C_RESET" "$agent" "$C_DIM" "$C_RESET"
    fi
  done

  # Disable built-in build / plan
  local builtin already
  for builtin in build plan; do
    already=$(jq --arg b "$builtin" '.agent[$b].disable // false' "$cfg")
    if [ "$already" != "true" ]; then
      jq --arg b "$builtin" '.agent[$b] = ((.agent[$b] // {}) + {"disable": true})' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
      printf "  %s✓%s disabled built-in %s\n" "$C_GREEN" "$C_RESET" "$builtin"
      safe_inc STAT_BUILTIN
    fi
  done

  # default_agent
  local da
  da=$(jq -r '.default_agent // empty' "$cfg")
  if [ -z "$da" ]; then
    jq '.default_agent = "lead"' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    ok "Set default_agent = ${C_BOLD}lead${C_RESET}"
  elif [ "$da" != "lead" ]; then
    warn "default_agent is ${C_BOLD}$da${C_RESET}, not overwriting your choice"
  else
    ok "default_agent = ${C_BOLD}lead${C_RESET}"
  fi

  # --full: deny webfetch / websearch
  if [ "$FULL_MODE" = "true" ]; then
    jq '.permission = ((.permission // {}) + {"webfetch":"deny","websearch":"deny"})' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    ok "${C_BOLD}--full${C_RESET}: disabled webfetch / websearch (forces skilless)"
    STAT_FULL_TOGGLED=true
  fi
}

step_check_skilless() {
  step "Check skilless"
  if [ -d "$HOME/.agents/skills/skilless" ] || [ -d "$HOME/.agents/skills/skilless.ai-research" ]; then
    ok "${C_BOLD}skilless${C_RESET}: installed"
    STAT_SKILLESS_OK=true
  else
    warn "${C_BOLD}skilless${C_RESET}: not installed"
    printf "    Provides search / web / yt-dlp / ffmpeg CLI tools — researcher prefers it.\n"
    printf "    Install: %s%s%s\n" "$C_CYAN" "curl -fsSL https://skilless.ai/install.sh | bash" "$C_RESET"
  fi
}

# ─── Check ─────────────────────────────────────────────────

# Extract version string from YAML frontmatter (first 10 lines)
extract_version() {
  head -10 "$1" 2>/dev/null | sed -n 's/^version:[[:space:]]*"\?\([^"]*\)"\?/\1/p' | head -1
}

do_check() {
  step "Check (${SCOPE})"
  local errors=0 warnings=0 outdated=0
  local ad; ad="$(current_agents_dir)"
  local cfg; cfg="$(current_config)"
  local have_src=false
  [ -d "$SRC_AGENTS" ] && [ -d "$SRC_SKILLS" ] && have_src=true

  info "[1/3] Agent files (${ad})"
  for agent in "${MANAGED_AGENTS[@]}"; do
    if [ ! -f "$ad/${agent}.md" ]; then
      printf "  %s✗%s %s — missing\n" "$C_RED" "$C_RESET" "${agent}.md"
      safe_inc errors
    elif $have_src && [ -f "$SRC_AGENTS/${agent}.md" ] && ! diff -q "$SRC_AGENTS/${agent}.md" "$ad/${agent}.md" >/dev/null 2>&1; then
      local v_src v_dst
      v_src="$(extract_version "$SRC_AGENTS/${agent}.md")"
      v_dst="$(extract_version "$ad/${agent}.md")"
      if [ -n "$v_src" ] && [ -n "$v_dst" ]; then
        printf "  %s[~]%s %-14s %soutdated (%s → %s)%s\n" "$C_YELLOW" "$C_RESET" "${agent}.md" "$C_DIM" "$v_dst" "$v_src" "$C_RESET"
      else
        printf "  %s[~]%s %-14s %soutdated (differs from source)%s\n" "$C_YELLOW" "$C_RESET" "${agent}.md" "$C_DIM" "$C_RESET"
      fi
      safe_inc outdated
    else
      printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "${agent}.md"
    fi
  done

  echo; info "[2/3] Skill files (${GLOBAL_SKILLS_DIR})"
  for skill in "${MANAGED_SKILLS[@]}"; do
    if [ ! -f "$GLOBAL_SKILLS_DIR/${skill}/SKILL.md" ]; then
      printf "  %s✗%s %s — missing\n" "$C_RED" "$C_RESET" "${skill}"
      safe_inc errors
    elif $have_src && [ -f "$SRC_SKILLS/${skill}/SKILL.md" ] && ! diff -q "$SRC_SKILLS/${skill}/SKILL.md" "$GLOBAL_SKILLS_DIR/${skill}/SKILL.md" >/dev/null 2>&1; then
      local v_src v_dst
      v_src="$(extract_version "$SRC_SKILLS/${skill}/SKILL.md")"
      v_dst="$(extract_version "$GLOBAL_SKILLS_DIR/${skill}/SKILL.md")"
      if [ -n "$v_src" ] && [ -n "$v_dst" ]; then
        printf "  %s[~]%s %-30s %soutdated (%s → %s)%s\n" "$C_YELLOW" "$C_RESET" "${skill}" "$C_DIM" "$v_dst" "$v_src" "$C_RESET"
      else
        printf "  %s[~]%s %-30s %soutdated (differs from source)%s\n" "$C_YELLOW" "$C_RESET" "${skill}" "$C_DIM" "$C_RESET"
      fi
      safe_inc outdated
    else
      printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "${skill}"
    fi
  done

  echo; info "[3/3] Config (${cfg})"
  if [ ! -f "$cfg" ]; then
    err "Config does not exist"
    safe_inc errors
  elif command -v jq >/dev/null 2>&1; then
    for agent in "${MANAGED_AGENTS[@]}"; do
      local configured
      configured=$(jq --arg a "$agent" '.agent[$a] != null' "$cfg")
      if [ "$configured" = "true" ]; then
        printf "  %s✓%s %s registered\n" "$C_GREEN" "$C_RESET" "$agent"
      else
        printf "  %s✗%s %s not registered\n" "$C_RED" "$C_RESET" "$agent"
        safe_inc errors
      fi
    done
    local da; da=$(jq -r '.default_agent // empty' "$cfg")
    if [ "$da" = "lead" ]; then
      printf "  %s✓%s default_agent = lead\n" "$C_GREEN" "$C_RESET"
    else
      warn "  default_agent = ${da:-(not set)}"
      safe_inc warnings
    fi
  else
    warn "  jq not installed"
    safe_inc warnings
  fi

  echo
  if [ $errors -gt 0 ]; then
    err "$errors error(s), $warnings warning(s), $outdated outdated"
    return 1
  elif [ $outdated -gt 0 ]; then
    warn "$outdated file(s) outdated, $warnings warning(s) — use --force to upgrade"
    return 0
  elif [ $warnings -eq 0 ]; then
    ok "${C_BOLD}All checks passed${C_RESET}"
    return 0
  else
    warn "$warnings warning(s), not blocking"
    return 0
  fi
}

# ─── Summary ───────────────────────────────────────────────

print_summary() {
  local scope_label
  if [ "$SCOPE" = "global" ]; then
    scope_label="${C_BOLD}${C_MAGENTA}global${C_RESET} ${C_DIM}(any directory)${C_RESET}"
  else
    scope_label="${C_BOLD}${C_CYAN}project${C_RESET} ${C_DIM}(${PROJECT_DIR})${C_RESET}"
  fi

  local mode_extra=""
  [ "$FULL_MODE" = "true" ] && mode_extra="${mode_extra} --full"
  [ "$FORCE_MODE" = "true" ] && mode_extra="${mode_extra} --force"

  local skilless_badge="${C_DIM}not installed (recommended)${C_RESET}"
  [ "$STAT_SKILLESS_OK" = "true" ] && skilless_badge="${C_GREEN}installed${C_RESET}"

  local full_line=""
  if [ "$STAT_FULL_TOGGLED" = "true" ]; then
    full_line="
  ${C_YELLOW}⚡${C_RESET} ${C_BOLD}disabled${C_RESET} built-in webfetch / websearch (using skilless)"
  fi

  local skip_hint=""
  if [ "$STAT_AGENTS_SKIP" -gt 0 ] 2>/dev/null || [ "$STAT_SKILLS_SKIP" -gt 0 ] 2>/dev/null; then
    skip_hint="  ${C_DIM}Use --force to overwrite existing files${C_RESET}
"
  fi

  cat <<EOF

${C_BOLD}${C_GREEN}╔════════════════════════════════════════════════════════════╗${C_RESET}
${C_BOLD}${C_GREEN}║                   Install complete                         ║${C_RESET}
${C_BOLD}${C_GREEN}╚════════════════════════════════════════════════════════════╝${C_RESET}

  ${C_BOLD}Scope${C_RESET}           $scope_label
  ${C_BOLD}Options${C_RESET}        $mode_extra
  ${C_BOLD}Version${C_RESET}         $VERSION

  ${C_BOLD}Agents${C_RESET}          ${C_GREEN}$STAT_AGENTS${C_RESET} installed  ${C_DIM}/ $STAT_AGENTS_SKIP skipped${C_RESET}
  ${C_BOLD}Skills${C_RESET}          ${C_GREEN}$STAT_SKILLS${C_RESET} installed  ${C_DIM}/ $STAT_SKILLS_SKIP skipped${C_RESET}
${skip_hint}  ${C_BOLD}Registered${C_RESET}      ${C_GREEN}$STAT_REGISTERED${C_RESET} agent(s)  ${C_DIM}/ $STAT_BUILTIN built-in disabled${C_RESET}
  ${C_BOLD}Default agent${C_RESET}   ${C_BOLD}${C_CYAN}lead${C_RESET}
  ${C_BOLD}skilless${C_RESET}        $skilless_badge${full_line}

${C_BOLD}${C_BLUE}━━━ Next ━━━${C_RESET}

EOF

  if [ "$SCOPE" = "project" ]; then
    cat <<EOF
  ${C_DIM}From inside the project directory:${C_RESET}
  ${C_CYAN}\$${C_RESET} cd "$PROJECT_DIR"
  ${C_CYAN}\$${C_RESET} opencode                          ${C_DIM}# launch TUI, default lead${C_RESET}

  ${C_DIM}If you want it available in any directory:${C_RESET}
  ${C_CYAN}\$${C_RESET} ./install.sh --global

EOF
  else
    cat <<EOF
  ${C_CYAN}\$${C_RESET} opencode                          ${C_DIM}# launch TUI from anywhere${C_RESET}
  ${C_CYAN}\$${C_RESET} opencode run "..." --agent lead

EOF
  fi

  cat <<EOF
  ${C_CYAN}\$${C_RESET} ./install.sh --check              ${C_DIM}# check install state${C_RESET}
  ${C_CYAN}\$${C_RESET} ./install.sh --rollback           ${C_DIM}# roll back this install${C_RESET}

EOF

  if [ "$STAT_SKILLESS_OK" != "true" ]; then
    cat <<EOF
${C_YELLOW}╭─ Recommended: install skilless ─────────────────────────╮${C_RESET}
${C_YELLOW}│${C_RESET}  search / web / yt-dlp / ffmpeg CLI tool chain
${C_YELLOW}│${C_RESET}  ${C_CYAN}curl -fsSL https://skilless.ai/install.sh | bash${C_RESET}
${C_YELLOW}╰─────────────────────────────────────────────────────────╯${C_RESET}

EOF
  fi
}

# ─── Main ──────────────────────────────────────────────────

print_help() {
  cat <<EOF
opencrew installer

Usage: ./install.sh [options]

  (no args)    ${C_BOLD}Default${C_RESET}: project-level install (writes ./.opencode/ + ./opencode.json)
  --global     Global install (writes ~/.config/opencode/)
  --full       Also disable built-in webfetch/websearch (use skilless instead)
  --force      Overwrite locally-modified files (still backs up first)
  --rollback   Roll back the last install
  --check      Only check current install state
  --help       Show this help

One-liner (curl | bash):
  curl -fsSL https://raw.githubusercontent.com/brikerman/opencrew/main/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/brikerman/opencrew/main/install.sh | bash -s -- --global
  curl -fsSL https://raw.githubusercontent.com/brikerman/opencrew/main/install.sh | bash -s -- --global --full

Examples (after clone):
  ./install.sh                      # install into current project
  ./install.sh --global             # install globally
  ./install.sh --global --full      # global + disable webfetch/websearch

EOF
}

bootstrap_if_needed() {
  # Source tree is colocated → already running from a clone, nothing to do.
  if [ "$RUNNING_FROM_STDIN" = "false" ] && [ -d "$SRC_AGENTS" ] && [ -d "$SRC_SKILLS" ]; then
    return 0
  fi

  print_banner
  step "Bootstrap (one-liner install)"

  if ! command -v git >/dev/null 2>&1; then
    err "git is required for the curl|bash one-liner. Install git, or clone the repo manually:"
    err "  git clone $REPO_URL && cd opencrew && ./install.sh"
    exit 1
  fi

  mkdir -p "$CACHE_DIR"
  local repo_dir="$CACHE_DIR/repo"

  if [ -d "$repo_dir/.git" ]; then
    info "Updating cached repo: $repo_dir"
    if ! ( cd "$repo_dir" && git fetch --depth=1 origin "$REPO_BRANCH" >/dev/null 2>&1 \
          && git reset --hard "origin/$REPO_BRANCH" >/dev/null 2>&1 ); then
      warn "git fetch failed, re-cloning..."
      rm -rf "$repo_dir"
    fi
  fi

  if [ ! -d "$repo_dir/.git" ]; then
    info "Cloning ${C_BOLD}$REPO_URL${C_RESET} → $repo_dir"
    if ! git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$repo_dir" >/dev/null 2>&1; then
      err "git clone failed. Check network and $REPO_URL."
      exit 1
    fi
  fi

  ok "Source ready. Re-executing installer from clone..."
  echo
  exec bash "$repo_dir/install.sh" "$@"
}

main() {
  bootstrap_if_needed "$@"

  local op_check=false op_rollback=false
  while [ $# -gt 0 ]; do
    case "$1" in
      --global)   SCOPE="global" ;;
      --full)     FULL_MODE=true ;;
      --force)    FORCE_MODE=true ;;
      --check)    op_check=true ;;
      --rollback) op_rollback=true ;;
      --help|-h)  print_help; exit 0 ;;
      *)          err "Unknown option: $1"; print_help; exit 2 ;;
    esac
    shift
  done

  if $op_rollback; then
    print_banner
    do_rollback
  fi

  if $op_check; then
    print_banner
    do_check
    exit $?
  fi

  print_banner
  preflight_install
  do_backup
  step_install_agents
  step_install_skills
  step_merge_config
  step_check_skilless

  echo
  step "Verify"
  if ! do_check; then
    echo
    err "${C_BOLD}Verification failed${C_RESET}"
    err "Roll back with: $0 --rollback"
    exit 1
  fi

  print_summary
}

main "$@"
