FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-ic"]

#installing dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    zip \
    wget \
    xorg \
    unzip \
    xauth \
    openbox \
    mono-devel \
    xserver-xorg-video-fbdev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /Mission-Planner && \
    cd /Mission-Planner && \
    wget https://firmware.ardupilot.org/Tools/MissionPlanner/archive/MissionPlanner-1.3.75.zip && \
    unzip MissionPlanner-1.3.75.zip -d MissionPlanner

WORKDIR /Mission-Planner/MissionPlanner

CMD mono MissionPlanner.exe
