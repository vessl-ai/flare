#!/bin/sh
# Bootstrap script for VESSL flare.
set -e

echo "Bootstrapping VESSL Flare..."
URL_BASE="flare.vessl.ai"

########################
# HELPER FUNCTIONS START

# Usage: _command_exists <command>
_command_exists() {
  type "$1" >/dev/null 2>&1
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
  for PY_CANDIDATE in \
    "python3.11" \
    "python3.10" \
    "python3.9" \
    "python3.8" \
    "python3.7" \
    "python3.6" \
    "python3"
  do
    if _command_exists "${PY_CANDIDATE}"
    then
      PY_CMD="${PY_CANDIDATE}"
      unset PY_CANDIDATE
      return
    fi
  done
  unset PY_CANDIDATE

  if _command_exists python
  then
    if [ "$(python -c "import sys; print(sys.version_info[0])")" = "3" ]
    then
      PY_CMD="python"
      return
    fi
  fi

  echo "Error: no 'python3.X', 'python3', nor 'python' (that is Python 3) found."
  echo "Sorry, but VESSL Flare requires Python 3."
  exit 1
}

_check_root() {
  _EUID=$(id -u)
  if [ "${_EUID}" != "0" ]
  then
    echo "===== WARNING! ====="
    echo "You do not appear to be root (user id ${_EUID} != 0)."
    echo "Without root permission, Flare may not able to read"
    echo "certain system files or execute certain commands."
    echo
    echo "We recommend running Flare with root permission."
    if _command_exists sudo
    then
      echo "For example:"
      echo "  \$ curl -L ${URL_BASE} | sudo sh"
    fi
    echo

    if [ -n "${FLARE_NOROOT}" ]
    then
      echo "Since FLARE_NOROOT environment variable is set,"
      echo "Flare will run without root permission."
      echo
      return 0
    fi

    if [ ! -r "/dev/tty" ]
    then
      echo "Cannot open /dev/tty for prompting; giving up."
      echo "If you want to run Flare as non-root without interaction,"
      echo "set environment variable FLARE_NOROOT to non-empty string, and run again."
      return 1
    fi

    echo "Do you want to continue running Flare as non-root?"
    printf "[Type 'y' or 'yes' to continue]: "

    read -r RESP < /dev/tty
    case "${RESP}" in
      "y"|"yes") return 0 ;;
      *) return 1 ;;
    esac
  fi
}

# HELPER FUNCTIONS END
#########################

_find_python3
_check_root

TEMPDIR="$(mktemp -d)"
PATH_TAR="${TEMPDIR}/flare.tar"
PATH_PYROOT="${TEMPDIR}/code"

mkdir -p "${PATH_PYROOT}"

_download_to "${URL_BASE}/flare.tar" "${PATH_TAR}"
tar -x -f "${PATH_TAR}" -C "${PATH_PYROOT}"

"${PY_CMD}" "${PATH_PYROOT}/main.py" "$@"
