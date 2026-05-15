#!/usr/bin/env bash
set -euo pipefail

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
  if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - bash)"
  fi
fi

cd "$(dirname "$0")"

if ! bundle check >/dev/null 2>&1; then
  echo "==> Installing dependencies (bundle install)"
  bundle install
fi

echo "==> Starting Jekyll at http://127.0.0.1:4000 (Ctrl+C to stop)"
exec bundle exec jekyll serve --watch "$@"
