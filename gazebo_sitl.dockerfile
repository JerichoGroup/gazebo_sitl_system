FROM osrf/ros:humble-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-lc"]

# Create and switch to new user.
ARG NEW_USER=ros2
RUN groupadd -r ${NEW_USER} && \
    useradd -r -m -g ${NEW_USER} -s /bin/bash ${NEW_USER} && \
    echo "ros2 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NEW_USER}
USER ${NEW_USER}

# Install basic apt dependencies.
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    curl \
    wget \
    pip \
    gnupg \
    cmake \
    pkg-config \
    lsb-release \
    build-essential \
    python3-vcstools \
    python3-colcon-common-extensions \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Gazebo Garden.
RUN sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    gz-garden && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install apt Gazebo dependencies.
#RUN sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
#    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
#    sudo apt-get update && \
#    sudo apt-get install -y \
#      $(sort -u $(find . -iname 'packages-'`lsb_release -cs`'.apt' -o -iname 'packages.apt' | grep -v '/\.git/') | sed '/gz\|sdf/d' | tr '\n' ' ')

# Install Micro-XRCE-DDS-Gen.
RUN cd ~ && \
    git clone https://github.com/eProsima/Micro-XRCE-DDS-Gen.git && \
    cd Micro-XRCE-DDS-Gen && \
    git submodule init && \
    git submodule update && \
    ./gradlew assemble

COPY --chown=${NEW_USER} humble_ws /home/${NEW_USER}/humble_ws
COPY --chown=${NEW_USER} .gazenv /home/${NEW_USER}/.gazenv
COPY --chown=${NEW_USER} .ardupilot_env /home/${NEW_USER}/.ardupilot_env
COPY --chown=${NEW_USER} .bash_aliases /home/${NEW_USER}/.bash_aliases

# Install remaining Gazebo packages from source.
#RUN source ~/.bash_aliases && \
#    cd src && \
#    curl -O https://raw.githubusercontent.com/gazebo-tooling/gazebodistro/master/collection-garden.yaml && \
#    vcs import < collection-garden.yaml
# Pro gamer move bug fix (added COMPRESSED_JPEG to PixelFormatType in image.hh).
#COPY --chown=${NEW_USER} Image.hh /home/${NEW_USER}/humble_ws/src/gz-common/graphics/include/gz/common/Image.hh
#RUN source ~/.bash_aliases && \
#    colcon build --cmake-args -DBUILD_TESTING=OFF --merge-install

# Install ardupilot.
#RUN source ~/.bash_aliases && \
#    cd src && \
#    git clone -b Copter-4.5 https://github.com/ArduPilot/ardupilot.git && \
#    vcs import --recursive < ros2.repos.adjusted && \
#    sudo apt update && \
#    rosdep update && \
#    cd .. && \
#    rosdep install -y --from-paths src --ignore-src -r && \
#    colcon build --packages-up-to ardupilot_dds_tests
#
## Install ardupilot_gazebo & ardupilot_gz & SITL_Models & ros_gz & sdformat_urdf.

WORKDIR /home/${NEW_USER}/humble_ws/src

RUN wget https://raw.githubusercontent.com/ArduPilot/ardupilot_gz/main/ros2_gz.repos && \
    vcs import --recursive < ros2_gz.repos
    # sudo apt update && \
    # rosdep update
    # cd .. && \
    # rosdep install --rosdistro humble --from-paths src -i -r -y
#     # colcon build --cmake-args -DBUILD_TESTING=ON


## Install ardupilot_gazebo & ardupilot_gz & SITL_Models & ros_gz & sdformat_urdf. - Roi
RUN pip3 install pexpect future mavproxy

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    libgz-sim7-dev \
    rapidjson-dev \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    python3-wxgtk4.0 \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-gl && \
    cd ardupilot_gazebo && \
    export GZ_VERSION=garden && \
    sudo bash -c 'wget https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list -O /etc/ros/rosdep/sources.list.d/00-gazebo.list' && \
    rosdep update && \
    rosdep resolve gz-garden && \
    rosdep install --from-paths src --ignore-src -y && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make && \
    sudo ln -s /usr/bin/python3 /usr/bin/python && \
    echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=/home/ros2/humble_ws/src/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> ~/.bashrc && \
    echo 'export GZ_SIM_RESOURCE_PATH=/home/ros2/humble_ws/src/ardupilot_gazebo/models:/home/ros2/humble_ws/src/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> ~/.bashrc


# WORKDIR /home/${NEW_USER}/humble_ws



## Install ardupilot_gazebo plugin apt dependencies.
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    libgz-sim7-dev \
#    rapidjson-dev \
#    libopencv-dev \
#    libgstreamer1.0-dev \
#    libgstreamer-plugins-base1.0-dev \
#    gstreamer1.0-plugins-bad \
#    gstreamer1.0-libav \
#    gstreamer1.0-gl \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/*
#
## Install ardupilot_gazebo plugin rosdep dependencies.
#RUN export GZ_VERSION=garden && \
#    echo "export GZ_VERSION=garden" >> /root/.bashrc && \
#    bash -c 'wget https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list -O /etc/ros/rosdep/sources.list.d/00-gazebo.list'  && \
#    rosdep update && \
#    rosdep resolve gz-garden && \
#    rosdep install --from-paths src --ignore-src -y
#
## Install ardupilot_gazebo plugin.
#RUN cd $HOME && \
#    git clone https://github.com/ArduPilot/ardupilot_gazebo.git && \
#    cd ardupilot_gazebo && \
#    mkdir build && \
#    cd build && \
#    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
#    make -j4 && \
#    echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> $HOME/.bashrc && \
#    echo 'export GZ_SIM_RESOURCE_PATH=$HOME/ardupilot_gazebo/models:$HOME/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> $HOME/.bashrc
#
