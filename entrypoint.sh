#!/bin/bash
set -e

# Source ROS2 and workspace
source /opt/ros/${ROS_DISTRO}/setup.bash
source /root/ros_ws/install/setup.bash

# Start RTSP server in background
echo "Starte MediaMTX..."
mediamtx &

# Give server a moment to initialize
sleep 2

# Start ROS2-GStreamer pipeline (Beispiel)
echo "Starting ROS2 camera stream..."
gst-launch-1.0 --gst-plugin-path=/root/ros_ws/install/gst_bridge/lib/gst_bridge/ \
  rosimagesrc ros-topic=/camera/image_raw ! \
  queue ! \
  videoconvert ! \
  videorate ! video/x-raw,format=I420,framerate=30/1 ! \
  queue ! \
  x264enc bitrate=4000 tune=zerolatency speed-preset=ultrafast ! \
  h264parse ! \
  rtspclientsink location=rtsp://0.0.0.0:8554/camera0 \
&
gst-launch-1.0 --gst-plugin-path=/root/ros_ws/install/gst_bridge/lib/gst_bridge/ \
  rosimagesrc ros-topic=/camera/image_raw ! \
  queue ! \
  videoconvert ! \
  videorate ! video/x-raw,format=I420,framerate=30/1 ! \
  queue ! \
  x264enc bitrate=4000 tune=zerolatency speed-preset=ultrafast ! \
  h264parse ! \
  rtspclientsink location=rtsp://0.0.0.0:8554/camera1 \
&

wait
# Keep container alive
#exec "$@"
