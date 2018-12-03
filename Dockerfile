FROM laniakeacloud/galaxy:18.05

MAINTAINER ma.tangaro@ibiom.cnr.it

ENV container docker

COPY ["playbook.yaml","/"]

RUN ansible-galaxy install indigo-dc.galaxycloud-tools
RUN ansible-galaxy install indigo-dc.galaxycloud-tooldeps
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
