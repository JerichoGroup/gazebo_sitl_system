# SAGA Omniverse, Gazebo, ROS1 and ROS2

## Prehistoric
### Start
Image original:ros:humble-perception-jammy
Image modified:apt install ros-humble-vision-msgs (request for ROS2 Bridge omniverse)
Changement of cap:
docker pull osrf/ros:humble-desktop-full
Image modified:apt install ros-humble-vision-msgs (request for ROS2 Bridge omniverse)

### Then

On host and docker
locale
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
locale
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install ros-humble-desktop
sudo apt install ros-dev-tools
sudo apt autoremove￼￼
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp talker
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp listener

sudo apt install ros-humble-vision-msgs

sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
sudo apt install python3-colcon-common-extensions
cd humble_ws
 rosdep install -i --from-path src --rosdistro humble
 rosdep update
 
 apt install vim
 sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
 git clone -b humble-devel https://github.com/ROBOTIS-GIT/turtlebot3.git turtlebot3

### In the docker

export LANG=en_US.UTF-8
apt update
apt install ros-humble-desktop
apt install ros-dev-tools
Term 1: cd humble_ws; source install/setup.bash;ros2 run demo_nodes_cpp talker
Term 2: cd humble_ws; source install/setup.bash;ros2 run demo_nodes_cpp listener
apt install ros-humble-vision-msgs
apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
apt install python3-colcon-common-extensions
cd humble_ws
 rosdep install -i --from-path src --rosdistro humble
 rosdep update

**./omniverse-launcher-linux.AppImage
**
Ardupilot ROS2: IN CONTAINER
==> DDS dependencies:
git clone https://github.com/eProsima/Micro-XRCE-DDS-Gen.git
cd Micro-XRCE-DDS-Gen
git submodule init
git submodule update
./gradlew assemble
./scripts/microxrceddsgen -help ==> should be valid

#### Add this to ~/.bash_aliases

```export PATH=$PATH:/colcon_ws/Micro-XRCE-DDS-Gen/scripts
cd /path/to/ardupilot
microxrceddsgen -version```

Install again ardupilot for ROS2 environment: IN HOST
Previous ardupilot to ardupilot_ros1
On the host and not on the docker because user in docker is root and :
```
---------- Tools/environment_install/install-prereqs-ubuntu.sh start ----------
+ '[' 0 == 0 ']'
+ echo 'Please do not run this script as root; don'\''t sudo it!'
Please do not run this script as root; don't sudo it!
+ exit 1 ```

#### NOTE

According ardupilot instruction, we have to run the following script:
Tools/environment_install/install-prereqs-ubuntu.sh -y

One of the result is adding to ~/.profile the following entry:
export PATH=/home/user/IsaacSim-ros_workspaces/ardupilot/Tools/autotest:$PATH
or for ROS1, I created another directory:
export PATH=/home/user/IsaacSim-ros_workspaces/ardupilot_ros1/Tools/autotest:$PATH

In bash_aliases, there is a setup of the ardupilot environment variables

Reading furthermore the ardupilot ros2 page, I decided to add an additonal
sudoer user to the ros2 docker and to install ardupilot there.

Add user in CONTAINER:
adduser ros2 passwd qwer1234
usermod -aG sudo ros2
copy ~root/.bash_aliases ~ros2/.bash_aliases
>su - ros2
>run Tools/environment_install/install-prereqs-ubuntu.sh -y
Installed also toolchain for pixhawk. May be shouldn't have/

Save docker, exit and re-run as user ros2 (passwd qwer1234).
Test: "./scripts/microxrceddsgen -help" was valid

Rerun install of ardupilot:
>run Tools/environment_install/install-prereqs-ubuntu.sh -y

### START INSTALLING ROS@ FOR ARDUPILOT IN CONTAINER AS USER ROS2:

