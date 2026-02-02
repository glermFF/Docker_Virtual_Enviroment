FROM kalilinux/kali-rolling
RUN apt update && apt install -y iproute2 iputils-ping net-tools openssh-client
RUN apt update && apt install -y clamav binwalk