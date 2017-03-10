FROM debian:jessie
MAINTAINER Luca Crea <lucacrea@yahoo.it>

ENV OE_PATH /var/lib/openerp
ENV OE_USER openerp

# @BUGFIX: it's necessary to git to clone within Docker
ENV GIT_SSL_NO_VERIFY true


##
# Install required Python modules and various dependencies
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libreoffice-script-provider-python \
        locales \
        python-cairo \
        python-dateutil \
        python-feedparser \
        python-gdata \
        python-genshi \
        python-imaging \
        python-ldap \
        python-libxslt1 \
        python-lxml \
        python-mako \
        python-openid \
        python-psycopg2 \
        python-pybabel \
        python-pychart \
        python-pydot \
        python-pyparsing \
        python-reportlab \
        python-setuptools \
        python-simplejson \
        python-tz \
        python-uno \
        python-vatnumber \
        python-vobject \
        python-webdav \
        python-xlwt \
        python-yaml \
        python-zsi \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# @BUGFIX: otherwise attachments accented filenames will be corrupted
ENV LANG en_US.utf8


##
# Install Aeroolib + Aeroo Reports modules + Werkzeug library (old version)
#
# @BUGFIX
# Python Werkzeug 0.9.x installed by default in Debian it's unable to handle
# PDFs print processes. The only solution is to downgrade to 0.8.x version...
# or to upgrade OpenERP :-)
#
# Aeroolib: old version (v1.2.0)
# http://www.alistek.com/images/stories/downloads/aeroolib/aeroolib.tar.gz
#
# Aeroolib: latest version
# https://github.com/aeroo/aeroolib
RUN set -x \
    && TMP_PKGS="\
        bzr \
        git \
        python-pip \
    " \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${TMP_PKGS} \
    # aeroolib
    && AEROODIR=$(mktemp -d) \
    && git clone -b master --depth 1 "https://github.com/aeroo/aeroolib.git" ${AEROODIR} \
    && cd ${AEROODIR} \
    && python setup.py install \
    # aeroo reports
    && bzr branch lp:aeroo/openerp6.1.x /var/lib/aeroo_reports \
    && rm -rf /var/lib/aeroo_reports/.bzr \
    # werkzeug
    && pip install werkzeug==0.8.3 \
    # cleanup
    && apt-get purge -y --auto-remove ${TMP_PKGS} \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf ${AEROODIR}


##
# Install OpenERP (v6.1) + wkhtmltopdf static (v0.12.4)
#
# @BUGFIX
# wkhtmltopdf must be the static version, otherwise the reports don't work and
# OperERP returns an error.
#
# wkhtmltopdf latest version is available at this link:
# http://wkhtmltopdf.org/downloads.html
RUN set -x \
    && TMP_PKGS="\
        curl \
        git \
        xzdec \
    " \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${TMP_PKGS} \
    # wkhtmltopdf
    && cd /usr/local/bin \
    && curl -fSL "http://download.gna.org/wkhtmltopdf/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz" -o wkhtmltox.tar.xz \
    && xzdec wkhtmltox.tar.xz > wkhtmltox.tar \
    && tar xvf wkhtmltox.tar wkhtmltox/bin/wkhtmltopdf \
    && mv -v wkhtmltox/bin/wkhtmltopdf . \
    && chown root:root wkhtmltopdf \
    && chmod 755 wkhtmltopdf \
    && ln -sv $(pwd)/wkhtmltopdf /usr/bin/wkhtmltopdf \
    && rm -vrf wkhtmltox* \
    # OpenERP
    && mkdir -pv -m 750 ${OE_PATH} \
    && git clone -b 6.1 --depth 1 "https://github.com/odoo/odoo.git" ${OE_PATH} \
    && rm -rf ${OE_PATH}/.git* \
    # cleanup
    && apt-get purge -y --auto-remove ${TMP_PKGS} \
    && rm -rf /var/lib/apt/lists/*


##
# Fixing permissions + Setting default dirs
COPY ./entrypoint.sh /
COPY ./openerp-server.conf /etc/openerp/

RUN set -x \
    && DIRS_NEW=" \
        /mnt/extra-addons \
        /run/openerp \
        ${OE_PATH}/filestore \
    " \
    && DIRS_2FIX=" \
        /etc/openerp \
        /var/lib/aeroo_reports \
    " \
    # create user and group
    && addgroup --system --gid 600 ${OE_USER} \
    && adduser --home ${OE_PATH} --system --shell /sbin/nologin --gid 600 --uid 600 ${OE_USER} \
    # create default directories
    && mkdir -pv -m 750 ${DIRS_NEW} \
    # fixing file permissions
    && find ${OE_PATH} ${DIRS_NEW} ${DIRS_2FIX} -exec chown ${OE_USER}:${OE_USER} {} \+ \
    && find ${OE_PATH} ${DIRS_NEW} ${DIRS_2FIX} -type d -exec chmod 750 {} \+ \
    && find ${OE_PATH} ${DIRS_NEW} ${DIRS_2FIX} -type f -exec chmod 640 {} \+ \
    && find ${OE_PATH} ${DIRS_NEW} ${DIRS_2FIX} -type f -name '*.sh' -exec chmod 750 {} \+ \
    && chmod 755 /entrypoint.sh


VOLUME ["${OE_PATH}/filestore", "/mnt/extra-addons"]

EXPOSE 8069 8070

WORKDIR /${OE_PATH}

USER ${OE_USER}

ENTRYPOINT ["/entrypoint.sh"]

CMD ["openerp-server"]