cd /colcon_ws/humble_ws/src
wget https://raw.githubusercontent.com/ArduPilot/ardupilot/master/Tools/ros2/ros2.repos
vcs import --recursive < ros2.repos
==> It seems that it brought ardupilot again....
cd /colcon_ws/humble_ws
sudo apt update
rosdep update
rosdep install --from-paths src --ignore-src
colcon build --packages-up-to ardupilot_dds_tests

Problems: Not all submodules are here.
sudo apt install tree
sudo apt install git-all
pip install -U MAVProxy


Got problems with colcon build:
1. Submodules problems:
    - the submodules: DroneCAN/libcanard, DroneCAN/dronecan_dsdlc/
, Micro-XRCE-DDS-Client, Micro-CDR were not updated properly
    - for each one of them, 
        1. Got to the directory
        2. git checkout origin/master
        3. git switch -
2. Problem with mavlink submodule: 
"Submodule mavlink not updated: non-fastforward"
    1. I installed: pip install -U MAVProxy ==> didn't help

After several interations: it is clear that master is not the right branch to update.
I changed the ardupilot version to Copter-4.5
I could build the ardupilot_dds_tests but when running them there are 4 failures:
ros2@user-Precision-3660:/colcon_ws/humble_ws$ colcon test-result --all --verbose
build/ardupilot_dds_tests/pytest.xml: 7 tests, 0 errors, 4 failures, 0 skipped
- ardupilot_dds_tests.test.ardupilot_dds_tests.test_navsat_msg_received test_dds_serial_navsat_msg_recv
  <<< failure message
    AssertionError: Did not receive 'ap/navsat/navsat0' msgs.
    assert False
  >>>
- ardupilot_dds_tests.test.ardupilot_dds_tests.test_navsat_msg_received test_dds_udp_navsat_msg_recv
  <<< failure message
    AssertionError: Did not receive 'ap/navsat/navsat0' msgs.
    assert False
  >>>
- ardupilot_dds_tests.test.ardupilot_dds_tests.test_time_msg_received test_dds_serial_time_msg_recv
  <<< failure message
    AssertionError: Did not receive 'ROS_Time' msgs.
    assert False
  >>>
- ardupilot_dds_tests.test.ardupilot_dds_tests.test_time_msg_received test_dds_udp_time_msg_recv
  <<< failure message
    AssertionError: Did not receive 'ROS_Time' msgs.
    assert False
  >>>

The roslog of the tests: colcon test --packages-select ardupilot_dds_tests
is : ardupilot_dds_tests.log under /colcon_ws/humble_ws/src

### SITL with ROS2

mavproxy.py is in $HOME/.local/bin
The path should be:
            1	/bin
            2	/colcon_ws/Micro-XRCE-DDS-Gen/scripts
            3	/colcon_ws/humble_ws/src/ardupilot/Tools/autotest
            4	/home/ros2/.local/bin
            5	/opt/gcc-arm-none-eabi-10-2020-q4-major/bin
            6	/opt/ros/humble/bin
            7	/sbin
            8	/usr/bin
            9	/usr/lib/ccache
            10	/usr/local/bin
            11	/usr/local/sbin
            12	/usr/sbin


ros2 launch ardupilot_sitl sitl_dds_udp.launch.py transport:=udp4 refs:=$(ros2 pkg prefix ardupilot_sitl)/share/ardupilot_sitl/config/dds_xrce_profile.xml \
    synthetic_clock:=True wipe:=False model:=quad speedup:=1 slave:=0 instance:=0 \
    defaults:=$(ros2 pkg prefix ardupilot_sitl)/share/ardupilot_sitl/config/default_params/copter.parm,$(ros2 pkg prefix ardupilot_sitl)/share/ardupilot_sitl/config/default_params/dds_udp.parm sim_address:=127.0.0.1 master:=tcp:127.0.0.1:5760 sitl:=127.0.0.1:5501
