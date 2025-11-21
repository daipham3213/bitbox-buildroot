#!/usr/bin/sh

# make sure scripts and binaries bundled are executable
sudo chmod +x $TARGET_DIR/etc/init.d/
sudo chmod +x $TARGET_DIR/etc/profile.d/
sudo chmod +x $TARGET_DIR/usr/bin/
