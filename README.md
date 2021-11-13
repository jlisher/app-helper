# App Helper

App Helper is a docker compose application development helper utility.

## Requirements

- [docker-compose](https://docs.docker.com/compose/install/)
- [jq](https://stedolan.github.io/jq/download/)
  - Added for making completions easier to parse.

## Installation

There are a few ways in which you can install App.

> An installation script will be added soon.
> Please note, this tools isn't focused on being a general purpose user application, so this is not a priority.

### Composer

This is the original concept as it was created to work with laravel projects however added more generic methods and 
tools, so we can use it in any project.

Install using composer, simply run the following command:

```shell
composer reuqire --dev jlisher/app-helper
# run the install script
./vendor/bin/app.sh install
```

### NPM

While nodejs has the nvm project, which is nice, it doesn't help when you are creating container based applications
where you have multiple containers running different versions of nodejs. For this reason we have added support for npm
based installations and running nodejs and npm within the container.

Installing using npm, simply run the following command:

```shell
npm install -D jlisher-app-helper
```

### Git

You can use git to install and update the utility. 

Simply clone the repo and run the `install` command: 

```shell
git clone https://github.com/jlisher/app-helper.git
# cd into your project directory
cd /path/to/your/project
# run the installation
./path/to/app-helper/src/app.sh install
```

please replace `/path/to/app-helper/` with your real path to the app-helper files

### Manual

Simply download the files and place them in a directory within your application directory.

Simply download the files and run:

```shell
./path/to/app-helper/src/app.sh install
```

please replace `/path/to/app-helper/` with your real path to the app-helper files, 
and `/path/to/your/project` with your project directory.

## Setup

During installation, App Helper append some lines to the `.bashrc` file in your project root directory.

The `.bashrc` file is there to offer some handy shortcuts and set some environment variables, which are required for the
app helper script.

To make your life easier simply source the `.bashrc` file whenever you want to use the functionality. This only needs to
be performed once per a terminal session.

```shell
source .bashrc
```

The following variables are available to edit the default behaviour: 

| Variable | Default | Definition |
| --- | --- | --- |
| `_APP_HELPER_BASE_DIR` | `pwd` | Path to your project root directory. |
| `_APP_HELPER_COMPOSE_FILE` | `${APP_HELPER_BASE_DIR}/docker-compose.yml` | Path to the `docker-compose.yml` file for your project | 
| `_APP_HELPER_SERVICE` | `app` | The name of the `docker-compose` service to use. |
| `_APP_HELPER_USER`* | `www-data` | The username of the user to run as inside the container. This is ignored if the default user isn't root. |
| `_APP_HELPER_CUID`* | `id -u` | The id of the executing user inside the container. See note below for further details |

Note: `_APP_HELPER_USER` is ignored if `_APP_HELPER_CUID` is not `0`. `su` is used inside the container to execute the command as the `_APP_HELPER_USER`. This means that you have changed the user in the `Dockerfile` or `docker-compose.yml`
files `su` cannot be used, all commands will be executed as the user set in the `Dockerfile` or `docker-compose.yml`
files.

### Change Command Name

There is an easy way to change the command used to invoke the helper script. 
You simply need to prefix the installation command with `_APP_HELPER_ALIAS={new_app}` (replacing `{new_app}` with your desired name).
This will result in the alias, which is generated during the installation, being set to the provided name. 

For example:

```shell
# install the helper
_APP_HELPER_ALIAS=new_app ./path/to/app-helper/src/app.sh install
# source the .bashrc file
source .bashrc
# use your new alias
new_app --help
```

### Changing Service Name

> This script uses `docker-compose`, support for the `docker` cli might be added but for now `docker-compose` is easier to work with.

If you are using a service name other than the default `app`, all you need to do is update the `_APP_HELPER_SERVICE` variable. 
This may be done by either; applying the same logic to `_APP_HELPER_SERVICE` as we did with `_APP_HELPER_ALIAS` above, 
or by updating the value of `_APP_HELPER_SERVICE` in the `.bashrc` file after installation and sourcing the file from a new shell.

### Example Using The Laravel Sail Container

Simply prefix the installation command with `_APP_HELPER_SERVICE="laravel.test" _APP_HELPER_USER="sail"`. example: 

```shell
_APP_HELPER_SERVICE="laravel.test" _APP_HELPER_USER="sail" ./path/to/app-helper/src/app.sh install
```

## Usage

> The `--help` option will always be available, it will always contain the most important information.

WIP

## TODO

- Documentation.
- Refactor the functions to allow for better scoping and to keep the user's environment clean.
- Probably need to rewrite this in a proper language at some point too, but sh is a fun challenge.
