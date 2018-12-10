FROM laniakeacloud/galaxy:18.05

MAINTAINER ma.tangaro@ibiom.cnr.it

ENV container docker

COPY ["playbook.yaml","/"]

# Install tools
ADD https://raw.githubusercontent.com/Laniakea-elixir-it/Scripts/master/galaxy_tools/install_tools.docker.sh /tmp/install_tools.sh
RUN chmod +x /tmp/install_tools.sh

RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-CoVaCS/galaxy-CoVaCS-tool-list-1.yml  -O /tmp/tools1.yml
RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-CoVaCS/galaxy-CoVaCS-tool-list-2.yml  -O /tmp/tools2.yml

RUN /tmp/install_tools.sh GALAXY_ADMIN_API_KEY /tmp/tools1.yml && \
    /export/tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    /tmp/install_tools.sh GALAXY_ADMIN_API_KEY /tmp/tools2.yml && \
    /export/tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null

RUN ansible-galaxy install indigo-dc.cvmfs-client
RUN ansible-galaxy install indigo-dc.galaxycloud-refdata

# Download refdata configuration file
ADD https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/cvmfs_server_keys/elixir-italy.covacs.refdata.pub /tmp/elixir-italy.covacs.refdata.pub
ADD https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/cvmfs_server_config_files/elixir-italy.covacs.refdata.conf /tmp/elixir-italy.covacs.refdata.conf

RUN echo "localhost" > /etc/ansible/hosts

# Install tools and configure cvmfs reference data
RUN ansible-playbook /playbook.yaml

# This overwrite docker-galaxy CMD line
# Mount cvmfs and start galaxy
CMD /bin/mount -t cvmfs elixir-italy.covacs.refdata /cvmfs/elixir-italy.covacs.refdata; /usr/local/bin/galaxy-startup; /usr/bin/sleep infinity
