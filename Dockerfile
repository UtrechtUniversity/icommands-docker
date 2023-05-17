FROM ubuntu:18.04

LABEL org.opencontainers.image.source=https://github.com/UtrechtUniversity/icommands-docker
LABEL org.opencontainers.image.description="Docker container with iCommands"
LABEL org.opencontainers.image.licenses=MIT

RUN apt-get update && apt-get install -y gnupg2
RUN apt-get -y install wget
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -
RUN echo "deb [arch=amd64] https://packages.irods.org/apt/ xenial main" | tee /etc/apt/sources.list.d/renci-irods.list
RUN apt-get update
RUN apt -y install irods-icommands

CMD [ "ihelp" ]