ros2 launch ardupilot_sitl sitl_dds_udp.launch.py transport:=udp4 refs:=/colcon_ws/humble_ws/install/ardupilot_sitl/share/ardupilot_sitl/config/dds_xrce_profile.xml \
    synthetic_clock:=True wipe:=False model:=quad speedup:=1 slave:=0 instance:=0 \
    defaults:=/colcon_ws/humble_ws/install/ardupilot_sitl/share/ardupilot_sitl/config/default_params/copter.parm,/colcon_ws/humble_ws/install/ardupilot_sitl/share/ardupilot_sitl/config/default_params/dds_udp.parm sim_address:=127.0.0.1 master:=tcp:127.0.0.1:5760 sitl:=127.0.0.1:5501
or from /colcon_ws/humble_ws:
ros2 launch ardupilot_sitl sitl_dds_udp.launch.py transport:=udp4 refs:=install/ardupilot_sitl/share/ardupilot_sitl/config/dds_xrce_profile.xml \
    synthetic_clock:=True wipe:=False model:=quad speedup:=1 slave:=0 instance:=0 \
    defaults:=install/ardupilot_sitl/share/ardupilot_sitl/config/default_params/copter.parm,install/ardupilot_sitl/share/ardupilot_sitl/config/default_params/dds_udp.parm sim_address:=127.0.0.1 master:=tcp:127.0.0.1:5760 sitl:=127.0.0.1:5501

export APS=/colcon_ws/humble_ws/install/ardupilot_sitl/share/ardupilot_sitl
ros2 launch ardupilot_sitl sitl_dds_udp.launch.py transport:=udp4 refs:=$APS/config/dds_xrce_profile.xml \
    synthetic_clock:=True wipe:=False model:=quad speedup:=1 slave:=0 instance:=0 \
    defaults:=$APS/config/default_params/copter.parm,$APS/config/default_params/dds_udp.parm sim_address:=127.0.0.1 master:=tcp:127.0.0.1:5760 sitl:=127.0.0.1:5501

To fly:
mavproxy.py --console --map --aircraft test --master=:14550
In console of mavproxy:
    arm throttle ==> can fail if too early
    rc 3 1500   ==> can fail if too early
    mode LOITER ==> can fail if not heigh enough
    mode CIRCLE

## Suite of history

Install gazebo garden on the host: https://gazebosim.org/docs/harmonic/install_ubuntu
sudo apt-get update
sudo apt-get install lsb-release wget gnupg
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
sudo apt-get update
sudo apt-get install gz-harmonic

Try to install on the docker image as well.

Image rosgz:humble-harmonic

gz sim shapes.sdf -v 4
###########################################
In the docker:
ros2_gz.repos is original. Now using ros2_gz.repos.1 and vcs import --recursive < ros2_gz.repos.1
repositories:
  ardupilot:
    type: git
    url: https://github.com/ArduPilot/ardupilot.git
    version: Copter-4.5 ==> instead of master
  micro_ros_agent:
    type: git
    url: https://github.com/micro-ROS/micro-ROS-Agent.git
    version: humble
repositories:
  ardupilot_gazebo:
    type: git
    url: https://github.com/ArduPilot/ardupilot_gazebo.git
    version: ros2
  ardupilot_gz:
    type: git
    url: https://github.com/ArduPilot/ardupilot_gz.git
    version: main
  ardupilot_sitl_models:
    type: git
    url: https://github.com/ArduPilot/SITL_Models.git
    version: main
  ros_gz:
    type: git
    url: https://github.com/gazebosim/ros_gz.git
    version: humble
  sdformat_urdf:
    type: git
    url: https://github.com/ros/sdformat_urdf.git
    version: ros2

### Problems

