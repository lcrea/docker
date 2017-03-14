# Odoo & OpenERP Docker Images

This is a fork of the [Official Odoo repository](https://github.com/odoo/docker) on GitHub with some personal touch :sunglasses:  
I've chosen to divide this project in two main categories:

-   Odoo (versions 8/9/10)
-   OpenERP (version 6.1)

See below each one for more details.

---

## Odoo
Built exactly upon **the same Dockerfiles of the official ones**, but with these main differences:

1.  Always providing **the latest revision** of Odoo available on the nightly build servers with a **regular update** (see "Update plan" below).
1.  Fixing this boring issue: "[Error creating a new database](https://github.com/odoo/docker/issues/97)".

### To whom is this image for?
Anyone who wants to use Odoo through Docker, but needs an higher update frequency than the official one.

### Update plan
I've scheduled an automatic weekly rebuild of the image (every **Sunday**). This should guarantee both a good update rate for users and a not excessive overload of Docker's servers.

### What if I want to build it by myself?
All the necessary files are freely downloadable from my repo "[odoo-docker](https://github.com/lcrea/odoo-docker)" on GitHub, grouped by versions. You can simply clone the entire repository or download every single file you need and build your own image.

#### IMPORTANT
When it comes the time to update your image, please pay attention to **disable the cache of Docker** adding this flag `--no-cache` like this:

`$ docker build --no-cache -t my/odoo .`

This is necessary, because the `Dockerfile` is structured to always fetch the latest version from the nightly build servers, but the `Dockerfile` itself remains unchanged!  
So, if you don't disable the cache during the building process, Docker will not find any variation on the `Dockerfile` and it will reuse the cache version, returning exactly the latest image you previously compiled.

### If do I need help?
Because this image is quite the same as the official one, if you need any help or any informations, please refer to the Official repositories at these links:  

-   [Odoo Official: GitHub](https://github.com/odoo/docker)
-   [Odoo Official: Docker](https://registry.hub.docker.com/_/odoo/)  

---

## OpenERP v6.1
Based on the latest version available from GitHub, this aims to be a production ready OpenERP 6.1 image, powered up with all the main report engines:

-   **Aeroolib** (latest version)
-   **WebKit** (version 0.12.4)

### How to use it
Fist of all, the following images are required:

-   PostgreSQL
-   [lcrea/libreoffice-headless](https://hub.docker.com/r/lcrea/libreoffice-headless/) (only for Aeroo reports)

#### Start PostgreSQL
```
$ docker run -d \
    -e POSTGRES_USER=openerp \
    -e POSTGRES_PASSWORD=openerp \
    --name oe_db \
    postgres:9-alpine
```

#### Start Libreoffice (optional)
`$ docker run -d --name oe_loffice lcrea/libreoffice-headless`  

*Please refer to my [Libreoffice Headless](https://hub.docker.com/r/lcrea/libreoffice-headless/) page on Docker Hub for any extra information about how to use this image.*

#### Start OpenERP
```
$ docker run -d \
    -e DB_NAME=openerp \
    -e DB_PWD=openerp \
    -e DB_USER=openerp \
    --link oe_db:psql \
    --link oe_loffice:libreoffice \
    -p 8069:8069 \
    --name openerp \
    lcrea/odoo:6.1
```

### Custom configuration

#### Configuration file
The default configuration template is placed inside the image in this path:  
`/etc/openerp/openerp-server.conf`

IMHO, the best way to use a custom config file is mounting it through the Docker parameter `-v` like this:

```
$ docker run -d \
    -v /path/to/your/openerp-server.conf:/etc/openerp/openerp-server.conf \
    -e DB_NAME=openerp \
    -e DB_PWD=openerp \
    -e DB_USER=openerp \
    --link oe_db:psql \
    --link oe_loffice:libreoffice \
    -p 8069:8069 \
    --name openerp \
    lcrea/odoo:6.1
```

This simplifies your image update process and give you enough flexibility to play with the configuration in real time.

#### Ports available
These two native ports are exposed:

-   `8069`
-   `8070`

#### External volumes
As the official Odoo image, the same two volumes are declared:

-   `/mnt/extra-addons`: to mount or to store custom modules.
-   `/var/lib/openerp/filestore`: to store the attachments generated inside OpenERP.

#### How to add extra modules
You can mount a folder from the filesystem full of modules with the `-v` Docker parameter, like the config file:

```
$ docker run -d \
    -v /path/to/your/modules/:/mnt/extra-addons \
    -e DB_NAME=openerp \
    -e DB_PWD=openerp \
    -e DB_USER=openerp \
    --link oe_db:psql \
    --link oe_loffice:libreoffice \
    -p 8069:8069 \
    --name openerp \
    lcrea/odoo:6.1
```

Alternatively, you can build another image based on this one with all the modules inside it, or:

1.  Create a Docker volume.
1.  Copy all the modules inside it.
1.  Mount the volume to the `/mnt/extra-addons` path.

#### Environment variables
The following variables are available with their relative default values:

-   `DB_HOST`
    -   default: `psql`
-   `DB_NAME`
    -   default: `openerp`
-   `DB_PORT`
    -   default: `5432`
-   `DB_PWD`
    -   default: `openerp`
-   `DB_USER`
    -   default: `openerp`

**They all are optional.** Obviously, using different values is highly suggested.

##### WARNING
Please, bear in mind that any values (i.e. **passwords**) passed through the environment variables **can be read by anyone who has access to Docker**, simply using `docker top` or any alternative commands.

#### How to update
Like the official ones, simply pass the `-u` flag (a shortcut for `openerp-server -u`) and this automatically force OpenERP to reload all the modules, like this:  

```
$ docker run \
    -e DB_NAME=openerp \
    -e DB_PWD=openerp \
    -e DB_USER=openerp \
    --link oe_db:psql \
    -p 8069:8069 \
    --name openerp \
    lcrea/odoo:6.1 \
    -u
```

### Reports

#### How to use Aeroolib reports
The latest version available of the Aeroo Report modules are already included inside OpenERP image. Thus, all you need, it's just lunching a container of my image [lcrea/libreoffice-headless](https://hub.docker.com/r/lcrea/libreoffice-headless/) as described above.

To configure OpenERP to send the print request to the LibreOffice container, simply follow these steps:

1.  Install `report_aeroo` and `report_aeroo_ooo` modules.
1.  On the "Configure OpenOffice.org connection" window, set:
    -   **host**: `oe_loffice` (the name of the LibreOffice container)
    -   **port**: `8100` (the port set on the LibreOffice container)
1.  Follow the steps on screen.
1.  You should see this message:
    -   *Connection to the OpenOffice.org instance was successfully established and PDF conversion is working.*

You're now ready to print your reports through Aeroo.  
If you just want to run a test, you can additionally install the module `report_aeroo_sample`, included in the image too.

For more information about Aeroo reports, news or support, please refer to the official page of [Alistek Ltd.](http://www.alistek.com/wiki/index.php/Main_Page)

#### How to user WebKit reports
To use WebKit, simply follow these steps:

1.  Install `report_webkit` module.
1.  Check that your user as the `Extended View` flag active.
1.  Go to Settings > Customization > Low Level Objects > System Parameters.
1.  Create a new record with:
    -   key: `webkit_path`
    -   value: `/usr/local/bin/wkhtmltopdf`

That's it!

##### Blank page issue
After you configured WebKit, it's very important to **set all the page margins** (top, bottom, left, right) in the CSS section of the base report **grater than zero**, otherwise the system will produce PDF files with only one blank page.

For a more precise report, it's also better to set units in the `font-size` CSS properties too. Unfortunately, the default base report provided is pretty messy.

### User case example with Docker Compose
The best way to enjoy a full working OpenERP environment is leveraging the power of Docker Compose. What's following is only an example of a simple (but fully working) environment.

```yaml
version: '2'

services:
    libreoffice:
        image: lcrea/libreoffice-headless

    psql:
        image: postgres:9-alpine
        environment:
            - POSTGRES_PASSWORD=${PSQL_PASS}
            - POSTGRES_USER=${PSQL_USER}

    openerp:
        image: lcrea/openerp:6.1
        depends_on:
            - libreoffice
            - psql
        environment:
            - DB_NAME=${PSQL_DB}
            - DB_PWD=${PSQL_PASS}
            - DB_USER=${PSQL_USER}
        links:
            - libreoffice:libreoffice
            - psql:psql
        ports:
            - "8069:8069"
        volumes:
            - /path/to/your/modules/:/mnt/extra-addons
```

#### Note
I intentionally wanted to show an example of a Docker Compose file with environment values stored in an external `.env` file, as described in the official Docker documentation. If you don't want to use this feature, **simply substitute any `${ }` variable with their values**.

##### Debug
If you want to pass environment values to the image through the `.env` file, I included a simple `debug` function that prints out on the standard output all the values.  
This should helps you to check if your configuration is running as you expect.

```
$ docker run \
    -e DB_NAME=${PSQL_DB} \
    -e DB_PWD=${PSQL_PASS} \
    -e DB_USER=${PSQL_USER} \
    --link oe_db:psql \
    -p 8069:8069 \
    --name openerp \
    lcrea/odoo:6.1 \
    debug
```

### Update plan
OpenERP v6.1 is no longer supported, thus, an update of it is quite meaningless. However, this image is based on Jessie, the latest supported Debian distribution.  
So, I've scheduled an automatic monthly rebuild of the image (on the **1st of every month**, to be precise) to guarantee a regular update of all the basic libraries required.

### Why this version?
This image is the result of part of one of my previous project, that I decided to share freely, hoping that could be helpful for anybody who's still working with this beautiful version of OpenERP (now Odoo) or just want to play with it.

### Support
If you have any issues, please report them to [https://github.com/lcrea/odoo-docker/issues](https://github.com/lcrea/odoo-docker/issues).  
If you made any improvements, please open a pull request to [https://github.com/lcrea/odoo-docker/pulls](https://github.com/lcrea/odoo-docker/pulls).

### Author
Luca Crea  
[https://www.linkedin.com/in/lucacrea](https://www.linkedin.com/in/lucacrea)
