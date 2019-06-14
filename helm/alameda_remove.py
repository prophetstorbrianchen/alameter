import os
import sys
import config


alamedaservice_path = config.alamedaservice_path
stackpoint_env = config.stackpoint_env

def remove_federator_operator():
    #os.system("git clone https://github.com/containers-ai/federatorai-operator.git /tmp/federatorai-operator")
    os.system("kubectl delete -f /tmp/federatorai-operator/deploy/upstream/")
    os.system("rm -rf /tmp/federatorai-operator")

def remove_prometheus():
    if stackpoint_env == "n":
        os.system("helm delete prometheus --purge")
    else:
        os.system("/tmp/alameter/helm/linux-amd64/helm delete prometheus --purge")
    
    os.system("kubectl delete crd/alertmanagers.monitoring.coreos.com crd/prometheuses.monitoring.coreos.com crd/prometheuses.monitoring.coreos.com crd/prometheusrules.monitoring.coreos.com crd/servicemonitors.monitoring.coreos.com")

def remove_alamedaservice():
    os.system("kubectl delete -f /tmp/alameter/helm/alamedaservice.yaml")
    os.system("kubectl delete ns alameda")

def remove_alamedascaler():
    cmd = "kubectl delete -f /tmp/alameter/helm/alamedascaler.yaml"
    os.system(cmd)

if __name__ == '__main__':

    ####remove_alamedascaler
    remove_alamedascaler()

    ####remove_alamedaservice
    remove_alamedaservice()

    ####remove_prometheus
    remove_prometheus()
    
    ####remove_federator_operator
    remove_federator_operator()

