#!/bin/sh
version_info_file_full_path="$BUILD_WORKSPACE/package.properties.var"
if [ -e "$version_info_file_full_path" ]; then
  if [ "$HIPCHAT_ROOM_NOTIFICATION_URL" ]; then
    echo 'Notifying HipChat...'
    # shellcheck source=/dev/null
    . "$version_info_file_full_path"
    PACKAGE_ID=$(echo "$INSTALL_URL" | cut -d"=" -f 2)
    notification_color="purple"
    # This message is still required. HipChat reverts to it in environments without full functionality support.
    notification_message="<a href='$INSTALL_URL'>$PACKAGE_VERSION</a><br/>$TIMESTAMP"
    # Passive or active level
    notification_notifies=true
    notification_message_format="html"
    curl  -d "\
            {\
              \"color\":\"$notification_color\",\
              \"message\":\"$notification_message\",\
              \"notify\":$notification_notifies,\
              \"message_format\":\"$notification_message_format\",\
              \"card\" : {\
                \"style\": \"application\",\
                \"format\": \"compact\",\
                \"url\" : \"$INSTALL_URL\",\
                \"id\": \"1\",\
                \"title\" : \"New package released\",\
                \"icon\": {\
                  \"url\": \"$ATLAS_CARD_ICON\"\
                },\
                \"attributes\": [\
                  {\
                    \"label\": \"Version\",\
                    \"value\": {\
                      \"label\": \"$PACKAGE_VERSION\"
                    }\
                  },\
                  {\
                    \"label\": \"Timestamp\",\
                    \"value\": {\
                      \"label\": \"$TIMESTAMP\"\
                    }\
                  },\
                  {\
                    \"label\": \"ID\",\
                    \"value\": {\
                      \"label\": \"$PACKAGE_ID\"\
                    }\
                  }\
                ]\
              }\
            }" \
          -H 'Content-Type: application/json' \
          "$HIPCHAT_ROOM_NOTIFICATION_URL"
  else
    echo "No notifiers found"
  fi
else
  echo "File with package information not found: $version_info_file_full_path"
fi
