#!/bin/sh
# Bootstrap script for VESSL flare.
set -e

########################
# HELPER FUNCTIONS START

# Usage: _command_exists <command>
_command_exists() {
  type "$1" 2>&1 >/dev/null
}

# Usage: _download_to <url> <path>
_download_to() {
  if _command_exists curl
  then
    curl -sSfL -o "$2" "$1"
    return
  fi

  if _command_exists wget
  then
    wget -nv -t 0 -O "$2" "$1"
    return
  fi

  echo "Error: no curl or wget found. Cannot download flare code; aborting."
  exit 1
}

_find_python3() {
  local PY_CANDIDATE
  for PY_CANDIDATE in \
    "python3" \
    "python3.6" \
    "python3.7" \
    "python3.8" \
    "python3.9" \
    "python3.10" \
    "python3.11"
  do
    if _command_exists "${PY_CANDIDATE}"
    then
      PY_CMD="${PY_CANDIDATE}"
      return
    fi
  done

  if _command_exists python
  then
    if [ "$(python -c "import sys; print(sys.version_info[0])")" = "3" ]
    then
      PY_CMD="python"
      return
    fi
  fi

  echo "Error: no 'python3', 'python3.X', nor 'python' (that is Python 3) found."
  echo "Sorry, but VESSL Flare requires Python 3."
  exit 1
}

# HELPER FUNCTIONS END
#########################

_find_python3

TEMPDIR="$(mktemp -d)"
PATH_TAR="${TEMPDIR}/flare.tar"
PATH_PYROOT="${TEMPDIR}/code"
URL_BASE="flare.vessl.ai"

mkdir -p "${PATH_PYROOT}"

_download_to "${URL_BASE}/flare.tar" "${PATH_TAR}"
tar -x -f "${PATH_TAR}" -C "${PATH_PYROOT}"

"${PY_CMD}" "${PATH_PYROOT}/main.py"