Problems  with colcon build
sudo apt install libgz-cmake2-dev
sudo apt install libgz-cmake2-dev
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt-get update
sudo apt install libgz-cmake3-dev
sudo apt install ros-humble-ros-gz
************************************************
1.Restart fresh
2.rm -rf build log install
3.sudo apt update
4.rosdep install -r --from-paths src -i -y --rosdistro humble
==> ardupilot_gz_gazebo: Cannot locate rosdep definition for [gz-plugin2]
5.export GZ_VERSION=Harmonic
6.Compile package: ros_gz (brought by ardupilot ros2_gz):
==>colcon build --packages-select ros_gz
	[0.724s] WARNING:colcon.colcon_core.shell:The following packages are in the workspace but haven't been built:
	- ros_gz_interfaces
	- ros_gz_sim
	- ros_gz_bridge
	- sdformat_urdf
	- ros_gz_image
	- ros_gz_sim_demos
	They are being used from the following locations instead:
	- /opt/ros/humble
	- /opt/ros/humble
	- /opt/ros/humble
	- /opt/ros/humble
	- /opt/ros/humble
	- /opt/ros/humble
So, not taken from source
7. Add gazebo sources to the docker:
	sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-		stable.list'
	wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
	sudo apt-get update
8. Try again: 	rosdep install -r --from-paths src -i -y --rosdistro humble
==>ardupilot_gz_gazebo: Cannot locate rosdep definition for [gz-plugin2]
==> In https://github.com/ArduPilot/ardupilot_gz.git it is written to install gazebo garden so may be gazebo harmonic is not supported
==> I will install gazebo garden:sudo apt-get install gz-garden
export GZ_VERSION=Garden and gz sim shapes.sdf -v 4 works (in docker)
9. Try again: rosdep install -r --from-paths src -i -y --rosdistro humble
and again: ==>ardupilot_gz_gazebo: Cannot locate rosdep definition for [gz-plugin2]

## After the deluge

START FRESH
Still no gazebo installed: gz sim shapes.sdf -v 4 Not working

colcon build --packages-select ros_gz ==> usual warning, taking package from /opt/ros
export GZ_VERSION=garden
colcon build --packages-select ros_gz_interfaces ros_gz_sim ros_gz_bridge ros_gz_sim_demos ros_gz_image sdformat_urdf sdformat_test_files ==> errors
several iterations
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

====>>>>>
Try install gazebo garden from sources: https://gazebosim.org/docs/garden/install_ubuntu_src

pip install vcstool || pip3 install vcstool
pip install -U colcon-common-extensions || pip3 install -U colcon-common-extensions	

wget https://raw.githubusercontent.com/gazebo-tooling/gazebodistro/master/collection-garden.yaml
vcs import < collection-garden.yaml
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
According instructions:
==> A::cd ~/workspace/src; sudo apt -y install \
  $(sort -u $(find . -iname 'packages-'`lsb_release -cs`'.apt' -o -iname 'packages.apt' | grep -v '/\.git/') | sed '/gz\|sdf/d' | tr '\n' ' ')
Got: Couldn't find any package by glob 'libogre-next-2.3-dev'
==> B:: The following is already installed: libogre-next-dev

Then: colcon build --cmake-args -DBUILD_TESTING=OFF --merge-install
Din't work because install is isolated so:
colcon build --cmake-args -DBUILD_TESTING=OFF 
==> Problem with GzConfigureBuild
sudo apt install libfreeimage-dev
sudo apt-get install curl zip unzip tar

Now: 
1. gz_physics doesn't find gz/common/Mesh.hh
2. I moved the gz_common5 project to gz-common5_5.4.2 (to 09/23)
3. It solved this problem.

Now:
1. No RapidJSON
2. pip install python-rapidjson

==> Install RapidJSON:
1. Install: git clone https://github.com/microsoft/vcpkg
2. ./vcpkg/bootstrap-vcpkg.sh
3.sudo apt-get install curl zip unzip tar

