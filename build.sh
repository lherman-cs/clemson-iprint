#!/bin/bash

exists(){
   command -v "$@" 2>&1 > /dev/null
}

TARGET_URL="http://www.clemson.edu/onlineprinting"
APP_NAME="Clemson iPrint"
PKG_NAME="iprint"
MAINTAINER="Lukas Herman"
DESCRIPTION="Clemson iPrint desktop app for debian based linux"
DEFAULT_FLAGS="--single-instance --disable-context-menu --disable-dev-tools --name $PKG_NAME"
HOME_PATH=$(dirname `pwd`/`dirname "$0"`)
TARGET_HOME_PATH="$HOME_PATH/$PKG_NAME"
TARGET_APP_PATH="$TARGET_HOME_PATH/usr/share"
TARGET_BIN_PATH="$TARGET_HOME_PATH/usr/bin"
TARGET_DESKTOP_SHORTCUT_PATH="$TARGET_APP_PATH/applications"
TARGET_DEBIAN_PATH="$TARGET_HOME_PATH/DEBIAN"

DESKTOP_SHORTCUT_PATH="$HOME_PATH/desktop.template"
CONTROL_PATH="$HOME_PATH/control.template"


if ! exists npm
then
   sudo apt-get update && sudo apt-get install -y npm
fi

if ! exists nativefier
then
   sudo npm install -g nativefier
fi

echo "Creating $TARGET_APP_PATH directory..."
[ -d $TARGET_APP_PATH ] || mkdir -p $TARGET_APP_PATH

if [ -d "$TARGET_APP_PATH/$PKG_NAME" ]
then
   rm -rf "$TARGET_APP_PATH/$PKG_NAME"
fi

echo "Building $APP_NAME app..."
read -p "Extra flags [Default=$DEFAULT_FLAGS]: " flags
nativefier $DEFAULT_FLAGS $flags $TARGET_URL 2>&1 > /dev/null
mv "$PKG_NAME-linux-x64" "$TARGET_APP_PATH/$PKG_NAME"
chmod -R +rx "$TARGET_APP_PATH/$PKG_NAME/resources/app"

echo "Linking the executable file for $APP_NAME..."
[ -d $TARGET_BIN_PATH ] || mkdir -p $TARGET_BIN_PATH
rm -rf $TARGET_BIN_PATH/$PKG_NAME
cd "$TARGET_BIN_PATH" && ln -sr "../share/$PKG_NAME/$PKG_NAME" "$PKG_NAME"
cd "$HOME_PATH"

echo "Creating desktop shortcut for $APP_NAME..."
[ -d $TARGET_DESKTOP_SHORTCUT_PATH ] || mkdir -p $TARGET_DESKTOP_SHORTCUT_PATH
sed "s/{NAME}/$APP_NAME/g" $DESKTOP_SHORTCUT_PATH | sed "s/{CMD}/$PKG_NAME/g" > "$TARGET_DESKTOP_SHORTCUT_PATH/$PKG_NAME.desktop"

echo "Creating DEBIAN control..."
[ -d $TARGET_DEBIAN_PATH ] || mkdir -p $TARGET_DEBIAN_PATH
sed "s/{NAME}/$PKG_NAME/g" $CONTROL_PATH | sed "s/{MAINTAINER}/$MAINTAINER/g" | sed "s/{DESCRIPTION}/$DESCRIPTION/g" > "$TARGET_DEBIAN_PATH/control"

echo "Packaging $APP_NAME..."
fakeroot dpkg-deb --build "$TARGET_HOME_PATH" 2>&1 > /dev/null
