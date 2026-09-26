#!/bin/sh
set -e

WRT_DIR="$GITHUB_WORKSPACE/wrt"
PATCH_DIR="$WRT_DIR/package/system/apk/patches"
PATCH_FILE="$PATCH_DIR/0101-allow-untrusted-by-default.patch"

mkdir -p "$PATCH_DIR"

cat > "$PATCH_FILE" <<'PATCH'
--- a/src/context.c
+++ b/src/context.c
@@ -68,7 +68,7 @@ int apk_ctx_prepare(struct apk_ctx *ac)
 		ac->open_flags &= ~(APK_OPENF_CREATE | APK_OPENF_WRITE);
 		ac->open_flags |= APK_OPENF_READ;
 	}
-	if (ac->flags & APK_ALLOW_UNTRUSTED) ac->trust.allow_untrusted = 1;
+	ac->trust.allow_untrusted = 1;
 	if (!ac->cache_dir) ac->cache_dir = "etc/apk/cache";
 	else ac->cache_dir_set = 1;
 	if (!ac->root) ac->root = "/";
PATCH

echo "APK 补丁已应用"
echo "$PATCH_FILE"
