# Docker container with iCommands

__iCommands__ is a collection of command line tools for interfacing with iRODS instances, such as YODA. Using iCommands is a more stable and faster way of uploading and downloading data to iRODS than through a WebDav drive-mapping.

However, iCommands are only available for some flavours of Linux (CentOS and Ubuntu), and Windows 10 or 11 using the Windows Subsystem for Linux (WSL). To make them available on other platforms and Windows-systems without WSL, this repository offers a straightforward way of running iCommands using a Docker container. The only technical prerequisite is a Docker installation.

More information on iCommands:

+ [iCommands documentation](https://docs.irods.org/master/icommands/user/)
+ [YODA: Using iCommands for large datasets](https://www.uu.nl/en/research/yoda/guide-to-yoda/i-am-using-yoda/using-icommands-for-large-datasets)
+ [iRODS Client - iCommands](https://github.com/irods/irods_client_icommands)

If you wish to access iRODS programmatically, there are [client libraries available in various languages](https://irods.org/clients/).


## Set up

### Downloading the container
To download and install the container, open a terminal on the computer where you want to run the container, and execute (requires GitHub-authorization):

```bash
$ docker pull ghcr.io/utrechtuniversity/docker_icommands:0.2
```

This needs only to be done once, but if for some reason the image is deleted from the local cache, you will encounter the error `Unable to find image 'ghcr.io/utrechtuniversity/docker_icommands:0.2' locally` when executing a command. In that case, simply pull the container again.

#### Locally building the container (optional)
If for some reason you wish to build your own container image rather than download the image from the registry, clone [the repository](https://github.com/UtrechtUniversity/icommands-docker), and execute the following command in its root:

```bash
$ sudo docker build -t <tag> .
```
Subtitute `<tag>` with your own tag. A tag consists of a label and a version, separated by a colon; for instance: `my_tag:1.0`. If the version is omitted, it will default to `latest` (`my_tag:latest`). Remember the tag, as it is required to run the container once it has been built.


### Server configuration
iCommands require information about the iRODS-server you want to communicate with. For YODA, these differ per research environment; see [Step 2. Configuring iCommands](https://www.uu.nl/en/research/yoda/guide-to-yoda/i-am-using-yoda/using-icommands-for-large-datasets#paragraph-152527) on the page 'Using iCommands for large datasets' of UU's YODA-pages. Copy the appropriate configuration, and save it as a JSON-file named `irods_environment.json` on your computer (for example, save the file in: `/data/my_project/irods/`). Make sure to change the value of `irods_user_name` to the email-address matching your YODA-account.

### Volume mapping
By default, containers run as isolated processes from the host; to make files on the host available inside the container, you must explicitly map a file or folder from the host to one in the container. Volume mappings take the form `/path/on/host:/path/in/container`, and must be provided when starting the container using the `-v` flag. Multiple mappings can be provided by simply repeating the flag and the mapping. For example, by starting a container with `-v /data/my_project:/data`, the files residing on the host in `/data/my_project` will become  accessible within the container in the folder `/data`. Commands executed _inside_ the container, like iCommands, subsequently "see" the files in `/data`.

#### Mapping ~/.irods/ folder
The configuraton-file on your host computer must be made accessible to the iCommands running inside the container. By default, iCommands looks for the file in `~/.irods/`. As iCommands run inside the container as root, this expands to `/root/.irods/`. Map the folder on the host computer where you have saved `irods_environment.json` to `/root/.irods/` (expanding on the example above, the volume mapping would become `-v /data/my_project/irods/:/root/.irods/`).

Note that on initialisation, iCommands will write a cached password to a file in `~/.irods/`, so make sure to use the same mapping for subsequent sessions.

If, for some reason, you are running the container from a computer that also has iCommands installed and configured on the host itself, do not map your host's user own `~/.irods` folder to the one in the container, to avoid the host's cached password file from being overwritten from within the container.

#### Mapping data folder
If you are up- or downloading data to or from the iRODS-server, you will need to map an additional volume for files to be read from and/or stored in. To avoid confusion over different paths on the host and in the container, it is recommended to keep them the same, e.g. `/data/my_project/files:/data/my_project/files`.

N.b., make sure that the path in the container you are mapping to is not one that already exists on a default Linux installation (the container runs a Ubuntu 18.04 installation); for example, avoid a mapping like `/data:/tmp`, which would cause the `/data` directory on the host to also be used as the container's `/tmp` directory.


### Access to YODA & Data Access Password
Make sure that you have access to the YODA-environment you want to communicate with. Using iCommands will require a Data Access Password for the specific YODA-environment you are communicating with. Log in to the YODA-environment, generate a Data Access Password, and copy it ([more info on Data Access Passwords](https://www.uu.nl/en/research/yoda/using-data-access-passwords)).

Note that some YODA-servers are only accessible from within the UU's network. Furthermore, whether a specific YODA-server can be reached from a server (rather than a workstation) depends on network configuration. If attempts to access a YODA-server time out unsuccessfully, it is possible that a firewall between the two is limiting access.


## Running iCommands
### General syntax
The basic syntax for running iCommands via the container is:

```bash
$ docker run -it --rm \
     -v /path/to/irods_cfg:/root/.irods \
     -v /path/to/data:/path/to/data \
     ghcr.io/utrechtuniversity/docker_icommands:0.2 \
     <icommand> [<args>]
```
`-it` maked the command run interactively (not strictly necessary for commands that require no interaction, but doesn't cause errors either). `--rm` automatically removes the container when it exits. For a complete overview of the options, see the entry for [docker run](https://docs.docker.com/engine/reference/commandline/run/) in the Docker manual.

Volume mappings are optional, and only necessary if the operation you are performing requires access to the host's filesystem.

`<icommand>` can be any of the iCommands; see the [iCommands documentation](https://docs.irods.org/master/icommands/user/) for a complete list. If an iCommand expects arguments, these can be added after the command (no quotes required). If you run the command without any icommand and arguments, it will default to `ihelp`.

_Verbosity_

Most iCommands can be run with `-v` (verbose) and `-V` (very verbose) flags, which forces the command to give some feedback on its operation. This can be helpful to trace the source of problems, or gain a general insight in what's happening.

<a name=singlethreading></a>
_Single-threading_

Sync-, get- or put-operations automatically switch to multithreading when more than 30MB of data is being transferred. On occasion, this has been observed to cause problems, leading to timeouts. To force a command into single-threading mode, add the flag `-N 0` when running it:

```bash
$ docker run -it --rm -N 0 iget [...]
```

### Initialisation
Before first use, initialise the iCommands session by calling the `iinit` command:
```bash
$ docker run -it --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    -v /data/my_project/irods:/root/.irods iinit
```
You will be asked to enter your Data Access Password (or 'PAM password'), which, after succesful authorization, will be stored (scrambled) in the password cache file `/root/.irods/.irodsA` (which will appear as `/data/my_project/irods/.irodsA` on the host).

#### CAT_INVALID_AUTHENTICATION error
If you run into the error `-826000 CAT_INVALID_AUTHENTICATION` during operations, try regenerating the password cache file by exiting and re-initialising your iCommands session:
```bash
$ docker run -it --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    -v /data/my_project/irods:/root/.irods iexit full
$ docker run -it --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    -v /data/my_project/irods:/root/.irods iinit
```

### Examples of common operations
#### Help
To get an overview of all available iCommands:

```bash
$ docker run --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 ihelp
```

#### Synchronizing data between local folder and YODA
To recursively synchonise all data in the local folder `/data/my_project/files` to the YODA-collection `my_data`, run:

```bash
$ docker run -it --rm \
    -v /data/my_project/irods:/root/.irods \
    -v /data/my_project/files:/data/my_project/files \
    ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    irsync -rv /data/my_project/files i:my_data/
```
The `-r` flag ensures that folders are synced recursively, the `-v` flag will make the command give feedback on which files have been uploaded, and which were found to be unchanged. Unfortunately, none of the sync-, get- and put-operations display a proper indication of the operation's progress.

Note the `:i` prefix of the target path, indicating that it is an iRODS path. `irsync` can also be used to sync files from YODA to a local folder - in which case the order of the paths would be reversed - and between two locations in YODA, in which case both paths would get a `i:` prefix.

In case of timeout-errors, see [the paragraph about single-threading](#singlethreading).


#### Uploading a file
To upload a local file to YODA:
```bash
$ docker run --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    -v /data/my_project/irods:/root/.irods \
    -v /data/my_project/files:/data/my_project/files \
    iput /data/my_project/files/research_data.zip my-data/research/
```
This uploads the local file `research_data.zip` to the collection (folders are called 'collections' in iRODS) `my-data/research/` in YODA. This corresponds to the same folder within the Research-section in the YODA-webinterface (you cannot upload files to the Vault-section). If the collection you are uploading to doesn't exist yet, it is created automatically.

Note the absence of the `i:` prefix, which is unnecessary since the arguments are non-ambiguous.

In case of timeout-errors, see [the paragraph about single-threading](#singlethreading).

#### Downloading a file
Analogous to uploading:
```bash
$ docker run --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    -v /data/my_project/irods:/root/.irods \
    -v /data/my_project/files:/data/my_project/files \
    iget my-data/research/research_data.zip /data/my_project/files/backup
```
Note that the folder you are downloading to already needs to exist.

In case of timeout-errors, see [the paragraph about single-threading](#singlethreading).

#### Current iRODS environment
iCommands will automatically take the address of the YODA-server, and the iRODS home path from the configuration in the `irods_environment.json` file. To see the settings for the current iRODS environment:
```bash
$ docker run --rm ghcr.io/utrechtuniversity/docker_icommands:0.2 \
    -v /data/my_project/irods:/root/.irods \
    ienv
```

### Interrupting operations
A side-effect of running iCommands through a container can be that interrupting operations by pressing Ctrl+C doesn't work. To interrupt a running command, you can stop the container, rather than the command itself. Open a second terminal on the host, and list all running containers:
```bash
$ docker ps
```
This will produce a list of running containers. Find the correct container based on the values of IMAGE and COMMAND, copy its CONTAINER ID (a twelve character hexadecimal string), and run:
```bash
$ docker stop <CONTAINER ID>
```
to stop the container. Or, if that fails:
```bash
$ docker kill <CONTAINER ID>
```
