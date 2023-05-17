# Docker container with iCommands

__iCommands__ is a collection of command line tools for interfacing with iRods instances, such as YODA. Using iCommands is a more stable and faster way of uploading and downloading data to iRods than through a WebDav drive-mapping.

However, iCommands are only available for some flavours of Linux (CentOS and Ubuntu), and Windows 10 or 11 using the 'Windows Subsystem for Linux' (WSL). To make them available on other platforms and Windows-systems without WSL, this repository offers a straightforward way of running iCommands using a Docker container. The only technical prerequisite is a Docker installation.

More information on iCommands:

+ [iCommands documentation](https://docs.irods.org/master/icommands/user/)
+ [YODA: Using iCommands for large datasets](https://www.uu.nl/en/research/yoda/guide-to-yoda/i-am-using-yoda/using-icommands-for-large-datasets)
+ [iRODS Client - iCommands](https://github.com/irods/irods_client_icommands)


## Set up

### Downloading the container
To download and install the container, open a terminal on the computer where you want to run the container, and execute (requires GitHub-authorization):

```bash
$ docker pull ghcr.io/utrechtuniversity/docker_icommands:0.2
```

This needs only to be done once, but if for some reason the image is deleted from the local cache, you will encounter the error `Unable to find image 'ghcr.io/utrechtuniversity/docker_icommands:0.2' locally` when executing a command. In that case, simply pull the container again.

#### Building the container (optional)
If for some reason you wish to build your own container image rather than download the image from the registry, clone this repository, and execute the following command in the root of the cloned repo:

```bash
$ sudo docker build -t <tag> .
```
Subtitute `<tag>` with your own tag. A tag consists of a label and a version, separated by a colon; for instance: `my_tag:1.0`. If the version is omitted, it will default to `latest` (`my_tag:latest`). Remember the tag, as it is required to run the container once it has been built.


### Server configuration
iCommands require information about the iRods-server you want to communicate with. For YODA, these differ per research environment; see [Step 2. Configuring iCommands](https://www.uu.nl/en/research/yoda/guide-to-yoda/i-am-using-yoda/using-icommands-for-large-datasets#paragraph-152527) on the page 'Using iCommands for large datasets' of UU's YODA-pages. Copy the appropriate configuration, and save it as a JSON-file named `irods_environment.json` on your computer (for example, save the file in: `/data/my_project/irods/`). Make sure to change the value of `irods_user_name` to the email-address matching your YODA-account.

### Volume mapping
By default, containers run as isolated processes from the host; to make files on the host available inside the container, you must explicitly map a folder from the host to one in the container. Volume mappings take the form `/path/on/host:/path/in/container`, and must be provided when starting the container using the `-v` flag. Multiple mappings can be provided by simply repeating the flag and the mapping. For example, by starting a container with `-v /data/my_project:/data`, the files residing on the host in `/data/my_project` will become  accessible within the container in the folder `/data`. Commands executed _inside_ the container, like iCommands, subsequently "see" the files in `/data`.

#### Mapping .irods folder
The configuraton-file on your host computer must be made accessible to the iCommands running inside the container. By default, iCommands looks for the file in `~/.irods/`. As iCommands run inside the container as root, this expands to `/root/.irods/`. Map the folder on the host computer where you have saved `irods_environment.json` to  `/root/.irods/` (expanding on the example above, the volume mapping would become `-v /data/my_project/irods/:/root/.irods/`). Please note that iCommands will eventually also write a cached password to this folder, so make sure to use the same mapping for subsequent sessions.

Note: if you are working on a computer that also has iCommands installed and configured on the host itself, do not map your host's user own `~/.irods` folder to the one in the container, to avoid the host's cached password file from being overwritten from within the container.

#### Mapping data folder
If you are up- or downloading data to or from the iRods-server, you will need to map an additional volume for file to be read from or stored in. To avoid confusion over different paths on the host and in the container, it is recommended to keep them the same, e.g. `/data/my_project/files:/data/my_project/files`.

N.b., make sure that the path in the container you are mapping to is not one that already exists on a default Linux installation (the container runs a basic Ubuntu installation); for example, avoid a mapping  like `/data:/tmp`, which would cause the `/data` directory on the host to suddenly also be used as the container's `/tmp` directory.


### Access to YODA & Data Access Password
Make sure that you have access to the YODA-environment you want to communicate with. Using iCommands will require a Data Access Password for the specific YODA-environment you are communicating with. Log in to the YODA-environment, generate a Data Access Password, and copy it ([more info on Data Access Passwords](https://www.uu.nl/en/research/yoda/using-data-access-passwords)).

Please note that some YODA-environments are only accessible from within the UU's network. 


## Running iCommands
### General
The basic syntax for running iCommands via the container is:

```bash
$ docker run -i --rm \
     -v /path/to/irods_cfg/:/root/.irods/ \
     -v /path/to/data/:/path/to/data/ \
     ghcr.io/utrechtuniversity/docker_icommands:0.2 \
     <icommand>
```
`<icommand>` can be any of the iCommands; see the [iCommands documentation](https://docs.irods.org/master/icommands/user/) for a complete list. If an iCommand expects parameters, these can be added normally after the command (no quotes required).

`-i` causes the command to run interactively, `--rm` automatically removes the container when it exits. For a complete overview of the options, see the entry for [docker run](https://docs.docker.com/engine/reference/commandline/run/) in the Docker manual.

The volume mappings are optional, and only necessary if the operation you are performing requires them (for instance, `ihelp` only lists  available commands, and doesn't require access to any files on the host).


### Password caching (optional)
To avoid having to enter your password repeatedly, iCommands gives you the option of caching your password by calling the `iinit` command:
```bash
$ docker run -i --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 iinit
```
You will be asked to enter your Data Access Password (or 'PAM password'), which, after succesful authorization, will be stored in the password cache file `/root/.irods/.irodsA` (path in the container).

#### CAT_INVALID_AUTHENTICATION error
Password caching has been observed to occasionally cause problems. If you are confronted during further operations with the error `-826000 CAT_INVALID_AUTHENTICATION`, then this is the case. If so, remove the `.irodsA` file by manually deleting it from the directory you have mapped to `/root/.irods/` (although documentation seems to suggest that this can be achieved by running the `iexit` command, this doesn' actually remove the cache file). Do not run `iinit` again. You will be required to enter your Data Access Password with each operation.


### 'Echo mode' errors
Some commands will display the errors `WARNING: Error 25 disabling echo mode.` and `Error reinstating echo mode.`. These can safely be ignored.


### Examples of common operations
#### Help
To get an overview of all available commands:

```bash
$ docker run --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 ihelp
```

For help on a specific iCommand:
```bash
$ docker run --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 ihelp <icommand>
```

#### Synchronizing data between local copy and copy stored in iRODS
```bash
$ docker run -i --rm \
    -v /path/to/irods_cfg/:/root/.irods/ \
    -v /path/to/data/:/path/to/data/ \
    ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    irsync -rv /path/to/data/upload/ i:/nluu12p/home/my_data/
```


### Interrupting operations
If you want to interrupt a (long) running command, open another terminal and display a list of running containers:
```bash
$ docker ps
```
You will see a list of running containers. Find the correct container based on the values of IMAGE and COMMAND, copy its CONTAINER ID, and run:
```bash
$ docker kill <CONTAINER ID>
```
