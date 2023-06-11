FROM python:3.8-slim

ARG HOME

RUN pip install numpy
RUN pip install panda

# https://stackoverflow.com/a/66473309/17619982
RUN apt-get update && apt-get install -y python3-opencv
RUN pip install opencv-python

ADD . /root/git/awesome-bash-cli/

RUN cd /root/git/awesome-bash-cli; pip3 install -e .

CMD ["bash", "-ic", "source /root/git/awesome-bash-cli/bash/abcli.sh; /bin/bash"]