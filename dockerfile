FROM kalilinux/kali-rolling
COPY analyze.sh /home/analyze/
RUN chmod +x analyze.sh
RUN apt update && apt install -y iproute2 iputils-ping net-tools openssh-client
RUN apt update && apt install -y clamav binwalk
