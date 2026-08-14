#!/bin/bash
GOOGLESERVICE_INFO_PLIST=GoogleService-Info.plist
if [[ "$CONFIGURATION" == *-dev ]]; then
  ENVIRONMENT="dev"
elif [[ "$CONFIGURATION" == *-prod ]]; then
  ENVIRONMENT="prod"
else
  ENVIRONMENT="dev"
fi
PLIST_SOURCE="${PROJECT_DIR}/Runner/config/${ENVIRONMENT}/${GOOGLESERVICE_INFO_PLIST}"
PLIST_DESTINATION="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/${GOOGLESERVICE_INFO_PLIST}"
if [ -f "$PLIST_SOURCE" ]; then
    cp "$PLIST_SOURCE" "$PLIST_DESTINATION"
else
    exit 1
fi
