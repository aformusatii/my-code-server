FROM lscr.io/linuxserver/code-server:latest

# Install as root (build-time, so it persists in the image)
RUN apt update -y && \
    apt install -y python3 python3-pip && \
    ln -sf /usr/bin/python3 /usr/bin/python