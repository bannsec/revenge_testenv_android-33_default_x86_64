FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt QEMU_AUDIO_DRV=none TOOLS=${ANDROID_HOME}/tools
ENV PATH=${ANDROID_HOME}:${ANDROID_HOME}/emulator:${TOOLS}:${TOOLS}/bin:${ANDROID_HOME}/platform-tools:${PATH} 
ENV QTWEBENGINE_DISABLE_SANDBOX=1

RUN apt update && apt dist-upgrade -y && \
    apt install -y qemu-system curl openjdk-19-jre unzip xauth x11-apps && \
    SDKURL=`curl -s https://developer.android.com/studio | grep --color=never -Eo "http.*commandlinetools-linux.*\.zip"` && \
    mkdir -p /opt && cd /opt && curl -s $SDKURL > android_sdk.zip && unzip android_sdk.zip && rm android_sdk.zip && \
    mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "tools" >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;33.0.0" >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-33" >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --channel=4 "emulator" >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;android;m2repository"  >/dev/null && \
    echo y | /opt/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "system-images;android-33;google_apis_playstore;x86_64" >/dev/null && \
    echo no | /opt/cmdline-tools/bin/avdmanager create avd --force --name test --package 'system-images;android-33;google_apis_playstore;x86_64' && \
    echo hw.keyboard=yes >> /root/.android/avd/test.avd/config.ini && \
    echo hw.dPad=yes >> /root/.android/avd/test.avd/config.ini && \
    echo hw.mainKeys=yes >> /root/.android/avd/test.avd/config.ini

CMD ["/opt/emulator/emulator", "@test"]

# sudo docker run -it --rm --network host --privileged -v /tmp/.X11-unix/:/tmp/.X11-unix/ -e DISPLAY=$DISPLAY -v $HOME/.Xauthority:/root/.Xauthority bannsec/revenge_testenv_android-33_default_x86_64
