#!/bin/bash
#

#set -v
#set -x

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $SCRIPTS_DIR/roscorizing.sh

# Run roscorizing in a subshell
roscorizing rostopic pub -l /test_msg std_msgs/Bool "data: True" &

# Give some time to roscore to starts
sleep 1

uri_local 11322

rostopic echo /test_msg
