FROM freeradius/freeradius-server

ENV CRON_SCHEDULE="*/1 * * * *"

# install packages
RUN apt-get update && \
    apt-get install -y python3 python3-openpyxl cron


# change files
RUN mkdir -p /config/exec.d/ && \
    mkdir -p /examples && \
    sed -i 's/auth = no$/auth = yes/' /etc/freeradius/radiusd.conf && \
    echo "# include config file\n\$INCLUDE /config/clients.conf\n" >> /etc/freeradius/clients.conf && \
    echo "# include config file\n\$INCLUDE /config/huntgroups\n" >> /etc/freeradius/huntgroups && \
    sed -i '1i# include config file\n$INCLUDE /config/users\n' /etc/freeradius/users

# copy examples
COPY example-bash /examples/example-bash
COPY example-python /examples/example-python

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh    
ENTRYPOINT ["/docker-entrypoint.sh"]