Solution for rapidjson: copy include/rapidjson to include of ardupilot_gazebo
GZ_SIM_SYSTEM_PLUGIN_PATH=/colcon_ws/humble_ws/install/ardupilot_gazebo/lib:${GZ_SIM_SYSTEM_PLUGIN_PATH}
export GZ_SIM_RESOURCE_PATH=/colcon_ws/humble_ws/ardupilot_gazebo/share/ardupilot_gazebo/models:/colcon_ws/humble_ws/install/ardupilot_gazebo/share/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}

Re-install garden
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
sudo apt-get update
sudo apt-get install gz-garden
Problem with gz path: /colcon_ws/humble_ws/install/gz-tools2/bin/gz
And libraries:
export GZ_CONFIG_PATH=/colcon_ws/humble_ws/install/gz-cmake3/share/gz:\
/colcon_ws/humble_ws/install/gz-common5/share/gz:\
/colcon_ws/humble_ws/install/gz-fuel_tools8/share/gz:\
/colcon_ws/humble_ws/install/gz-gui7/share/gz:\
/colcon_ws/humble_ws/install/gz-launch6/share/gz:\
/colcon_ws/humble_ws/install/gz-math7/share/gz:\
/colcon_ws/humble_ws/install/gz-msgs9/share/gz:\
/colcon_ws/humble_ws/install/gz-physics6/share/gz:\
/colcon_ws/humble_ws/install/gz-plugin2/share/gz:\
/colcon_ws/humble_ws/install/gz-rendering7/share/gz:\
/colcon_ws/humble_ws/install/gz-sensors7/share/gz:\
/colcon_ws/humble_ws/install/gz-sim7/share/gz:\
/colcon_ws/humble_ws/install/gz-tools2/share/gz:\
/colcon_ws/humble_ws/install/gz-transport12/share/gz:\
/colcon_ws/humble_ws/install/gz-utils2/share/gz:\
/colcon_ws/humble_ws/install/sdformat13/share/gz


LD_LIBRARY_PATH=/colcon_ws/humble_ws/install/sdformat_urdf/lib:/colcon_ws/humble_ws/install/ros_gz_sim/lib:/colcon_ws/humble_ws/install/gz-launch6/lib:/colcon_ws/humble_ws/install/gz-sim7/lib:/colcon_ws/humble_ws/install/gz-sensors7/lib:/colcon_ws/humble_ws/install/gz-physics6/lib:/colcon_ws/humble_ws/install/sdformat13/lib:/colcon_ws/humble_ws/install/ros_ign_interfaces/lib:/colcon_ws/humble_ws/install/ros_gz_bridge/lib:/colcon_ws/humble_ws/install/ros_gz_interfaces/lib:/colcon_ws/humble_ws/install/micro_ros_agent/lib:/colcon_ws/humble_ws/install/isaac_ros2_messages/lib:/colcon_ws/humble_ws/install/gz-gui7/lib:/colcon_ws/humble_ws/install/gz-transport12/lib:/colcon_ws/humble_ws/install/gz-rendering7/lib:/colcon_ws/humble_ws/install/gz-plugin2/lib:/colcon_ws/humble_ws/install/gz-fuel_tools8/lib:/colcon_ws/humble_ws/install/gz-msgs9/lib:/colcon_ws/humble_ws/install/gz-common5/lib:/colcon_ws/humble_ws/install/gz-math7/lib:/colcon_ws/humble_ws/install/gz-utils2/lib:/colcon_ws/humble_ws/install/gz-tools2/lib:/colcon_ws/humble_ws/install/custom_message/lib:/colcon_ws/humble_ws/install/ardupilot_msgs/lib:/opt/ros/humble/opt/rviz_ogre_vendor/lib:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/colcon_ws/humble_ws/install/gz-rendering7/lib/gz-rendering-7/engine-plugins


