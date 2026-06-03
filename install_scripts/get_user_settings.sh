#!/bin/bash
CONFIGURATION=$1

read -rp "📦 Install $CONFIGURATION configurations? [Y/n]: " ANSWER

ANSWER=${ANSWER,,}

if [[ -z "$ANSWER" || "$ANSWER" == "y" || "$ANSWER" == "yes" ]]; then
    echo "✅ $CONFIGURATION enabled" >&2
	echo "true"
else
	echo "⏭️ Skipping $CONFIGURATION configurations" >&2
    echo "false"
fi
echo " " >&2