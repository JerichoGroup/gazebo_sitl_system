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

WORKDIR /home/${NEW_USER}/humble_ws/src

RUN vcs import --recursive < .repos

RUN sudo apt-get update && \
    pip3 install pexpect future mavproxy

# Compile ardupilot sitl...
RUN cd ardupilot && \
    ./waf distclean && \
    ./waf configure --board sitl && \
    ./waf copter

# Install ardupilot gazebo apt depndencies.
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
    gstreamer1.0-gl

# Install ardupilot gazebo...
RUN cd ardupilot_gazebo && \
    export GZ_VERSION=garden && \
    sudo bash -c 'wget https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list -O /etc/ros/rosdep/sources.list.d/00-gazebo.list' && \
    rosdep update && \
    rosdep resolve gz-garden && \
    rosdep install --from-paths src --ignore-src -y && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    sudo ln -s /usr/bin/python3 /usr/bin/python && \
    echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=/home/ros2/humble_ws/src/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> ~/.bashrc && \
    echo 'export GZ_SIM_RESOURCE_PATH=/home/ros2/humble_ws/src/ardupilot_gazebo/models:/home/ros2/humble_ws/src/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> ~/.bashrc

# Install mavros
RUN sudo apt-get install -y --no-install-recommends \
    ros-humble-mavros  \
    ros-humble-mavros-msgs \
    ros-humble-libmavconn \
    python3-vcstool \
    python3-rosinstall-generator \
    python3-osrf-pycommon && \
    wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh && \
    chmod a+x install_geographiclib_datasets.sh && \
    sudo ./install_geographiclib_datasets.sh && \
    rosinstall_generator --format repos mavlink | tee /tmp/mavlink.repos && \
    rosinstall_generator --format repos --upstream mavros | tee -a /tmp/mavros.repos && \
    cd .. && \
    vcs import src < /tmp/mavlink.repos && \
    cd src/mavlink && \
    git switch -c 2024.6.6-1 && \
    cd ../../ && \
    vcs import src < /tmp/mavros.repos && \
    cd src/mavros && \
    git switch -c 2.8.0 && \
    cd ../../ && \
    rosdep install --from-paths src --ignore-src -y && \
    sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh && \
    export ROS_PYTHON_VERSION=3 && \
    source /opt/ros/humble/setup.bash && \
    colcon build --packages-select mavlink && \
    colcon build --packages-select mavros   
