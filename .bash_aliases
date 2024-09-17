alias a=alias
alias h=history
alias j=jobs
alias d=date
alias rm='rm -i'
alias ver='lsb_release -a'
alias path='(IFS=:;ls -1d $PATH |  nl)'
alias dom="printenv | grep ROS_DOMAIN_ID"

# Allow core dump
ulimit -c unlimited

HUMBLE_WS_PATH="${HOME}/humble_ws"

export EDITOR='vi'
export FASTRTPS_DEFAULT_PROFILES_FILE="${HUMBLE_WS_PATH}/fastdds.xml"
export RUNGAZ=$(which gazebo)
export ROS_DOMAIN_ID=13
export LANG=en_US.UTF-8
alias oy="cd ${HUMBLE_WS_PATH}/;source install/setup.bash;cd -"
export PATH=$PATH:${HOME}/.local/bin:${HUMBLE_WS_PATH}/Micro-XRCE-DDS-Gen/scripts
export APS=${HUMBLE_WS_PATH}/install/ardupilot_sitl/share/ardupilot_sitl

source ~/.ardupilot_env
source ~/.gazenv
source /opt/ros/humble/setup.bash
source "${HUMBLE_WS_PATH}/install/setup.bash" || echo "${HUMBLE_WS_PATH}/install/setup.bash file doesn't exists !"
