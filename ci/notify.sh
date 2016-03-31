#!/bin/sh
version_info_file_full_path="$BUILD_WORKSPACE/package.properties.var"
if [ -e "$version_info_file_full_path" ]; then
  # Loading the package version information as variables
  # shellcheck source=/dev/null
  . "$version_info_file_full_path"
  # Extracting the package ID from the installation URL
  PACKAGE_ID=$(echo "$INSTALL_URL" | cut -d"=" -f 2)
  if [ "$HIPCHAT_ROOM_NOTIFICATION_URL" ]; then
    echo 'Notifying HipChat...'
    # This message is still required. HipChat reverts to it in environments without full functionality support.
    hipchat_fallback_notification_message="<a href='$INSTALL_URL'>$PACKAGE_VERSION</a><br/>$TIMESTAMP"
    # Passive or active level
    hipchat_notification_is_loud=true
    hipchat_notification_message_format="html"

    # Default values
    hipchat_default_atlas_card_icon="https://d3oaxc4q5k2d6q.cloudfront.net/m/418317b0b62e/emoji/img/package.svg" # A Bitbucket emoji of a package
    hipchat_default_notification_color="yellow" # same as HipChat's default
    if [ ! "$HIPCHAT_ATLAS_CARD_ICON" ]; then
      echo "Using default notification icon: $hipchat_default_atlas_card_icon"
      HIPCHAT_ATLAS_CARD_ICON="$hipchat_default_atlas_card_icon"
    fi
    if [ ! "$HIPCHAT_NOTIFICATION_COLOR" ]; then
      echo "Using default notification color: $hipchat_default_notification_color"
      HIPCHAT_NOTIFICATION_COLOR="$hipchat_default_notification_color"
    fi

    curl  -d "\
            {\
              \"color\":\"$HIPCHAT_NOTIFICATION_COLOR\",\
              \"message\":\"$hipchat_fallback_notification_message\",\
              \"notify\":$hipchat_notification_is_loud,\
              \"message_format\":\"$hipchat_notification_message_format\",\
              \"card\" : {\
                \"style\": \"application\",\
                \"format\": \"compact\",\
                \"url\" : \"$INSTALL_URL\",\
                \"id\": \"13599296\",\
                \"title\" : \"New package released\",\
                \"icon\": {\
                  \"url\": \"$HIPCHAT_ATLAS_CARD_ICON\"\
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
