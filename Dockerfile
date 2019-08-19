# Galaxy - CoVaCS

FROM bgruening/galaxy-stable:19.01

MAINTAINER Tangaro Marco Antonio, ma.tangaro@ibiom.cnr.it

ENV GALAXY_CONFIG_BRAND="CoVaCS"

WORKDIR /galaxy-central

RUN add-tool-shed --url 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'

RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-CoVaCS/galaxy-CoVaCS-tool-list-1.yml -O $GALAXY_ROOT/tools1.yml
RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-CoVaCS/galaxy-CoVaCS-tool-list-2.yml -O $GALAXY_ROOT/tools2.yml

RUN install-tools $GALAXY_ROOT/tools1.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    rm /export/galaxy-central/ -rf

RUN install-tools $GALAXY_ROOT/tools2.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    rm /export/galaxy-central/ -rf

#TODO
#Install workflows
# change cvmfs setup

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
