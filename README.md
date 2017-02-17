# Odoo & OpenERP Docker Images

This is a fork of the [Official Odoo repository](https://github.com/odoo/docker) on GitHub with some personal touch :sunglasses:  
I've chosen to divide this project in two main categories:
-   Odoo (versions 8/9/10)
-   OpenERP (version 6.1)

See below each one for more details.

---

## Odoo

Built exactly upon **the same Dockerfiles of the official ones**, but with these main differences:

1.  Always providing **the latest revision** of Odoo available on the nightly build servers, with a **regular update**.
1.  Fixing this boring issue: "[Error creating a new database](https://github.com/odoo/docker/issues/97)".

### To whom is this image for?
Anyone who wants to use Odoo through Docker, but with higher update frequency than the official one.

### What if I want to build it by myself?
All the necessary files are freely downloadable from this repo "[odoo-docker](https://github.com/lcrea/odoo-docker)", grouped by versions. You can simply clone the entire repository or download every single file you need and build your own image.

#### IMPORTANT
When it comes the time to update your image, please pay attention to **disable the cache of Docker** adding this flag `--no-cache` like this:

`docker build --no-cache -t my/odoo .`

This is necessary, because the `Dockerfile` is structured to always fetch the latest version from the nightly build servers, but the `Dockerfile` itself remains unchanged!  
So, if you don't disable the cache during the building process, Docker will not find any variation on the `Dockerfile` and it will reuse the cache version, returning to you exactly the latest image you have previously compiled.

### If do I need help?
As I said, because this image is quite the same as the official one, if you need any help or any information, please refer to the Official repositories at these links:  

-   [Odoo Official: GitHub](https://github.com/odoo/docker)
-   [Odoo Official: Docker](https://registry.hub.docker.com/_/odoo/)  

---

## OpenERP v6.1

Will be available very soon. Stay tuned :wink:
