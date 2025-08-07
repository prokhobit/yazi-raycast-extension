#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title yazi
# @raycast.mode silent

# @raycast.icon
# @raycast.packageName Yazi Tools
# @raycast.description Launch Yazi file browser in your default terminal
# @raycast.author prokhobit

###------ Terminal detection ------###
if command -v wezterm &>/dev/null; then
  terminal_cmd="wezterm"
elif command -v kitty &>/dev/null; then
  terminal_cmd="kitty"
elif command -v alacritty &>/dev/null; then
  terminal_cmd="alacritty"
elif command -v ghostty &>/dev/null; then
  terminal_cmd="ghostty"
else
  terminal_cmd="open -a Terminal"
fi

###------ Check if yazi is installed ------###
if ! command -v yazi >/dev/null 2>&1; then
  PROMPT=$(
    osascript <<EOF
display dialog "yazi is not installed. Would you like to install the latest version?" buttons {"No", "Yes"} default button "Yes" with title "yazi not found"
EOF
  )

  if [[ "$PROMPT" == *"Yes"* ]]; then
    if command -v brew >/dev/null 2>&1; then
      osascript -e 'display notification "updating homebrew..." with title "yazi installer"'
      brew update
      brew install yazi --HEAD
    else
      osascript -e 'display notification "homebrew not found. Opening yazi GitHub page..." with title "yazi installer"'
      open "https://github.com/sxyazi/yazi"
    fi
  else
    osascript -e 'display notification "yazi launch cancelled..." with title "yazi-raycast-extension"'
    exit 0
  fi
fi

###------ Get current Finder directory (fallback to $HOME otherwise) ------###
DIR=$(
  osascript 2>/dev/null <<EOF
tell application "Finder"
  try
    set thePath to (insertion location as alias)
    return POSIX path of thePath
  on error
    return "$HOME"
  end try
end tell
EOF
)

###------ If found, use the $DIR ------###
if [[ -n "$1" ]]; then
  DIR="$1"
fi

###------ Finally launch yazi in your terminal ------###
if [[ "$terminal_cmd" == "terminal" ]]; then
  osascript <<EOF
tell application "Terminal"
  activate
  do script "cd \"$DIR\" && yazi"
end tell
EOF
else
  "$terminal_cmd" -e yazi "$DIR" &
fi
