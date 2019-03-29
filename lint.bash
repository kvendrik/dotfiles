if [[ -z "$(command -v shellcheck)" ]]; then
  if ! brew install shellcheck; then
    echo 'ShellCheck not found and failed to install through brew. Check shellcheck.net for instructions on how to install ShellCheck.'
    exit 1
  fi
fi

all_files=$(ls -pa | grep -v / | sed /README.md/d | tr '\n' ' ')

echo "Checking $all_files"

shellcheck $all_files