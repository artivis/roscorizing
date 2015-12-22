#! /bin/bash
#
# Author : Jeremie Deray

#set -e
#set -o pipefail

function get_roscore_pid_by_port()
{
  if [[ $# < 1 ]]
  then
    echo "usage: get_roscore_pid_by_port [port_value]" 1>&2
    return 1
  else
    echo `pgrep -f "roscore.*${1}"`
    return 0
  fi
}

function new_roscore_by_port()
{
  if [[ $# < 1 ]]
  then
    echo "usage: new_roscore_by_port [port_value]" 1>&2
    return 1
  else
    if [[ $(get_roscore_pid_by_port ${1}) == "" ]]
    then
      echo "Starting a roscore on port : ${1}"
      roscore -p ${1} 1> /dev/null
      return 0
    else
      echo "Roscore already exist on port : ${1} !" 1>&2
      return 1
    fi
  fi
}

# Show or change $ROS_MASTER_URI localhost port
function uri_local()
{
  if [[ $# < 1 ]]
  then
    echo "usage: uri_local [port_value]" 1>&2
    return 1
  else
    export ROS_MASTER_URI=http://localhost:$1
  fi
}

function kill_roscore_by_port()
{
  if [[ $# < 1 ]]
  then
    echo "usage: kill_roscore_by_port [port_value]" 1>&2
    return 1
  else
    local roscore_pid=$(get_roscore_pid_by_port ${1})
    if [[ roscore_pid != "" ]]
    then
      kill -1 $roscore_pid &> /dev/null
    fi
    return 0
  fi
}

function find_available_port()
{
  # Starts port search at 11322 since 11311 is default one

  local local_port

  if [[ $# == 1 ]] && [[ ${1} > 11311 ]]
  then
	local_port=${1}
  else
    local_port=11322
  fi

  while [[ $(get_roscore_pid_by_port $local_port) != "" ]]
  do
    let local_port+=11
  done

  echo $local_port
}

# TODO : export somehow pid & port
function roscorizing()
{
  if [[ $# < 1 ]]
  then
    echo "usage: roscorizing ros_cmd" 1>&2
    return 1
  else    
    ROSCORE_PORT=$(find_available_port)

    # '&' (ampersand) is a builtin control operator
    # that executes the command in the background in a subshell
    new_roscore_by_port $ROSCORE_PORT &

    #trap 'echo "trapping roscore"; kill_roscore_by_port $ROSCORE_PORT' EXIT SIGINT SIGTERM SIGHUP

    # Gives some time to roscore to starts 
    sleep 1;

    ROSCORE_PID=$(get_roscore_pid_by_port $ROSCORE_PORT)

    #echo "It has PID : $ROSCORE_PID"

    uri_local $ROSCORE_PORT

	# Todo : fix quote
    command=$@

    #echo "About to exec : $command"

    ($command)

    # Gives some time to $command to shutdown 
    sleep 1;

    kill_roscore_by_port $ROSCORE_PORT

    return 0
  fi
}
