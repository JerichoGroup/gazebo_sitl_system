## 📚 About

**gazebo_sitl_system** is a linux based simulation system for launching: 

- Gazebo (ignition) Garden.
- Ardupilot sitl.
- Mavros (ros2 humble).

## 📝 Build docker images
```shell
docker build -t gazebo_sitl:humble_garden -f gazebo_sitl.dockerfile .
docker-compose build
```
## 🚀 Run simulation 
```shell
docker-compose up
```

## 🤝 Feedback and Contributions

For any issue regarding launching the simulation, please feel free to contact us :)
