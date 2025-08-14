#!/bin/bash

# USB Memory Optimization
echo 256 > /sys/module/usbcore/parameters/usbfs_memory_mb
echo "✓ USB memory set to 256MB"

# Fast DDS Parameters
sysctl net.ipv4.ipfrag_time=3
sysctl net.ipv4.ipfrag_high_thresh=134217728
sysctl -w net.core.rmem_max=2147483647
sysctl -w net.core.rmem_default=2147483647
sysctl -w net.core.wmem_max=2147483647
sysctl -w net.core.wmem_default=2147483647
echo "✓ Fast DDS network parameters optimized!"

# Fast DDS XML Configuration
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export FASTRTPS_DEFAULT_PROFILES_FILE=$HOME/shm_fastdds.xml
export RMW_FASTRTPS_USE_QOS_FROM_XML=1
echo "✓ Fast DDS environment variables set!"

exec /bin/bash