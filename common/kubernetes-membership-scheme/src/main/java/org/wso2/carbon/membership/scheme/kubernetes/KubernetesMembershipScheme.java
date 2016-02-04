/*
 * Copyright (c) 2005-2015, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.carbon.membership.scheme.kubernetes;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hazelcast.config.Config;
import com.hazelcast.config.NetworkConfig;
import com.hazelcast.config.TcpIpConfig;
import com.hazelcast.core.*;
import org.apache.axis2.clustering.ClusteringFault;
import org.apache.axis2.clustering.ClusteringMessage;
import org.apache.axis2.description.Parameter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.core.clustering.hazelcast.HazelcastCarbonClusterImpl;
import org.wso2.carbon.core.clustering.hazelcast.HazelcastMembershipScheme;
import org.wso2.carbon.core.clustering.hazelcast.HazelcastUtil;
import org.wso2.carbon.membership.scheme.kubernetes.api.KubernetesApiEndpoint;
import org.wso2.carbon.membership.scheme.kubernetes.api.KubernetesHttpApiEndpoint;
import org.wso2.carbon.membership.scheme.kubernetes.api.KubernetesHttpsApiEndpoint;
import org.wso2.carbon.membership.scheme.kubernetes.domain.Address;
import org.wso2.carbon.membership.scheme.kubernetes.domain.Endpoints;
import org.wso2.carbon.membership.scheme.kubernetes.domain.Subset;
import org.wso2.carbon.utils.xml.StringUtils;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Kubernetes membership scheme provides carbon cluster discovery on kubernetes.
 */
public class KubernetesMembershipScheme implements HazelcastMembershipScheme {

    private static final Log log = LogFactory.getLog(KubernetesMembershipScheme.class);

    private static final String PARAMETER_NAME_KUBERNETES_MASTER = "KUBERNETES_MASTER";
    private static final String PARAMETER_NAME_KUBERNETES_MASTER_USERNAME = "KUBERNETES_MASTER_USERNAME";
    private static final String PARAMETER_NAME_KUBERNETES_MASTER_PASSWORD = "KUBERNETES_MASTER_PASSWORD";
    private static final String PARAMETER_NAME_KUBERNETES_NAMESPACE = "KUBERNETES_NAMESPACE";
    private static final String PARAMETER_NAME_KUBERNETES_SERVICES = "KUBERNETES_SERVICES";
    private static final String ENDPOINTS_API_CONTEXT = "/api/v1/namespaces/%s/endpoints/";

    private final Map<String, Parameter> parameters;
    private final NetworkConfig nwConfig;
    private final List<ClusteringMessage> messageBuffer;
    private HazelcastInstance primaryHazelcastInstance;
    private HazelcastCarbonClusterImpl carbonCluster;

    public KubernetesMembershipScheme(Map<String, Parameter> parameters,
                                      String primaryDomain,
                                      Config config,
                                      HazelcastInstance primaryHazelcastInstance,
                                      List<ClusteringMessage> messageBuffer) {
        this.parameters = parameters;
        this.primaryHazelcastInstance = primaryHazelcastInstance;
        this.messageBuffer = messageBuffer;
        this.nwConfig = config.getNetworkConfig();
    }

    @Override
    public void setPrimaryHazelcastInstance(HazelcastInstance primaryHazelcastInstance) {
        this.primaryHazelcastInstance = primaryHazelcastInstance;
    }

    @Override
    public void setLocalMember(Member localMember) {
    }

    @Override
    public void setCarbonCluster(HazelcastCarbonClusterImpl hazelcastCarbonCluster) {
        this.carbonCluster = hazelcastCarbonCluster;
    }

    @Override
    public void init() throws ClusteringFault {
        try {
            log.info("Initializing kubernetes membership scheme...");

            nwConfig.getJoin().getMulticastConfig().setEnabled(false);
            nwConfig.getJoin().getAwsConfig().setEnabled(false);
            TcpIpConfig tcpIpConfig = nwConfig.getJoin().getTcpIpConfig();
            tcpIpConfig.setEnabled(true);

            // Try to read parameters from env variables
            String kubernetesMaster = System.getenv(PARAMETER_NAME_KUBERNETES_MASTER);
            String kubernetesNamespace = System.getenv(PARAMETER_NAME_KUBERNETES_NAMESPACE);
            String kubernetesServices = System.getenv(PARAMETER_NAME_KUBERNETES_SERVICES);
            String kubernetesMasterUsername = System.getenv(PARAMETER_NAME_KUBERNETES_MASTER_USERNAME);
            String kubernetesMasterPassword = System.getenv(PARAMETER_NAME_KUBERNETES_MASTER_PASSWORD);

            // If not available read from clustering configuration
            if(StringUtils.isEmpty(kubernetesMaster)) {
                kubernetesMaster = getParameterValue(PARAMETER_NAME_KUBERNETES_MASTER);
                if(StringUtils.isEmpty(kubernetesMaster)) {
                    throw new ClusteringFault("Kubernetes master parameter not found");
                }
            }
            if(StringUtils.isEmpty(kubernetesNamespace)) {
                kubernetesNamespace = getParameterValue(PARAMETER_NAME_KUBERNETES_NAMESPACE, "default");
            }
            if(StringUtils.isEmpty(kubernetesServices)) {
                kubernetesServices = getParameterValue(PARAMETER_NAME_KUBERNETES_SERVICES);
                if(StringUtils.isEmpty(kubernetesServices)) {
                    throw new ClusteringFault("Kubernetes services parameter not found");
                }
            }

            if(StringUtils.isEmpty(kubernetesMasterUsername)) {
                kubernetesMasterUsername = getParameterValue(PARAMETER_NAME_KUBERNETES_MASTER_USERNAME, "");
            }

            if(StringUtils.isEmpty(kubernetesMasterPassword)) {
                kubernetesMasterPassword = getParameterValue(PARAMETER_NAME_KUBERNETES_MASTER_PASSWORD, "");
            }

            log.info(String.format("Kubernetes clustering configuration: [master] %s [namespace] %s [services] %s",
                    kubernetesMaster, kubernetesNamespace, kubernetesServices));

            String[] kubernetesServicesArray = kubernetesServices.split(",");
            for (String kubernetesService : kubernetesServicesArray) {
                List<String> containerIPs = findContainerIPs(kubernetesMaster,
                        kubernetesNamespace, kubernetesService, kubernetesMasterUsername, kubernetesMasterPassword);
                for(String containerIP : containerIPs) {
                    tcpIpConfig.addMember(containerIP);
                    log.info("Member added to cluster configuration: [container-ip] " + containerIP);
                }
            }
            log.info("Kubernetes membership scheme initialized successfully");
        } catch (IOException e) {
            throw new ClusteringFault("Kubernetes membership initialization failed", e);
        }
    }

