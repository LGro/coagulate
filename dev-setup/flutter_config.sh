#!/bin/bash
#
# Run this if you regenerate and need to reconfigure platform specific make system project files
#
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPTDIR/_script_common

# iOS: Set deployment target
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [^;]*/IPHONEOS_DEPLOYMENT_TARGET = 12.4/g' $VEILIDCHATDIR/ios/Runner.xcodeproj/project.pbxproj
sed -i '' "s/platform :ios, '[^']*'/platform :ios, '12.4'/g" $VEILIDCHATDIR/ios/Podfile

# MacOS: Set deployment target
sed -i '' 's/MACOSX_DEPLOYMENT_TARGET = [^;]*/MACOSX_DEPLOYMENT_TARGET = 10.14.6/g' $VEILIDCHATDIR/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/platform :osx, '[^']*'/platform :osx, '10.14.6'/g" $VEILIDCHATDIR/macos/Podfile

# Android: Set NDK version
if [[ "$TMPDIR" != "" ]]; then 
    ANDTMP=$TMPDIR/andtmp_$(date +%s)
else 
    ANDTMP=/tmp/andtmp_$(date +%s)
fi
cat <<EOF > $ANDTMP
    ndkVersion '25.1.8937393'
EOF
sed -i '' -e "/android {/r $ANDTMP" $VEILIDCHATDIR/android/app/build.gradle
rm -- $ANDTMP

# Android: Set min sdk version
sed -i '' 's/minSdkVersion .*/minSdkVersion Math.max(flutter.minSdkVersion, 24)/g' $VEILIDCHATDIR/android/app/build.gradle

# Android: Set gradle plugin version
sed -i '' "s/classpath \'com.android.tools.build:gradle:[^\']*\'/classpath 'com.android.tools.build:gradle:7.2.0'/g" $VEILIDCHATDIR/android/build.gradle

# Android: Set gradle version
sed -i '' 's/distributionUrl=.*/distributionUrl=https:\/\/services.gradle.org\/distributions\/gradle-7.3.3-all.zip/g' $VEILIDCHATDIR/android/gradle/wrapper/gradle-wrapper.properties
