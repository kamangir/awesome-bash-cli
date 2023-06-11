FROM python:3.8-slim

ARG HOME

RUN pip install numpy
RUN pip install panda

ADD . /root/git/awesome-bash-cli/

RUN cd /root/git/awesome-bash-cli; pip3 install -e .

CMD ["bash", "-ic", "source /root/git/awesome-bash-cli/bash/abcli.sh; /bin/bash"]