    private String getParameterValue(String parameterName) throws ClusteringFault {
        return getParameterValue(parameterName, null);
    }

    private String getParameterValue(String parameterName, String defaultValue) throws ClusteringFault {
        Parameter kubernetesServicesParam = getParameter(parameterName);
        if (kubernetesServicesParam == null) {
            if (defaultValue == null) {
                throw new ClusteringFault(parameterName + " parameter not found");
            } else {
                return defaultValue;
            }
        }
        return (String) kubernetesServicesParam.getValue();
    }

    private List<String> findContainerIPs(String kubernetesMaster, String namespace, String serviceName, String username, String password)
            throws IOException {
        final String path = String.format(ENDPOINTS_API_CONTEXT, namespace);

        final List<String> containerIPs = new ArrayList<String>();

        URL url = new URL(kubernetesMaster + path + serviceName);
        if (log.isDebugEnabled()) {
            log.debug("Resource location: " + kubernetesMaster + path + serviceName);
        }

        KubernetesApiEndpoint k8sApiEndpoint = null;
        if (url.getProtocol().equalsIgnoreCase("https")) {
            k8sApiEndpoint = new KubernetesHttpsApiEndpoint(url);

        } else if (url.getProtocol().equalsIgnoreCase("http")) {
            k8sApiEndpoint = new KubernetesHttpApiEndpoint(url);

        } else {
            String errorMsg = "K8s master API endpoint is neither HTTP or HTTPS";
            log.error(errorMsg);
            throw new RuntimeException(errorMsg);
        }

        Endpoints endpoints = null;
        try {
            // use basic auth to create the connection if username and password are specified
            if (!StringUtils.isEmpty(username) && !StringUtils.isEmpty(password)) {
                k8sApiEndpoint.createConnection(username, password);
            } else {
                k8sApiEndpoint.createConnection();
            }

            // read from the API endpoint
            endpoints = getEndpoints(k8sApiEndpoint.read());
        } catch (Exception e) {
            // no need to throw
            log.error(e.getMessage(), e);
        } finally {
            k8sApiEndpoint.disconnect();
        }

        if (endpoints != null) {
            if (endpoints.getSubsets() != null && !endpoints.getSubsets().isEmpty()) {
                for (Subset subset : endpoints.getSubsets()) {
                    for (Address address : subset.getAddresses()) {
                        containerIPs.add(address.getIp());
                    }
                }
            }
        } else {
            log.info("No endpoints found at " + url.toString());
        }

        return containerIPs;
    }

    private Endpoints getEndpoints (InputStream inputStream) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readValue(inputStream, Endpoints.class);
    }

    @Override
    public void joinGroup() throws ClusteringFault {
        primaryHazelcastInstance.getCluster().addMembershipListener(new KubernetesMembershipSchemeListener());
    }

    public Parameter getParameter(String name) {
        return parameters.get(name);
    }

    /**
     * Stratos membership listener.
     */
    private class KubernetesMembershipSchemeListener implements MembershipListener {

        @Override
        public void memberAdded(MembershipEvent membershipEvent) {
            Member member = membershipEvent.getMember();

            // send all cluster messages
            carbonCluster.memberAdded(member);
            log.info("Member joined [" + member.getUuid() + "]: " + member.getInetSocketAddress().toString());
            // Wait for sometime for the member to completely join before replaying messages
            try {
                Thread.sleep(5000);
            } catch (InterruptedException ignored) {
            }
            HazelcastUtil.sendMessagesToMember(messageBuffer, member, carbonCluster);
        }

        @Override
        public void memberRemoved(MembershipEvent membershipEvent) {
            Member member = membershipEvent.getMember();
            carbonCluster.memberRemoved(member);
            log.info("Member left [" + member.getUuid() + "]: " + member.getInetSocketAddress().toString());
        }

        @Override
        public void memberAttributeChanged(MemberAttributeEvent memberAttributeEvent) {
            if (log.isDebugEnabled()) {
                log.debug("Member attribute changed: [" + memberAttributeEvent.getKey() + "] " +
                        memberAttributeEvent.getValue());
            }
        }
    }
}