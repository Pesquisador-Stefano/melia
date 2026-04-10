#!/bin/bash
#
# Unified tmux Dashboard Launcher
# Launches all .NET servers into a single tiled window.
# -------------------------------------------------------------------------

# Change to the script's directory so paths resolve correctly.
cd "$(dirname "$0")" || exit

SESSION_NAME="ServerDashboard"
SUBFOLDER="net8.0"

# --- Function to find the binary path ---
get_dll_path() {
    local FILENAME="$1"
    if [ -f "bin/Release/$SUBFOLDER/$FILENAME" ]; then
        echo "bin/Release/$SUBFOLDER/$FILENAME"
    elif [ -f "bin/Debug/$SUBFOLDER/$FILENAME" ]; then
        echo "bin/Debug/$SUBFOLDER/$FILENAME"
    elif [ -f "bin/$SUBFOLDER/$FILENAME" ]; then
        echo "bin/$SUBFOLDER/$FILENAME"
    else
        echo ""
    fi
}

# --- Function to add a server to the tmux grid ---
# Usage: add_server "DllFileName" ["GroupID" "ServerID"]
add_server() {
    local FILENAME="$1"
    local GROUP_ID="$2"
    local SERVER_ID="$3"

    local DLL_PATH=$(get_dll_path "$FILENAME")

    if [ -z "$DLL_PATH" ]; then
        echo "ERROR: Could not find $FILENAME. Skipping..."
        return 1
    fi

    # The command to run
    local RUN_CMD="dotnet $DLL_PATH $GROUP_ID $SERVER_ID"

    # If the session doesn't exist, create it with the first server
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -n "Servers" "$RUN_CMD"
    else
        # Otherwise, split the current window and run the command
        tmux split-window -t "$SESSION_NAME" "$RUN_CMD"
        # Re-balance the panes into a neat grid
        tmux select-layout -t "$SESSION_NAME" tiled
    fi
}

# --- Main Execution ---

# 1. Clean up any old session with the same name
tmux kill-session -t "$SESSION_NAME" 2>/dev/null

echo "Building the dashboard..."

# 2. Add servers in order
# Barracks first
add_server "BarracksServer.dll" "1001" "1"
sleep 1

# Zone
add_server "ZoneServer.dll" "1001" "1"

# Social Servers
add_server "SocialServer.dll" "1001" "1"
add_server "SocialServer.dll" "1001" "2"

# Web
add_server "WebServer.dll"

# 3. Final layout tweak
tmux select-layout -t "$SESSION_NAME" tiled

# 4. Launch the terminal emulator to view the session
echo "Launching terminal..."

if command -v konsole &> /dev/null; then
    konsole --new-tab -e tmux attach-session -t "$SESSION_NAME" &
elif command -v gnome-terminal &> /dev/null; then
    gnome-terminal -- tmux attach-session -t "$SESSION_NAME" &
elif command -v xterm &> /dev/null; then
    xterm -e tmux attach-session -t "$SESSION_NAME" &
else
    echo "No terminal emulator found. Access your dashboard manually with: tmux attach-session -t $SESSION_NAME"
fi

exit 0
