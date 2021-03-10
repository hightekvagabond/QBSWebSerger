FROM python:3.7-slim

MAINTAINER OMBU


WORKDIR /root


# add contents to folder
COPY awscreds.tgz .
COPY ssh.tgz .
COPY installcreds.sh .
COPY pathcount.txt .
RUN /root/installcreds.sh

#RUN tar -zxf awscreds.tgz --directory /root/.aws 
#RUN tar -zxf ssh.tgz --directory /root/.ssh 

RUN apt-get -qq update && apt-get install -y build-essential \
    libssl-dev groff \
    && apt-get install vim -y \
    && apt-get install -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install -r requirements.txt

CMD ["pip", "freeze"]

ENTRYPOINT /bin/bash






