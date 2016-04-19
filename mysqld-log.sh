#!/bin/sh

exec chpst -u mysql svlogd -tt /var/log/mysqld/
