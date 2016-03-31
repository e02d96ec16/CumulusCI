#!/bin/sh
version_info_file_full_path="$BUILD_WORKSPACE/package.properties.var"
if [ -e "$version_info_file_full_path" ]; then
  if [ "$HIPCHAT_ROOM_NOTIFICATION_URL" ]; then
    echo 'Notifying HipChat...'
    # shellcheck source=/dev/null
    . "$version_info_file_full_path"
    PACKAGE_ID=$(echo "$INSTALL_URL" | cut -d"=" -f 2)
    notification_color="purple"
    notification_message="<a href='$INSTALL_URL'>$PACKAGE_VERSION</a><br/>$TIMESTAMP"
    notification_notifies=true
    notification_message_format="html"

    curl  -d "{\"color\":\"$notification_color\",\"message\":\"$notification_message\",\"notify\":$notification_notifies,\"message_format\":\"$notification_message_format\"}" \
          -H 'Content-Type: application/json' \
          "$HIPCHAT_ROOM_NOTIFICATION_URL"
  else
    echo "No notifiers found"
  fi
else
  echo "File with package information not found: $version_info_file_full_path"
fi
