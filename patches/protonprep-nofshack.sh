#!/bin/bash

#TKG patch order:

#549 clock monotonic
#567 bypass compositor
#718 vulkan childwindow
#1044 fsync staging
#1066 fsync spincount
#1078 fs hack
#1125 rawinput
#1207 LAA
#1221 winex11-MWM
#1229 steam client swap
#1236 protonify rpc
#1237 protonify
#1239 steam bits
#1332 SDL
#1333 SDL2
#1339 gamepad additions
#1375 vr
#1386 vk bits
#1387 fs hack integer scaling
#1391 winevulkan
#1396 msvcrt native builtin
#1411 win10
#1417 dxvk_config

    cd gst-plugins-ugly
    git reset --hard HEAD
    git clean -xdf
    echo "add Guy's patch to fix wmv playback in gst-plugins-ugly"
    patch -Np1 < ../patches/gstreamer/asfdemux-always_re-initialize_metadata_and_global_metadata.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-Re-initialize_demux-adapter_in_gst_asf_demux_reset.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-Only_forward_SEEK_event_when_in_push_mode.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-gst_asf_demux_reset_GST_FORMAT_TIME_fix.patch
    cd ..

    # warframe controller fix
    git checkout lsteamclient
    cd lsteamclient
    patch -Np1 < ../patches/proton-hotfixes/steamclient-disable_SteamController007_if_no_controller.patch
    patch -Np1 < ../patches/proton-hotfixes/steamclient-use_standard_dlopen_instead_of_the_libwine_wrappers.patch
    cd ..

    # vrclient
    git checkout vrclient_x64
    cd vrclient_x64
    patch -Np1 < ../patches/proton-hotfixes/vrclient-use_standard_dlopen_instead_of_the_libwine_wrappers.patch
    cd ..

    # VKD3D patches
    cd vkd3d
    git reset --hard HEAD
    git clean -xdf
    cd ..

    # Valve DXVK patches
    cd dxvk
    git reset --hard HEAD
    git clean -xdf
    patch -Np1 < ../patches/dxvk/valve-dxvk-avoid-spamming-log-with-requests-for-IWineD3D11Texture2D.patch
    patch -Np1 < ../patches/dxvk/proton-add_new_dxvk_config_library.patch
    patch -Np1 < ../patches/dxvk/dxvk-async.patch
    cd ..

    #WINE STAGING
    cd wine-staging
    git reset --hard HEAD
    git clean -xdf
    
#    echo "staging unfuck 1"
#    patch -Np1 -R < ../patches/wine-hotfixes/reverts/staging/06877e55b1100cc49d3726e9a70f31c4dfbe66f8.patch
#    echo "staging unfuck 2"
#    patch -Np1 < ../patches/wine-hotfixes/reverts/staging/934a09585a15e8491e422b43624ffe632b02bd3c.patch
#    echo "staging unfuck 3"
#    patch -Np1 < ../patches/wine-hotfixes/updates/staging/ntdll-ForceBottomUpAlloc-044cb93.patch
    cd ..

    #WINE
    cd wine
    git reset --hard HEAD
    git clean -xdf

    echo "proton gamepad conflict fix"
    git revert --no-commit da7d60bf97fb8726828e57f852e8963aacde21e9

    echo "sea of thieves patch fix"
#    # these commits will eventually replace the sea of thieves patch, but are currently incomplete
    git revert --no-commit 0b48050da58be2ee72bcc5c4848822d6853d857c
    git revert --no-commit a6de059eef5e0aa4aa688885c1d91497c588576f
    git revert --no-commit a46d359e91e299142a27570bb202d8141b9625da
    git revert --no-commit 0a90d0431d8d6d2f4913cdc6640edeb1ade833c0
    git revert --no-commit 93aea5d86fe2eb50a9bb0829533ca5da627908f6

