#!/usr/bin/env bash
# create-extension.sh
# Bootstrap a new AEM UI Extension project using the AIO CLI.
# Usage: ./create-extension.sh [project-name] [surface]
# Surfaces: cfe | ue | cfc | xp
set -euo pipefail

# ─── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ─── Surface → template map ────────────────────────────────────────────────────
declare -A TEMPLATES=(
  [cfe]="@adobe/aem-cf-editor-ui-ext-tpl"
  [ue]="@adobe/aem-universal-editor-ui-ext-tpl"
  [cfc]="@adobe/aem-cf-console-admin-ui-ext-tpl"
  [xp]="experience-hub-ext-tpl"
)

declare -A SURFACE_LABELS=(
  [cfe]="Content Fragment Editor"
  [ue]="Universal Editor"
  [cfc]="Content Fragment Console"
  [xp]="Experience Hub"
)

# ─── Argument / interactive input ──────────────────────────────────────────────
PROJECT_NAME="${1:-}"
SURFACE="${2:-}"

if [[ -z "$PROJECT_NAME" ]]; then
  read -rp "Project name (e.g. my-cfe-extension): " PROJECT_NAME
fi
[[ -z "$PROJECT_NAME" ]] && error "Project name is required."

if [[ -z "$SURFACE" ]]; then
  echo ""
  echo "Target surface:"
  echo "  cfe  – Content Fragment Editor"
  echo "  ue   – Universal Editor"
  echo "  cfc  – Content Fragment Console"
  echo "  xp   – Experience Hub"
  read -rp "Surface [cfe]: " SURFACE
  SURFACE="${SURFACE:-cfe}"
fi

[[ -z "${TEMPLATES[$SURFACE]+_}" ]] && \
  error "Unknown surface '${SURFACE}'. Valid values: cfe, ue, cfc, xp"

TEMPLATE="${TEMPLATES[$SURFACE]}"
LABEL="${SURFACE_LABELS[$SURFACE]}"

# ─── Prerequisites ─────────────────────────────────────────────────────────────
info "Checking prerequisites…"

if ! command -v aio &>/dev/null; then
  error "AIO CLI not found. Install it with: npm install -g @adobe/aio-cli"
fi
ok "AIO CLI: $(aio --version 2>/dev/null | head -1)"

if ! command -v node &>/dev/null; then
  error "Node.js not found. Install Node 18 or later."
fi
ok "Node: $(node --version)"

if ! command -v npm &>/dev/null; then
  error "npm not found."
fi
ok "npm: $(npm --version)"

# ─── Auth & workspace ──────────────────────────────────────────────────────────
echo ""
info "Checking AIO login status…"
if ! aio context get 2>/dev/null | grep -q "access_token"; then
  warn "Not logged in. Opening browser for IMS authentication…"
  aio login
fi
ok "Logged in."

echo ""
info "Select your Adobe I/O Console org / project / workspace."
info "Follow the interactive prompts below."
echo ""
aio console org select
aio console project select
aio console workspace select

echo ""
info "Current context:"
aio where

# ─── Scaffold ──────────────────────────────────────────────────────────────────
echo ""
info "Initialising new App Builder project: ${PROJECT_NAME}"
info "Target surface : ${LABEL}"
info "Template       : ${TEMPLATE}"
echo ""
warn "When prompted by the AIO CLI:"
warn "  → 'What templates do you want to search for?' → choose 'All Extension Points'"
warn "  → Select the template for ${LABEL}: ${TEMPLATE}"
echo ""

aio app init "${PROJECT_NAME}"

# ─── Post-scaffold setup ───────────────────────────────────────────────────────
if [[ ! -d "${PROJECT_NAME}" ]]; then
  error "Project directory '${PROJECT_NAME}' was not created. Check AIO CLI output above."
fi

cd "${PROJECT_NAME}"
ok "Changed into project directory: $(pwd)"

echo ""
info "Installing npm dependencies…"
npm install
ok "Dependencies installed."

# ─── Verification build ────────────────────────────────────────────────────────
echo ""
info "Running verification build (aio app build)…"
aio app build
ok "Build succeeded."

# ─── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN} Extension project ready: ${PROJECT_NAME}${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Start local dev server:"
echo "       cd ${PROJECT_NAME} && aio app dev"
echo ""
echo "  2. Open the URL printed by 'aio app dev' to verify the extension"
echo "     loads in the ${LABEL} host (use ?devMode=true&ext=https://localhost:9080)"
echo ""
echo "  3. Implement your extension in:"
echo "       src/dx-excshell-1/web-src/src/components/ExtensionRegistration.jsx"
echo "       src/dx-excshell-1/actions/"
echo ""
echo "  4. Run tests:"
echo "       aio app test"
echo ""
echo "  5. View action logs:"
echo "       aio app logs"
echo ""
