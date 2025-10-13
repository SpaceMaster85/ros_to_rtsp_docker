# Basis-Image: ROS2 Humble Desktop
FROM arm64v8/ros:jazzy

SHELL ["/bin/bash", "-c"]

# Installiere notwendige Pakete
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    python3-colcon-common-extensions \
    python3-pip \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-rtsp \
    && rm -rf /var/lib/apt/lists/*

# Installiere MediaMTX
RUN wget https://github.com/bluenviron/mediamtx/releases/download/v1.15.1/mediamtx_v1.15.1_linux_arm64.tar.gz \
    && tar -xzf mediamtx_v1.15.1_linux_arm64.tar.gz \
    && mv mediamtx /usr/local/bin/ \
    && rm mediamtx_v1.15.1_linux_arm64.tar.gz

# Erstelle Arbeitsverzeichnis für ROS2
WORKDIR /root/ros_ws/src

# Klone ros-gst-bridge Repository
RUN git clone https://github.com/BrettRD/ros-gst-bridge.git

# Baue ROS2 Workspace
WORKDIR /root/ros_ws

RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    apt-get update && rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y

# Build
RUN . /opt/ros/$ROS_DISTRO/setup.sh && colcon build --symlink-install


# Kopiere die Konfigurationsdatei für MediaMTX
COPY mediamtx.yml /root/ros_ws/mediamtx.yml

# Exponiere RTSP-Port
EXPOSE 8554

# Kopiere das Startskript
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Standardbefehl zum Starten des Containers
CMD ["/root/entrypoint.sh"]
