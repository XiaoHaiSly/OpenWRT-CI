#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修改argon主题颜色
if [ -d "$PACKAGE_PATH/luci-app-argon-config" ]; then
	echo " "
	if sed -i "s/ primary '.*'/ primary '#5e72e4'/g; s/ blur '.*'/ blur '0'/g; s/ transparency '.*'/ transparency '0.3'/g; s/ online_wallpaper '.*'/ online_wallpaper 'none'/g" \
		"$PACKAGE_PATH/luci-app-argon-config/root/etc/config/argon"; then
		echo "theme-argon has been fixed!"
	else
		echo "theme-argon fix failed; continuing!"
	fi
fi

#修改aurora菜单式样
if [ -d "$PACKAGE_PATH/luci-app-aurora-config" ]; then
	echo " "
	if find "$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec \
		sed -i "s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +; then
		echo "theme-aurora has been fixed!"
	else
		echo "theme-aurora fix failed; continuing!"
	fi
fi

#修改mini-diskmanager菜单位置
if [ -d "$PACKAGE_PATH/luci-app-mini-diskmanager" ]; then
	echo " "
	if sed -i "s/services/system/g" \
		"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"; then
		echo "mini-diskmanager has been fixed!"
	else
		echo "mini-diskmanager fix failed; continuing!"
	fi
fi

#修改openlist菜单位置
if [ -d "$FEEDS_PATH/luci/applications/luci-app-openlist" ]; then
	echo " "
	if sed -i "s/services/nas/g" \
		"$FEEDS_PATH/luci/applications/luci-app-openlist/root/usr/share/luci/menu.d/luci-app-openlist.json"; then
		echo "openlist has been fixed!"
	else
		echo "openlist fix failed; continuing!"
	fi
fi

#修复Rust编译失败
if [ -d "$FEEDS_PATH/packages/lang/rust" ]; then
	echo " "
	if sed -i 's/ci-llvm=true/ci-llvm=false/g' \
		"$FEEDS_PATH/packages/lang/rust/Makefile"; then
		echo "rust has been fixed!"
	else
		echo "rust fix failed; continuing!"
	fi
fi

#替换docker相关包并检查一致性
for DOCKER_PKG in docker dockerd containerd runc docker-compose; do
	DOCKER_SRC="./package/luci-app-dockerman/$DOCKER_PKG"
	DOCKER_DST="./feeds/packages/utils/$DOCKER_PKG"

	if [ -d "$DOCKER_SRC" ] && [ -d "./feeds/packages/utils" ]; then
		rm -rf "$DOCKER_DST"
		mv -f "$DOCKER_SRC" "$DOCKER_DST"
		echo "Replace official $DOCKER_PKG with repo version: $DOCKER_DST"
	else
		echo "Not found $DOCKER_PKG in luci-app-dockerman repo, keep official version!"
	fi
done

[ -f "./feeds/packages/utils/dockerd/git-short-commit.sh" ] && chmod +x "./feeds/packages/utils/dockerd/git-short-commit.sh"

DOCKER_CLI_VER=$(grep -Po "^PKG_VERSION:=\K.*" ./feeds/packages/utils/docker/Makefile 2>/dev/null)
DOCKERD_VER=$(grep -Po "^PKG_VERSION:=\K.*" ./feeds/packages/utils/dockerd/Makefile 2>/dev/null)
if [ -n "$DOCKER_CLI_VER" ] && [ "$DOCKER_CLI_VER" != "$DOCKERD_VER" ]; then
	echo "WARNING: docker ($DOCKER_CLI_VER) and dockerd ($DOCKERD_VER) versions differ, dockerd build will fail!"
fi
