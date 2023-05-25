#!/bin/bash
echo 'LeOS-20 buildbot'
echo 'init'
#repo init -u https://android.googlesource.com/platform/manifest -b android-13.0.0_r3
repo init -u https://android.googlesource.com/platform/manifest -b
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0

cp LeOS/iode.xml .repo/local_manifests
cp LeOS/manifest.xml .repo/local_manifests

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
cd system/vold/
git clone https://github.com/relan/exfat.git
cd ../..

bash lineage_build_unified/buildbot_unified.sh treble 64GX

bash patches/apply.sh leos-20
bash patches/apply.sh divest

echo 'Bootanimation'
cp /home/ich/Schreibtisch/leos-s-changes/android-logo-mask1a.png frameworks/base/core/res/assets/images/android-logo-mask.png
cp /home/ich/Schreibtisch/leos-s-changes/android-logo-shine.png frameworks/base/core/res/assets/images/android-logo-shine.png
cp LeOS/bootanimation.tar vendor/lineage/bootanimation

echo 'background'
cp /home/ich/Schreibtisch/leos-s-changes/default_wallpaper.png frameworks/base/core/res/res/drawable-nodpi/default_wallpaper.png
cp /home/ich/Schreibtisch/leos-s-changes/default_wallpaper.png frameworks/base/core/res/res/drawable-sw600dp-nodpi/default_wallpaper.png
cp /home/ich/Schreibtisch/leos-s-changes/default_wallpaper.png frameworks/base/core/res/res/drawable-sw720dp-nodpi/default_wallpaper.png
cp /home/ich/Schreibtisch/leos-s-changes/default_wallpaper.png frameworks/base/tests/HwAccelerationTest/res/drawable/default_wallpaper.png

echo 'Fonts'
cp -R /home/ich/Schreibtisch/aosp18changes/roboto-fonts external/
cp /home/ich/Schreibtisch/leos-s-changes/Roboto-Black.ttf external/roboto-fonts/

echo 'remove apps and files'
rm -R packages/apps/Browser2
rm -R packages/apps/AudioFX
rm -R packages/apps/Eleven
rm -R packages/apps/Etar
rm -R packages/apps/ExactCalculator
rm -R packages/apps/Jelly
rm -R packages/apps/Recorder
rm -R packages/apps/Calendar
rm -R packages/apps/Camera2
rm -R packages/apps/DeskClock
rm -R packages/apps/DevCamera
rm -R packages/apps/Dialer
rm -R packages/apps/Gallery
rm -R packages/apps/Gallery2
rm -R packages/apps/HTMLViewer
rm -R packages/apps/LegacyCamera
rm -R packages/apps/Messaging
rm -R packages/apps/Music
rm -R packages//MusicFX
rm -R packages/apps/UniversalMediaPlayer
rm -R packages/apps/QuickSearchBox
rm -R packages/overlays/Lineage/fonts
rm -R packages/apps/Aperture
rm -R frameworks/base/packages/EasterEgg
rm -R packages/overlays/Lineage/icons/

echo 'webview'
tar -xf LeOS/bromite-webview.tar.xz -C external
cd external/bromite-webview
bash update.sh
cd ../..
mv external/bromite-webview/prebuilt/arm/SystemWebView.apk external/chromium-webview/prebuilt/arm/webview.apk
mv external/bromite-webview/prebuilt/arm64/SystemWebView.apk external/chromium-webview/prebuilt/arm64/webview.apk
rm -R external/bromite-webview/


# hosts
cp LeOS/hosts system/core/rootdir/etc/

echo'LOS stats'
rm packages/apps/LineageParts/res/xml/anonymous_stats.xml
rm packages/apps/LineageParts/res/xml/preview_data.xml
rm -R packages/apps/LineageParts/src/org/lineageos/lineageparts/lineagestats/


rm -R vendor/lineage/overlay/common/frameworks/base/core/res/res/drawable*

echo "patch vendor_overlay"
cp LeOS/vendor_hardware_overlay.patch vendor/hardware_overlay
cd vendor/hardware_overlay
git apply *.patch
cd ../..

echo 'LeOS apps'
mkdir prebuilts/prebuiltapks
tar -xf /home/ich/Schreibtisch/leos-s-changes/prebuiltapks-jan.tar.xz -C prebuilts/
cd prebuilts/prebuiltapks/foss_nano
bash updateS.sh
cd ../../..

## new
rm -R packages/inputmethods/LatinIME/
tar -xf LeOS/LatinIME-20TD.tar.xz -C packages/inputmethods/

echo 'firebase mods'
cp LeOS/firebase-messaging-21.0.1.aar external/firebase-messaging/libs/
cp LeOS/play-services-cloud-messaging-16.0.0.aar external/firebase-messaging/libs/

echo "Patches"
cp /home/ich/Schreibtisch/leos-t-changes/patches/platform_testing.patch platform_testing
cd platform_testing
git apply *.patch
cd ..

cp patches/texte.txt ./texte.sh
bash texte.sh
mkdir images

bash all.sh

#### only need if divest patches failing
#echo 'not sure'
#rm -R packages/apps/QcRilAm/

#echo 'Settings New File'
#cp LeOS/ConnectivityCheckPreferenceController.java packages/apps/Settings/src/com/android/settings/network/
#cp LeOS/HostsPreferenceController.java packages/apps/Settings/src/com/android/settings/security/

#echo 'bionic'
#cp LeOS/hosts_cache.c bionic/libc/dns/net/hosts_cache.c
#cp LeOS/hosts_cache.h bionic/libc/dns/net/hosts_cache.h

#echo 'packages/modules/DnsResolver'
#cp LeOS/DnsResolver_hosts_cache.h packages/modules/DnsResolver/hosts_cache.h
#cp LeOS/DnsResolver_hosts_cache.cpp packages/modules/DnsResolver/hosts_cache.cpp

#echo 'packages/apps/Settings/src/com/android/settings/network/'
#cp LeOS/ConnectivityCheckPreferenceController.java packages/apps/Settings/src/com/android/settings/network/

#### not needed ##############
#echo 'LeOSize'
#cp LeOS/LineageParts_LeOSize.sh packages/apps/LineageParts/
#cd packages/apps/LineageParts/
#bash LineageParts_LeOSize.sh
#cd ../../..

#cp LeOS/lineage-sdk_LeOSize.sh lineage-sdk
#cd lineage-sdk
#bash lineage-sdk_LeOSize.sh
#cd ..

#tar -xf /home/ich/Schreibtisch/leos-t-changes/apply_patches.tar.xz
#rm -R frameworks/base/core/java/com/android/internal/gmscompat/AttestationHooks.java
# rm -R packages/apps/QcRilAm

#rm -r packages/apps/SettingsIntelligence/
#rm -r packages/apps/Car/SettingsIntelligence/

#rm -R packages/apps/ImsServiceEntitlement/src/com/android/imsserviceentitlement/fcm
#rm device/phh/treble/phh.mk
