FROM alpine

ARG abcli_git_ssh_key_name

RUN mkdir -p /root/.ssh; \
    mkdir -p /root/git/awesome-bash-cli; \
    mkdir -p /root/.kaggle

COPY temp/kaggle.json /root/.kaggle/kaggle.json

RUN apk update
RUN apk upgrade
RUN apk add openssh-client
RUN apk add git
RUN apk add --no-cache bash
# https://github.com/ish-app/ish/issues/393#issuecomment-1075880743
RUN apk add shadow

# https://stackoverflow.com/a/45143116/17619982
RUN apk add sudo

# https://stackoverflow.com/a/39777387/17619982
SHELL ["/bin/bash", "-c"] 

COPY temp/$abcli_git_ssh_key_name /root/.ssh/
RUN chmod 600 /root/.ssh/$abcli_git_ssh_key_name

# https://gist.github.com/rvarago/9ba1549057bfd7e09a956d770b9939f4
RUN apk --update add python3
RUN apk add py3-pip
RUN pip install --upgrade pip

ADD . /root/git/awesome-bash-cli/

RUN cd /root/git/awesome-bash-cli; pip3 install -e .

# https://www.cyberciti.biz/faq/how-to-change-shell-to-bash/
# https://github.com/ish-app/ish/issues/393#issuecomment-1075880743
RUN printf "MyPassword\nMyPassword" | passwd
RUN echo "MyPassword" | chsh -s /bin/bash

# RUN source /root/git/awesome-bash-cli/bash/abcli.sh

# ENTRYPOINT "/root/git/awesome-bash-cli/bash/abcli.sh"