LD_LIBRARY_PATH=/colcon_ws/humble_ws/install/sdformat_urdf/lib:/colcon_ws/humble_ws/install/ros_gz_sim/lib:/colcon_ws/humble_ws/install/gz-launch6/lib:/colcon_ws/humble_ws/install/gz-sim7/lib:/colcon_ws/humble_ws/install/gz-sensors7/lib:/colcon_ws/humble_ws/install/gz-physics6/lib:/colcon_ws/humble_ws/install/sdformat13/lib:/colcon_ws/humble_ws/install/ros_ign_interfaces/lib:/colcon_ws/humble_ws/install/ros_gz_bridge/lib:/colcon_ws/humble_ws/install/ros_gz_interfaces/lib:/colcon_ws/humble_ws/install/micro_ros_agent/lib:/colcon_ws/humble_ws/install/isaac_ros2_messages/lib:/colcon_ws/humble_ws/install/gz-gui7/lib:/colcon_ws/humble_ws/install/gz-transport12/lib:/colcon_ws/humble_ws/install/gz-rendering7/lib:/colcon_ws/humble_ws/install/gz-plugin2/lib:/colcon_ws/humble_ws/install/gz-fuel_tools8/lib:/colcon_ws/humble_ws/install/gz-msgs9/lib:/colcon_ws/humble_ws/install/gz-common5/lib:/colcon_ws/humble_ws/install/gz-math7/lib:/colcon_ws/humble_ws/install/gz-utils2/lib:/colcon_ws/humble_ws/install/gz-tools2/lib:/colcon_ws/humble_ws/install/custom_message/lib:/colcon_ws/humble_ws/install/ardupilot_msgs/lib:/opt/ros/humble/opt/rviz_ogre_vendor/lib:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib

My problem with Ogre2 is that it was not installed.
I can run gazebo with ogre by adding the following flag --render-engine ogre
For example: 
- gz sim --render-engine ogre shapes.sdf
- gz sim --render-engine ogre -r iris_runaway.sdf

Trying to install ogre2
sudo apt install mesa-utils ==> glxinfo | grep "OpenGL version" > 3.1
sudo apt install cmake libfreetype-dev libfreeimage-dev libzzip-dev libxrandr-dev libxaw7-dev
 libxt-dev freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev doxygen graphviz
git clone https://github.com/OGRECave/ogre-next.git


sudo apt-get install libfreetype6-dev libfreeimage-dev libzzip-dev libxrandr-dev libxaw7-dev freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev libx11-xcb-dev libxcb-keysyms1-dev doxygen graphviz  libsdl2-dev cmake ninja-build 
Then script: build_ogre_linux_c++latest.sh  ==> error
Try script: build_ogre_linux_c++11.sh ==> also failed 
Trying older version


rosgz image
sudo apt install ros-humble-topic-tools
ros2 launch ardupilot_gz_bringup iris_runway.launch.py ==> fails.
Gazebo is harmonic and everything compiled as garden.
Let's try to compile as harmonic.
export GZ_VERSION=Harmonic
==>--- stderr: ardupilot_gazebo
Building ardupilot_gazebo as an `ament_cmake` project.
CMake Error at CMakeLists.txt:53 (message):
  Unsupported GZ_VERSION: Harmonic
  Let's try: export GZ_VERSION=harmonic
  With little h it is better.
 Delete ogre-next
 As previously:
 ==> Problem with GzConfigureBuild
sudo apt install libfreeimage-dev
sudo apt-get nstall curl zip unzip tar


  user@user-Precision-3660:~/IsaacSim-ros_workspaces$ h | grep docker | grep pull
  125  docker pull osrf/ros:noetic-desktop-full
  223  docker pull https://github.com/biubug6/Pytorch_Retinaface.git
  224  docker pull nvcr.io/nvidia/pytorch:22.07-py3
  299  docker pull nvcr.io/nvidia/pytorch:23.01-py3
  351  docker pull atinoda/text-generation-webui
  565  docker pull osrf/ros:humble-desktop-full
  582  docker pull ros:humble-perception-jammy
  774  docker pull osrf/ros:humble-desktop-full-jammy

