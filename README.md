## 📚 About

**gazebo_sitl_system** is a linux based simulation system for launching: 

- Gazebo (ignition) Garden.
- Ardupilot sitl.
- Mavros (ros2 humble).

## 📝 Build docker images
```shell
docker build -t gazebo_sitl:humble_garden -f gazebo_sitl.dockerfile .
docker build -t gazebo:garden_mavros -f gazebo_garden_mavros.dockerfile .
docker build -t sitl:Copter-4.0.5 -f sitl.dockerfile .
docker-compose build
```
## 🚀 Run simulation 
```shell
docker-compose up
```

## tmp
gazebo garden:
```shell
gz gazebo -v4 iris_runway.sdf
```
sitl:
```shell
sim_vehicle.py -v ArduCopter -f gazebo-iris --model JSON --map --console
```
mavros:
```shell
ros2 launch mavros apm.launch fcu_url:=tcp://localhost gcs_url:=udp://@
```


## 🤝 Feedback and Contributions

For any issue regarding launching the simulation, please feel free to contact us :)
