FROM python:3.7-slim

MAINTAINER OMBU


WORKDIR /root

RUN apt-get -qq update && apt-get install -y build-essential \
    libssl-dev groff \
    && apt-get install vim -y \
    && apt-get install -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install -r requirements.txt

CMD ["pip", "freeze"]

ENTRYPOINT /root/src/CreateEC2.py
