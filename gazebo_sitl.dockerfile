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
    apt-get install gz-garden \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ardupilot_ros
RUN mkdir -p /root/humble_ws/src && \
    cd /root/humble_ws && \
    git clone git@github.com:ardupilot/ardupilot_ros.git src && \
    rosdep install --from-paths src --ignore-src -r && \
    source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build && \
    source /root/humble_ws/install/setup.bash && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
    echo "source /root/humble_ws/install/setup.bash" >> /root/.bashrc
