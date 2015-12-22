#Roscorizing
##A collection of hacky bash functions to easily run a ros comand on a new roscore

*Roscorizing* aims at facilitating the evaluation of a ros-based implementation of an algorithm by allowing the user to lunch several instance of it in parallel on different roscore.

##Use

```shell
source roscorizing.sh
roscorizing rosrun my_pkg my_pkg_node
```
It will informs the user on which port the new roscore has been lunched.

Then to see eventual output from another shell

```shell
export ROS_MASTER_URI=http://localhost:[port]
rostopic echo /my_topic
```
or also

```shell
source roscorizing.sh
uri_local [port]
rostopic echo /my_topic
```
