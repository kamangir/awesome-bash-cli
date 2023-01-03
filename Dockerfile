# our base image
FROM alpine

# mkdir's
RUN mkdir -p /root/git/awesome-bash-cli; \
    mkdir -p /root/.kaggle

COPY temp/kaggle.json /root/.kaggle/kaggle.json

# apk add's
RUN apk update
RUN apk upgrade
RUN apk add openssh-client
RUN apk add git
RUN apk add --no-cache bash
# https://github.com/ish-app/ish/issues/393#issuecomment-1075880743
RUN apk add shadow

# https://stackoverflow.com/a/39777387/17619982
SHELL ["/bin/bash", "-c"] 

# https://gist.github.com/rvarago/9ba1549057bfd7e09a956d770b9939f4
RUN apk --update add python3
RUN apk add py3-pip
RUN pip install --upgrade pip

ADD . /root/git/awesome-bash-cli/

RUN cd /root/git/awesome-bash-cli; pip3 install -e .

# RUN source /root/git/awesome-bash-cli/bash/abcli.sh

# https://www.cyberciti.biz/faq/how-to-change-shell-to-bash/
# https://github.com/ish-app/ish/issues/393#issuecomment-1075880743
#RUN printf "MyPassword\nMyPassword" | passwd
#RUN echo "MyPassword" | chsh -s /bin/bash

# install Python modules needed by the Python app
#COPY requirements.txt /usr/src/app/
#RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt

# copy files required for the app to run
#COPY app.py /usr/src/app/
#COPY templates/index.html /usr/src/app/templates/

# tell the port number the container should expose
#EXPOSE 5000

# run the application
#CMD ["python", "/usr/src/app/app.py"]
