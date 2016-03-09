# ------------------------------------------------------------------------
#
# Copyright 2005-2015 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
#
# ------------------------------------------------------------------------

FROM wso2/base:1.0.0
MAINTAINER dev@wso2.org

# Build time arguments
ARG WSO2_SERVER
ARG WSO2_SERVER_VERSION
ARG WSO2_SERVER_PROFILE
ARG WSO2_ENVIRONMENT

# Carbon server information
ENV WSO2_SERVER=${WSO2_SERVER:-wso2cep} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION:-4.0.0} \
    WSO2_SERVER_PROFILE=${WSO2_SERVER_PROFILE:-default} \
    WSO2_ENVIRONMENT=${WSO2_ENVIRONMENT:-dev}

COPY scripts/init.sh /usr/local/bin/init.sh
COPY puppet/ /etc/puppet/

# Export facter variables
ENV FACTER_product_name=${WSO2_SERVER} \
    FACTER_product_version=${WSO2_SERVER_VERSION} \
    FACTER_product_profile=${WSO2_SERVER_PROFILE} \
    FACTER_environment=${WSO2_ENVIRONMENT} \
    FACTER_vm_type=docker

# Execute puppet apply and clean after
WORKDIR /etc/puppet
RUN puppet apply -e "include ${WSO2_SERVER}" --hiera_config=/etc/puppet/hiera.yaml \
    && apt-get purge -y --auto-remove puppet \
    && rm -rf /etc/puppet/* \
    && rm -rf /var/lib/apt/lists/* \
    && chown wso2user:wso2 /usr/local/bin/init.sh \
    && chown -R wso2user:wso2 /mnt

USER wso2user

# Expose transport ports
EXPOSE 7611 7711 9763 9443 9611 9711

ENTRYPOINT /usr/local/bin/init.sh
