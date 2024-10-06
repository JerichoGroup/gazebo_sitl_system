FROM ubuntu:18.04

ARG COPTER_TAG=Copter-4.0.5

#installing and updating git
RUN apt-get update && apt-get install -y git; git config --global url."https://github.com/".insteadOf git://github.com/ \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

#cloning the ardupilot repository
RUN git clone https://github.com/ArduPilot/ardupilot.git ardupilot
WORKDIR /ardupilot

RUN git checkout ${COPTER_TAG}
RUN git submodule update --init --recursive

ENV DEBIAN_FRONTEND=noninteractive

#installing dependencies and configuration
RUN apt-get update && apt-get install -y sudo lsb-release tzdata \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN USER=nobody Tools/environment_install/install-prereqs-ubuntu.sh -y

RUN ./waf distclean
RUN ./waf configure --board sitl
RUN ./waf copter

EXPOSE 5760/tcp

RUN echo 'export PATH=$PATH:/root/.local/bin' >> ~/.bashrc
RUN pip install mavproxy==1.8.16

#launching the arducopter
ENTRYPOINT /ardupilot/Tools/autotest/sim_vehicle.py -v ArduCopter -f gazebo-iris -m --map --console