Now new problems with gz-common5
Now: I moved the gz_common5 project from branch gz-common5_5.4.2 (to 09/23) to gz_common5
Add COMPRESSED_JPEG to PixelFormatType in : /home/user/IsaacSim-ros_workspaces/humble_ws/src/gz-common/graphics/include/gz/common/Image.hh
Note that I had to delete build/gz-common5 in order to make colcon take the changes into account.
Everything compiled at the end.1
When running gz sim shapes.sdf then:
	I cannot find any available 'gz' command:
		* Did you install any Gazebo library?
		* Did you set the GZ_CONFIG_PATH environment variable?
		    E.g.: export GZ_CONFIG_PATH=$HOME/local/share/gz
Then source .gazenv and it opens
Also gz sim shapes.sdf -v 4 is OK.
ros2 launch ardupilot_gz_bringup iris_runway.launch.py not ok

In another window:
cd humble_ws
 which gz  ==> /usr/bin/gz
 oy
 which gz  ==> /colcon_ws/humble_ws/install/gz-tools2/bin/gz
 source .gazenv 
 gz sim shapes.sdf -v 4  ==> gazebo garden!
 export GZ_VERSION=garden
 ros2 launch ardupilot_gz_bringup iris_runway.launch.py ==> not good
 
   sudo apt update
  371  rosdep update
  372  rosdep install --from-paths src --ignore-src -r
  373  colcon build --packages-up-to ardupilot_gz_bringup
  
  Problem Error Code 5: Msg: Attempting to load a Sensor
  Looks in Internet. Find same problem reported 5 days ago and find that 
  	ros2 launch ardupilot_gz_bringup wildthumper_playpen.launch.py 
  brings rviz and gazebo but also errors. ==> gazebo version is Fortress !!!!
  I recompiled with GZ_VERSION=garden upto ardupilot_bringup and even iris opened.
  Trying to deal with libEGL warning
  sudo apt install mesa-utils  ==> sudo apt install mesa-utils
  with export LIBGL_ALWAYS_SOFTWARE=1 things looks better
  docker commit gazebo rosgz:humble-garden
  
  I succeed to fly the iris in the maze world. With QGroundControl.
  
  ```
    cd IsaacSim-ros_workspaces
    ./run_gaz.bash and ./exec_gaz.bash
    cd humble_ws
    oy
  ```

  Everything should be configured: GZ_VERSION as well as all libraries gz
    In ~/.bash_aliases: source ~/.gazenv
  
   ``` ros2 launch ardupilot_gz_bringup iris_maze.launch.py ```
  
  In host: /home/user/Downloads/QGroundControl.AppImage (outside container)
  
  #### Try cartographer
  
  ```
  git clone https://github.com/ArduPilot/ardupilot_ros.git
  ros2 launch ardupilot_gz_bringup iris_maze.launch.py
  colcon build --packages-up-to ardupilot_ros ardupilot_gz_bringup rviz:=false
  
  ros2 launch ardupilot_ros cartographer.launch.py
  mavproxy.py --console --map --aircraft test --master=:14550
  mode guided
  arm throttle
  takeoff 2.5
  velocity 1.0 0 0
  velocity 0 -1.0 0
  ```
  
  Save map:
  ```ros2 run nav2_map_server map_saver_cli ```

  Visualize map with image viewer
  
  ```
  sudo apt install less
  sudo apt install ros-humble-rqt-robot-steering
  pip install pysdf
  sudo apt install ros-humble-sdformat-urdf
  ros2 run topic_tools relay_field /ap/twist/filtered /mytwist geometry_msgs/Twist "{linear: m.twist.linear}"
  ```

```
sudo apt install lynx
sudo apt-get install ros-humble-rviz2 ros-humble-turtle-tf2-py 
sudo apt install ros-humble-tf2-ros ros-humble-tf2-tools 
sudo apt install ros-humble-turtlesim
```

# INSTALL USD-SDF Convertor

According: https://github.com/gazebosim/gz-usd

