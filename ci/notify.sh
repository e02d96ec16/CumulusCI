#!/bin/sh
version_info_file_full_path="$BUILD_WORKSPACE/package.properties"
if [ -e "$version_info_file_full_path" ]; then
  if [ "$HIPCHAT_ROOM_NOTIFICATION_URL" ]; then
    echo 'Notifying HipChat...'
    # shellcheck source=/dev/null
    . "$version_info_file_full_path"
    notification_color="purple"
    notification_message="$PACKAGE_VERSION\n$INSTALL_URL\n$TIMESTAMP"
    notification_notifies=true
    notification_message_format="text"

    curl  -d "{\"color\":\"$notification_color\",\"message\":\"$notification_message\",\"notify\":$notification_notifies,\"message_format\":\"$notification_message_format\"}" \
          -H 'Content-Type: application/json' \
          "$HIPCHAT_ROOM_NOTIFICATION_URL"
  else
    echo "No notifiers found"
  fi
else
  echo "File with package information not found: $BUILD_WORKSPACE/package.properties"
fi
