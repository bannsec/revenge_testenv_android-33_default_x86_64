FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt QEMU_AUDIO_DRV=none TOOLS=${ANDROID_HOME}/tools
ENV PATH=${ANDROID_HOME}:${ANDROID_HOME}/emulator:${TOOLS}:${TOOLS}/bin:${ANDROID_HOME}/platform-tools:${PATH} 
ENV PATH=/opt/cmdline-tools/latest/bin:${PATH}
ENV QTWEBENGINE_DISABLE_SANDBOX=1

RUN apt update && apt dist-upgrade -y && \
    apt install -y qemu-system curl openjdk-19-jre unzip xauth x11-apps && \
    SDKURL=`curl -s https://developer.android.com/studio | grep --color=never -Eo "http.*commandlinetools-linux.*\.zip"` && \
    mkdir -p /opt && cd /opt && curl -s $SDKURL > android_sdk.zip && unzip android_sdk.zip && rm android_sdk.zip && \
    mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
    mkdir /opt/cmdline-tools/latest && cp -r /opt/cmdline-tools/. /opt/cmdline-tools/latest/. ; \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager --update >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "platform-tools" >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "tools" >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "build-tools;33.0.0" >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "platforms;android-33" >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "emulator" >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "extras;android;m2repository"  >/dev/null && \
    echo y | /opt/cmdline-tools/latest/bin/sdkmanager "system-images;android-33;google_apis;x86_64" >/dev/null && \
    echo no | /opt/cmdline-tools/latest/bin/avdmanager create avd --force --name test --package 'system-images;android-33;google_apis;x86_64' && \
    echo hw.keyboard=yes >> /root/.android/avd/test.avd/config.ini && \
    echo hw.dPad=yes >> /root/.android/avd/test.avd/config.ini && \
    echo hw.mainKeys=yes >> /root/.android/avd/test.avd/config.ini && \
    echo fastboot.forceColdBoot=yes >> /root/.android/avd/test.avd/config.ini && \
    echo hw.gpu.enabled=yes >> /root/.android/avd/test.avd/config.ini && \
    echo hw.gpu.mode=swiftshader_indirect >> /root/.android/avd/test.avd/config.ini

CMD ["/opt/emulator/emulator", "-memory", "3072", "-writable-system", "@test"]

# sudo docker run -it --rm --network host --privileged -v /tmp/.X11-unix/:/tmp/.X11-unix/ -e DISPLAY=$DISPLAY -v $HOME/.Xauthority:/root/.Xauthority bannsec/revenge_testenv_android-33_default_x86_64
