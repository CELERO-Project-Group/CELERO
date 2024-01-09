FROM postgres:13
# Original Maintainer: MAINTAINER Mike Dillon <mike@appropriate.io>
# md: Added installs of plpython and pgrouting and removed version info

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
	   postgresql-plpython3-13 \
      && rm -rf /var/lib/apt/lists/*

# Create directory for SQL dump files
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy the SQL dump file into the container
COPY ecoman_01_10.sql /docker-entrypoint-initdb.d/

# Set appropriate permissions to the SQL dump file
RUN chown postgres:postgres /docker-entrypoint-initdb.d/ecoman_01_10.sql
RUN chmod 755 /docker-entrypoint-initdb.d/ecoman_01_10.sql

#To Import the SQL dump to postgres you need to execute the follong command in the "celerodb" docker container: 
#psql -U postgres -d ecoman_01_10 < docker-entrypoint-initdb.d/ecoman_01_10.sql

# RUN chown -R celero:celero /var/lib/postgresql/data
# RUN chmod -R 0777 /var/lib/postgresql/data
