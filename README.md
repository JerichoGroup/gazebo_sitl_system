## 📚 About

**gazebo_sitl_system** is a linux based simulation system for launching:

- Gazebo (ignition) Garden.
- Ardupilot sitl (Copter-4.5).
- Mavros (ros2 humble).

## 📝 Build docker images

```shell
docker-compose build
```

## Requirements
1) Make sure you have gpu support for docker containers by running:
```shell
sudo docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```
If not, please install nvidia container toolkit.


## 📝 Setup simon
1) Go simon_core project and:

```shell
pip install .
simon_install
```

2) Simon init in this directory:
```shell
simon_init
```

## 🚀 Run simulation
```shell
simon up
```

## Configurations
in docker-compose.yml -> gazebo_sitl -> volumes:
We added a gazebo-iris.parm file to stabilise the gimbal, this overrides the basic ardupilot parameters.

## 🤝 Feedback and Contributions

For any issue regarding launching the simulation, please feel free to contact us :)
