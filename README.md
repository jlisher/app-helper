# App Helper

App Helper is a docker compose application development helper utility.

## Installation

There are a few ways in which you can install App.

### 1. composer

This is the original concept as it was created to work with laravel projects however added more generic methods and 
tools, so we can use it in any project.

Install using composer, simply run the following command:

```shell
composer reuqire --dev jlisher/app-helper
```

### 2. npm

While nodejs has the nvm project, which is nice, it doesn't help when you are creating container based applications
where you have multiple containers running different versions of nodejs. For this reason we have added support for npm
based installations and running nodejs and npm within the container.

Installing using npm, simply run the following command:

```shell
npm install -D jlisher-app-helper
```

### 4. Git

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

### 3. Manual

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