```
git clone --depth 1 -b v21.11 https://github.com/PixarAnimationStudios/USD.git
cd USD
git switch -c v21.11
sudo apt install libpyside2-dev python3-opengl cmake libglu1-mesa-dev freeglut3-dev mesa-common-dev
cd USD
python3 build_scripts/build_usd.py --build-variant release --no-tests --no-examples --no-tutorials --no-docs --no-python /colcon_ws/humble_ws/install/USD
```

Problems with file USD/pxr/base/work/singularTask.h : doesn't undertsand size_t, suggests std::size_t
When opening on the host (not container) with code, it identifies the definition of size_t.
Let's try to compile USD in the host:
1. Install dependencies 
2. build
==> same problem


# Install GPU monitoring tools

```
sudo apt install nvtop
```

GPUS for docker usage
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
==> deprecated

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get install -y nvidia-container-toolkit


On docker rosgz:humble-garden: install nvtop gpustat and pip install nvitop:
sudo apt install nvtop
pip install nvitop
sudo apt install gpustat

*******************************************
22-07-2024

1. Build USD: ```python3 build_scripts/build_usd.py --build-variant release --no-tests --no-examples --no-tutorials --no-docs --no-python /colcon_ws/humble_ws/install/USD```
2. Install on the docker: sudo apt-get install -y ptex-base
3. When building: ```colcon build --packages-skip sleepy_dragon iris_description usd```
4. Remove rclpy error when running ros2 command on lion native: ```cd /opt/ros/humble/lib; sudo mv librcl_logging_spdlog.so librcl_logging_spdlog.bak```

***************************************************
06-08-2024

0. In the docker:
   1. Install tf tools: ```sudo apt install ros-humble-tf2-tools```
   2. Remember password qwer1234
   3. Run: ```ros2 run tf2_tools view_frames```
   4. Document viewer opens the pdf
   5. Can be sort of seen in node graph in rqt
   6. Install also: ```sudo apt install ros-humble-rqt-tf-tree```
   7. Run ```rqt --clear-config``` in order to see the tf tree in the Visualization submenu.
1. Commit image: ```docker commit gazebo rosgz:humble-garden```


***************************************************
12-09-2024

# Install mavros

0. In the docker:
   1. sudo apt install ros-humble-mavros
   2. ros2 run mavros install_geographiclib_datasets.sh
   3. wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
   4. chmod a+x install_geographiclib_datasets.sh 
   5. sudo ./install_geographiclib_datasets.sh
   6. sudo apt install -y python3-vcstool python3-rosinstall-generator python3-osrf-pycommon
   7. rosinstall_generator --format repos mavlink | tee /tmp/mavlink.repos
   8. rosinstall_generator --format repos --upstream mavros | tee -a /tmp/mavros.repos
   9. vcs import src < /tmp/mavlink.repos
   10. cd src/mavlink
   11. git switch -c 2024.6.6-1
   12. cd ../../
   13. vcs import src < /tmp/mavros.repos
   14. git switch -c 2.8.0
   15. rosdep install --from-paths src --ignore-src -y
   16. sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh
   17. colcon build --packages-select mavlink
   18. colcon build --packages-select mavros
   19. colcon build --packages-skip sleepy_dragon iris_description usd
   20. source install/setup.bash
   21. ros2 launch mavros apm.launch fcu_url:=tcp://localhost gcs_url:=udp://@
   22. I run gazebo from gazebo docker and mission planner and it worked
1. docker commit gazebo-test rosgz:humble-garden-mavros
2. Change run_ros2.bash and exec_ros2.bash
```
xhost +
docker run -it --network host --rm --privileged -e DISPLAY --gpus all -w /colcon_ws/humble_ws -v ~/isaac_sim_ws:/colcon_ws -v /tmp/.X11-unix:/tmp/.X11-unix --user rosgz --name humble_garden rosgz:humble-garden-mavros bash
```

Voila!
