# Docker container with icommands

__iCommands__ is a collection of command line tools for interfacing with iRods instances, such as YODA. Using iCommands is a more stable and faster way of uploading and downloading data to iRods than through a WebDav drive-mapping.

However, iCommands are only available for some flavours of Linux (CentOS and Ubuntu), and Windows 10 or 11 using the 'Windows Subsystem for Linux' (WSL). To make them available on other platforms and Windows-systems without WSL, this repository offers a straightforward way of running iCommands using a Docker container. The only technical prerequisite is a Docker installation.

More information on iCommands:

+ [iCommands documentation](https://docs.irods.org/master/icommands/user/)
+ [YODA: Using iCommands for large datasets](https://www.uu.nl/en/research/yoda/guide-to-yoda/i-am-using-yoda/using-icommands-for-large-datasets)
+ [iRODS Client - iCommands](https://github.com/irods/irods_client_icommands)


## Building a container
In order to run the Docker container, it must first be built. Clone this repository, open a terminal, and navigate to the [dockerfile](./dockerfile) folder.

Execute this command to build a container from the definition in the Dockerfile, substituting &lt;tag&gt; with a tag of your choosing:
```bash
$ sudo docker build -t <tag> .
```
A tag should consist of a label and a version, separated by a colon; for instance: `my_tag:1.0`. If the version is omitted, it will default to `latest` (`my_tag:latest`). Remember the tag, as it is required to run the container once it has been built.

For the sake of convenience, a bash file (for Linux) is included to run the build command with `icommands:0.1` as default tag.

The first time it will take a few minutes to build the container. Generally speaking, it only needs to be built once. However, it is possible that after a period of disuse, the built container is removed from the local cache. If this has happened, you will encounter the error `Unable to find image 'icommands:0.1' locally` when executing a command. In that case, simply re-run the build command, and the image will become available once more.


## Running a container
The general syntax for running a container is:
```bash
$ docker run -i --rm <tag> <command>
```
`-i` causes the command to run interactively, `--rm` automatically removes the container when it exits. For a complete overview of the options, see the entry for [docker run](https://docs.docker.com/engine/reference/commandline/run/) in the Docker manual.

To run, for instance, the iCommands help-command `ihelp` in the container we've just built, execute:
```bash
$ docker run -i --rm icommands:0.1 ihelp
```
This will print the output of the `ihelp` command as if it were installed on your own computer.