# disable these when using proton's gamepad patches
#    -W dinput-SetActionMap-genre \
#    -W dinput-axis-recalc \
#    -W dinput-joy-mappings \
#    -W dinput-reconnect-joystick \
#    -W dinput-remap-joystick \

    echo "applying staging patches"
    ../wine-staging/patches/patchinstall.sh DESTDIR="." --all \
    -W server-Desktop_Refcount \
    -W ws2_32-TransmitFile \
    -W dinput-SetActionMap-genre \
    -W dinput-axis-recalc \
    -W dinput-joy-mappings \
    -W dinput-reconnect-joystick \
    -W dinput-remap-joystick \
    -W user32-window-activation
    
    echo "SC, DOS2, PoE revert fix"
    # StarCitizen freezes on start
    # https://bugs.winehq.org/show_bug.cgi?id=49007
    # Divinity: Original Sin 2 (GOG): Doesn't start since 5.7
    # https://bugs.winehq.org/show_bug.cgi?id=49098
    # Path of Exile flickers with multithreaded renderer
    # https://bugs.winehq.org/show_bug.cgi?id=49041
    patch -Np1 < ../patches/wine-hotfixes/reverts/wine/fd7992972b252ed262d33ef604e9e1235d2108c5.patch

    echo "origin 5.11 login hang fix"
    patch -Np1 < ../patches/game-patches/origin-login-hang-fix.patch

    #WINE FAUDIO
    #echo "applying faudio patches"
    #patch -Np1 < ../patches/faudio/faudio-ffmpeg.patch
    
    ### GAME PATCH SECTION ###

    #fix this
    echo "mech warrior online"
    patch -Np1 < ../patches/game-patches/mwo.patch

    echo "final fantasy XV denuvo fix"
    patch -Np1 < ../patches/game-patches/ffxv-steam-fix.patch

    echo "final fantasy XIV old launcher render fix"
    patch -Np1 < ../patches/game-patches/ffxiv-launcher.patch

    echo "assetto corsa"
    patch -Np1 < ../patches/game-patches/assettocorsa-hud.patch

    echo "sword art online"
    patch -Np1 < ../patches/game-patches/sword-art-online-gnutls.patch

    echo "origin downloads fix" 
    patch -Np1 < ../patches/game-patches/origin-downloads_fix.patch

    echo "sea of thieves winhttp patches"
    patch -Np1 < ../patches/game-patches/sea-of-thieves-websockets.patch
#    patch -Np1 < ../patches/game-patches/0001-winhttp-Don-t-close-child-handles-on-release.patch
#    patch -Np1 < ../patches/game-patches/0002-winhttp-WinHttpWebSocketCompleteUpgrade-use-WINHTTP_.patch
#    patch -Np1 < ../patches/game-patches/0003-winhttp-Pass-length-in-WINHTTP_CALLBACK_STATUS_CONNE.patch
#    patch -Np1 < ../patches/game-patches/0004-winhttp-Implement-WinHttpWebSocketSend.patch
#    patch -Np1 < ../patches/game-patches/0005-winhttp-Implement-WinHttpWebSocketClose.patch
#    patch -Np1 < ../patches/game-patches/0006-winhttp-Convert-winsock-error-to-internet-error.patch


    echo "fix steep"
    patch -Np1 < ../patches/game-patches/steep_fix.patch

#  TODO: Add game-specific check
    echo "mk11 patch"
    patch -Np1 < ../patches/game-patches/mk11.patch

#    Disabled for now. The game uses CEG which does not work in proton.    
#    echo "blackops 2 fix"
#    patch -Np1 < ../patches/game-patches/blackops_2_fix.patch

    ### END GAME PATCH SECTION ###
    
    #PROTON
    
    echo "clock monotonic"
    patch -Np1 < ../patches/proton/proton-use_clock_monotonic.patch

    echo "amd ags"
    patch -Np1 < ../patches/proton/proton-amd_ags.patch
    
    echo "bypass compositor"
    patch -Np1 < ../patches/proton/proton-FS_bypass_compositor.patch

    echo "applying winevulkan childwindow"
    patch -Np1 < ../patches/wine-hotfixes/winevulkan-childwindow.patch

