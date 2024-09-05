FROM ros:humble-ros-base-jammy

ENV DEBIAN_FRONTEND=noninteractive

# Install basic apt dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Gazebo Garden.
RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get install gz-garden && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ardupilot_ros
RUN mkdir -p $HOME/humble_ws/src && \
    cd $HOME/humble_ws && \
    git clone git@github.com:ardupilot/ardupilot_ros.git src && \
    rosdep install --from-paths src --ignore-src -r && \
    source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build && \
    source /root/humble_ws/install/setup.bash && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> $HOME/.bashrc && \
    echo "source /root/humble_ws/install/setup.bash" >> $HOME/.bashrc

WORKDIR $HOME/humble_ws

# Install ardupilot_gazebo plugin apt dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgz-sim7-dev \
    rapidjson-dev \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-gl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ardupilot_gazebo plugin rosdep dependencies.
RUN export GZ_VERSION=garden && \
    echo "export GZ_VERSION=garden" >> /root/.bashrc && \
    bash -c 'wget https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list -O /etc/ros/rosdep/sources.list.d/00-gazebo.list'  && \
    rosdep update && \
    rosdep resolve gz-garden && \
    rosdep install --from-paths src --ignore-src -y

# Install ardupilot_gazebo plugin.
RUN cd $HOME && \
    git clone https://github.com/ArduPilot/ardupilot_gazebo.git && \
    cd ardupilot_gazebo && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j4 && \
    echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> $HOME/.bashrc && \
    echo 'export GZ_SIM_RESOURCE_PATH=$HOME/ardupilot_gazebo/models:$HOME/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> $HOME/.bashrc

