FROM ubuntu:22.04

ARG QT_VERSION=6.8.1
ARG QT_MODULES="qtcharts qtlocation qtpositioning qtspeech qt5compat qtmultimedia qtserialport qtimageformats qtshadertools qtconnectivity qtquick3d qtsensors"

ENV DEBIAN_FRONTEND noninteractive

ENV DISPLAY :99

ENV QT_PATH /opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64

ENV PATH /usr/lib/ccache:$QT_DESKTOP/bin:$PATH

COPY ./qgroundcontrol/install-dependencies-debian.sh /tmp/qt/
RUN /tmp/qt/install-dependencies-debian.sh

COPY ./qgroundcontrol/install-qt-debian.sh /tmp/qt/
RUN /tmp/qt/install-qt-debian.sh

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

ARG NEW_USER=user
RUN groupadd -r ${NEW_USER} && \
    useradd -r -m -g ${NEW_USER} -s /bin/bash ${NEW_USER} && \
    mkdir -p /etc/sudoers.d/ && \
    touch /etc/sudoers.d/${NEW_USER} && \
    echo "${NEW_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NEW_USER}
USER ${NEW_USER}

WORKDIR /home/${NEW_USER}
RUN wget -O QGroundControl.AppImage https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage && \
    chmod +x QGroundControl.AppImage

CMD "./QGroundControl.AppImage"
