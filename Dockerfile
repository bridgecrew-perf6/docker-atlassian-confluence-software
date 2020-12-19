FROM ubuntu:20.04

RUN echo "Europe/Berlin" > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive
# Configuration variables.
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  7.9.0

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
RUN apt-get update  \
&&  apt-get install curl -y \
&&  apt-get install net-tools -y \
&&  apt-get install nano -y \
&&  apt-get install sudo -y \
&&  apt-get install ufw -y \
&&  apt-get install wget -y \
&&sudo /usr/sbin/useradd --create-home --comment "Account for running Confluence" --shell /bin/bash confluence \
&&  apt-get install openjdk-8-jre -y \
&&  apt-get install mysql-server -y \
    &&  apt-get install mysql-client -y \
#Confluence Configuration
&& mkdir -p                "${CONF_HOME}" \
&& chmod -R 700            "${CONF_HOME}" \
&& chown -R confluence:confluence  "${CONF_HOME}" \
&& chmod -R u=rwx,go-rwx "${CONF_HOME}" \
&& chmod -R o-x "${CONF_HOME}" \
&& mkdir -p                "${CONF_INSTALL}/conf" \
&& curl -Ls               "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
&& curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.44.tar.gz" | tar -xz --directory "${CONF_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.44/mysql-connector-java-5.1.44-bin.jar" \
&& chown -R confluence:confluence  "${CONF_INSTALL}" \
&& chmod -R u=rwx,go-rwx  "${CONF_INSTALL}" \
&& echo -e                 "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
&& touch -d "@0"           "${CONF_INSTALL}/conf/server.xml" \


# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER confluence:confluence

# Expose default HTTP connector port.
EXPOSE 8090

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/confluence


# Run Atlassian Confluence as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/start-confluence.sh", "-fg"]
