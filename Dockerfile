FROM centos:latest

MAINTAINER EasyMetrics

# Postgresql version
# ...
ENV PG_VERSION 9.5
ENV PGVERSION 95

# Set the environment variables
# ...
ENV HOME /var/lib/pgsql
ENV PGDATA /var/lib/pgsql/9.5/data

# Install postgresql and run InitDB
# ...
RUN rpm -vih https://download.postgresql.org/pub/repos/yum/$PG_VERSION/redhat/rhel-7-x86_64/pgdg-centos$PGVERSION-$PG_VERSION-2.noarch.rpm && \
    yum update -y && \
    yum install -y sudo \
    pwgen \
    postgresql$PGVERSION \
    postgresql$PGVERSION-server \
    postgresql$PGVERSION-contrib && \
    yum clean all

# Copy
# ...
COPY ./.docker/postgresql_scripts/postgresql-setup.sh /usr/pgsql-$PG_VERSION/bin/postgresql$PGVERSION-setup

# Working directory
# ...
WORKDIR /var/lib/pgsql

# Run initdb
# ...
RUN su root /usr/pgsql-$PG_VERSION/bin/postgresql$PGVERSION-setup initdb

# Copy config file
# ...
COPY ./.docker/postgresql_scripts/postgresql.conf /var/lib/pgsql/$PG_VERSION/data/postgresql.conf
COPY ./.docker/postgresql_scripts/pg_hba.conf /var/lib/pgsql/$PG_VERSION/data/pg_hba.conf
COPY ./.docker/postgresql_scripts/postgresql.sh /usr/local/bin/postgresql.sh

# Change own user
# ...
RUN chown -R postgres:postgres /var/lib/pgsql/$PG_VERSION/data/* && \
    usermod -G wheel postgres && \
    sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers && \
    chmod +x /usr/local/bin/postgresql.sh

# Set volume
# ...
VOLUME ["/var/lib/pgsql"]

# Set username
# ...
USER postgres

EXPOSE 5432

CMD ["/bin/bash", "/usr/local/bin/postgresql.sh"]
