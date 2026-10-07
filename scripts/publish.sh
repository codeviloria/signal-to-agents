#!/usr/bin/env bash
# Builds the blog, pushes it to GitHub and deploys it to Cloudflare Pages.
#   bash scripts/publish.sh
# First run: creates the GitHub repo and the Cloudflare Pages project (opens the browser to log in).
# Next runs: commit + push + deploy whatever changed.
set -euo pipefail

REPO="signal-to-agents"
PROJECT="signal-to-agents"           # → https://signal-to-agents.pages.dev
DESC="Signal to Agents: AI agents, local LLMs and telecom engineering (blog)"
cd "$(dirname "$0")/.."

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31mERROR: %s\033[0m\n' "$*"; exit 1; }

say "Checking tools"
command -v git >/dev/null || die "git not installed"
command -v gh  >/dev/null || die "gh not installed"
command -v node >/dev/null || die "Node.js not installed (needs >= 22.12)"
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
[ "$NODE_MAJOR" -ge 22 ] || die "Node $(node -v) is too old; Astro needs >= 22.12"
gh auth status >/dev/null 2>&1 || die "gh not logged in: gh auth login"
USER_GH="$(gh api user -q .login)"

say "Build"
[ -d node_modules ] || npm install --no-audit --no-fund
npm run build

say "Git commit"
[ -d .git ] || git init -b main
git add .
git diff --cached --name-only | grep -Eq '(^|/)\.env$' && { git reset -q; die ".env staged; nothing pushed"; }
git diff --cached --quiet || git commit -q -m "${1:-Update blog}"
git log --oneline -1

say "GitHub"
if gh repo view "$USER_GH/$REPO" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "git@github.com:$USER_GH/$REPO.git"
  git push -u origin main
else
  gh repo create "$REPO" --public --source=. --push --description "$DESC"
  gh repo edit "$USER_GH/$REPO" --add-topic "blog,astro,ai,agents,llm,telecom,5g" >/dev/null
fi

say "Cloudflare Pages (first time: a browser window opens to log in)"
npx --yes wrangler@latest whoami >/dev/null 2>&1 || npx --yes wrangler@latest login
npx --yes wrangler@latest pages project create "$PROJECT" --production-branch main >/dev/null 2>&1 || true
npx --yes wrangler@latest pages deploy dist --project-name "$PROJECT" --branch main --commit-dirty=true

say "Done"
echo "Blog: https://$PROJECT.pages.dev"
echo "Repo: https://github.com/$USER_GH/$REPO"
