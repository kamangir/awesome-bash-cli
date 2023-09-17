FROM ubuntu:latest

RUN apt-get update && apt-get install -y psmisc

RUN apt-get update && apt-get install -y python3-pip

RUN pip install numpy
RUN pip install panda

# https://askubuntu.com/a/1013396/1590785
ARG DEBIAN_FRONTEND=noninteractive

# https://stackoverflow.com/a/66473309/17619982
RUN apt-get update && apt-get install -y python3-opencv
RUN pip install opencv-python

VOLUME ["/root/git/awesome-bash-cli/"]

RUN cd /root/git/awesome-bash-cli
pip3 install -e .

CMD ["bash", "-ic", "source /root/git/awesome-bash-cli/bash/abcli.sh; /bin/bash"]
