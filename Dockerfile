# 使用 ROS 2 Humble 官方桌面镜像
FROM 10.1.0.3:5050/common/osrf/ros:humble-desktop

# 设置环境变量
ENV WORKDIR=/ros2_orbbec_ws
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR ${WORKDIR}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    python3-serial \
    vim \
    net-tools \
    can-utils \
    git \
    curl \
    build-essential \
    libssl-dev \
    libusb-1.0-0-dev \
    pkg-config \
    libgtk-3-dev \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libudev-dev \
    libgflags-dev  \
    libdw-dev \
    mesa-va-drivers \
    vainfo \
    nlohmann-json3-dev \
    ros-humble-image-transport \
    ros-humble-compressed-depth-image-transport \
    ros-humble-ffmpeg-image-transport \
    ros-humble-image-publisher \
    ros-humble-camera-info-manager \
    ros-humble-diagnostic-updater \
    ros-humble-diagnostic-msgs \
    ros-humble-statistics-msgs \
    ros-humble-backward-ros \
    ros-humble-ros2-socketcan \
    ros-humble-can-msgs \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${WORKDIR}/src
COPY OrbbecSDK_ROS2 ${WORKDIR}/src/OrbbecSDK_ROS2
COPY shm_fastdds.xml /root/shm_fastdds.xml
COPY entrypoint.sh /root/entrypoint.sh

RUN . /opt/ros/humble/setup.sh && \
    cd $WORKDIR && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

RUN echo 'alias sos="source /opt/ros/humble/setup.bash"' >> /root/.bashrc && \
    echo 'alias sis="source install/setup.bash"' >> /root/.bashrc && \
    echo 'alias rtl="ros2 topic list"' >> /root/.bashrc && \
    echo 'alias rte="ros2 topic echo"' >> /root/.bashrc && \
    echo 'alias rth="ros2 topic hz"' >> /root/.bashrc && \
    echo 'alias single="ros2 launch orbbec_camera gemini_330_series.launch.py"' >> /root/.bashrc && \
    echo 'alias double="ros2 launch orbbec_camera multi_camera.launch.py"' >> /root/.bashrc && \
    echo 'alias record_single="ros2 bag record /camera/color/camera_info /camera/color/image_raw/ffmpeg /camera/depth/camera_info /camera/depth/image_raw /camera/left_ir/camera_info /camera/left_ir/image_raw/ffmpeg /camera/right_ir/camera_info /camera/right_ir/image_raw/ffmpeg"' >> /root/.bashrc && \
    echo 'alias record_double="ros2 bag record /left/color/camera_info /left/color/image_raw/ffmpeg /left/depth/camera_info /left/depth/image_raw /left/left_ir/camera_info /left/left_ir/image_raw/ffmpeg /left/right_ir/camera_info /left/right_ir/image_raw/ffmpeg /right/color/camera_info /right/color/image_raw/ffmpeg /right/depth/camera_info /right/depth/image_raw /right/left_ir/camera_info /right/left_ir/image_raw/ffmpeg /right/right_ir/camera_info /right/right_ir/image_raw/ffmpeg"' >> /root/.bashrc && \
    echo 'source /opt/ros/humble/setup.bash' >> /root/.bashrc && \
    echo 'source /ros2_orbbec_ws/install/setup.bash' >> /root/.bashrc

ENTRYPOINT ["/root/entrypoint.sh"]