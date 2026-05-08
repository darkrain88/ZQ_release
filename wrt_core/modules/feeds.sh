#!/usr/bin/env bash

get_feeds_path() {
    local feeds_path="$BUILD_DIR/$FEEDS_CONF"
    if [[ -f "$BUILD_DIR/feeds.conf" ]]; then
        feeds_path="$BUILD_DIR/feeds.conf"
    fi
    printf '%s\n' "$feeds_path"
}

update_feeds() {
    local FEEDS_PATH
    FEEDS_PATH=$(get_feeds_path)
    sed -i '/^#/d' "$FEEDS_PATH"
    sed -i '/packages_ext/d' "$FEEDS_PATH"

    # if ! grep -q "small-package" "$FEEDS_PATH"; then
    #     [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
    #     echo "src-git small8 https://github.com/kenzok8/jell" >>"$FEEDS_PATH"
    # fi

    if ! grep -q "openwrt-passwall" "$FEEDS_PATH"; then
        [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
        echo "src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall;main" >>"$FEEDS_PATH"
    fi

    if ! grep -q "openwrt_bandix" "$FEEDS_PATH"; then
        [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
        echo 'src-git openwrt_bandix https://github.com/timsaya/openwrt-bandix.git;main' >>"$FEEDS_PATH"
    fi

    if ! grep -q "luci_app_bandix" "$FEEDS_PATH"; then
        [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
        echo 'src-git luci_app_bandix https://github.com/timsaya/luci-app-bandix.git;main' >>"$FEEDS_PATH"
    fi

    if ! grep -q "nikki" "$FEEDS_PATH"; then
        [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
        echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >>"$FEEDS_PATH"
    fi

    if [ ! -f "$BUILD_DIR/include/bpf.mk" ]; then
        touch "$BUILD_DIR/include/bpf.mk"
    fi

    ./scripts/feeds update -a
}

install_feeds() {
    ./scripts/feeds update -i
    for dir in $BUILD_DIR/feeds/*; do
        if [ -d "$dir" ] && [[ ! "$dir" == *.tmp ]] && [[ ! "$dir" == *.index ]] && [[ ! "$dir" == *.targetindex ]]; then
            local feed_name
            feed_name=$(basename "$dir")
            if [[ "$feed_name" == "passwall" ]]; then
                install_passwall
            elif [[ "$feed_name" == "nikki" ]]; then
                install_nikki
            else
                ./scripts/feeds install -f -ap "$feed_name"
            fi
        fi
    done
}
