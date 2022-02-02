FROM postgres:13
# Original Maintainer: MAINTAINER Mike Dillon <mike@appropriate.io>
# md: Added installs of plpython and pgrouting and removed version info

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
	   postgresql-plpython3-13 \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