#  TODO: Esync and Fsync compatibility was broken and disabled in 5.10.
#    #WINE FSYNC
#    echo "applying fsync patches"
#    patch -Np1 < ../patches/proton/proton-fsync_staging.patch
#    patch -Np1 < ../patches/proton/proton-fsync-spincounts.patch

    echo "fix for Dark Souls III, Sekiro, Nier" 
    patch -Np1 < ../patches/game-patches/nier-nofshack.patch

    echo "LAA"
    patch -Np1 < ../patches/proton/proton-LAA_staging.patch

    echo "steamclient swap"
    patch -Np1 < ../patches/proton/proton-steamclient_swap.patch

#    disabled for now -- was breaking Catherine Classic in 5.9
#    echo "audio patch test"
#    patch -Np1 < ../patches/proton/proton-xaudio2_stop_engine.patch

    echo "protonify"
    patch -Np1 < ../patches/proton/proton-protonify_staging.patch

    echo "protonify-audio"
    patch -Np1 < ../patches/proton/proton-pa-staging.patch
    
    echo "steam bits"
    patch -Np1 < ../patches/proton/proton-steam-bits.patch

    echo "seccomp"
    patch -Np1 < ../patches/proton/proton-seccomp-envvar.patch

    echo "SDL Joystick"
    patch -Np1 < ../patches/proton/proton-sdl_joy.patch
    patch -Np1 < ../patches/proton/proton-sdl_joy_2.patch
    
    echo "proton gamepad additions"
    patch -Np1 < ../patches/proton/proton-gamepad-additions.patch

    echo "Valve VR patches"
    patch -Np1 < ../patches/proton/proton-vr.patch

    echo "Valve vulkan patches"
    patch -Np1 < ../patches/proton/proton-vk-bits-4.5-nofshack.patch

#    echo "FS Hack integer scaling"
#    patch -Np1 < ../patches/proton/proton_fs_hack_integer_scaling.patch
    
    echo "proton winevulkan"
    patch -Np1 < ../patches/proton/proton-winevulkan-nofshack.patch
    
    echo "msvcrt overrides"
    patch -Np1 < ../patches/proton/proton-msvcrt_nativebuiltin.patch

    echo "valve registry entries"
    patch -Np1 < ../patches/proton/proton-apply_LargeAddressAware_fix_for_Bayonetta.patch
    patch -Np1 < ../patches/proton/proton-Set_amd_ags_x64_to_built_in_for_Wolfenstein_2.patch
    
    echo "set prefix win10"
    patch -Np1 < ../patches/proton/proton-win10_default.patch

    echo "dxvk_config"
    patch -Np1 < ../patches/proton/proton-dxvk_config.patch

    echo "hide wine prefix update"
    patch -Np1 < ../patches/proton/proton-hide_wine_prefix_update_window.patch

    echo "applying WoW vkd3d wine patches"
    patch -Np1 < ../patches/wine-hotfixes/vkd3d/D3D12SerializeVersionedRootSignature.patch
    patch -Np1 < ../patches/wine-hotfixes/vkd3d/D3D12CreateVersionedRootSignatureDeserializer.patch
    
    echo "media foundation upstream pending"
    patch -Np1 < ../patches/wine-hotfixes/media_foundation/media_foundation_wine_pending.patch
        
    echo "guy's media foundation alpha patches"
    patch -Np1 < ../patches/wine-hotfixes/media_foundation/media_foundation_alpha.patch
    
    echo "proton-specific manual mfplat dll register patch"
    patch -Np1 < ../patches/wine-hotfixes/media_foundation/proton_mediafoundation_dllreg.patch
    
    #WINE CUSTOM PATCHES
    #add your own custom patch lines below
    
    echo "Paul's Diablo 1 menu fix"
    patch -Np1 < ../patches/game-patches/diablo_1_menu.patch
    
    
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    #end
