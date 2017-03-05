#!/bin/bash

# Terminate the script if a command exits non-zero
set -e

# If none of these variables are set, uses default values.
: ${DB_HOST:="psql"}
: ${DB_NAME:="openerp"}
: ${DB_PORT:=5432}
: ${DB_PWD:="openerp"}
: ${DB_USER:="openerp"}

OE_ARGS=(
    "--config=/etc/openerp/openerp-server.conf"
    "--database=${DB_NAME}"
    "--db_host=${DB_HOST}"
    "--db_password=${DB_PWD}"
    "--db_port=${DB_PORT}"
    "--db_user=${DB_USER}"
    "--pidfile=/run/openerp/openerp.pid"
)

case "$1" in
    -- | openerp-server)
        shift
        exec python openerp-server "${OE_ARGS[@]}" "$@"
        ;;
    -*)
        exec python openerp-server "$@"
        ;;
    debug)
        echo "OpenERP parameters:" "${OE_ARGS[@]}"
        exit 1
        ;;
    *)
        exec "$@"
esac

exit 1
