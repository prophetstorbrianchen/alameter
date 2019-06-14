import os
import sys
import config


alamedaservice_path = config.alamedaservice_path
stackpoint_env = config.stackpoint_env

def alamedaservice_edit_version(path,version):

    temp_list = []

    with open(path, 'r') as f:
        for line in f:
            #print(line)
            #print('------------------')
            temp_list.append(line)

    with open(path, 'w') as f:
        for line in temp_list:
            if "version" in line:
                f.write("  version: " + version + "\n")
            else:
                f.write(line)

def install_federator_operator():
    os.system("git clone https://github.com/containers-ai/federatorai-operator.git /tmp/federatorai-operator")
    os.system("kubectl apply -f /tmp/federatorai-operator/deploy/upstream/")

def install_prometheus():
    if stackpoint_env == "n":
        #print("stackpoint_env is no")
        os.system("helm install stable/prometheus-operator --version 5.5.1 --name prometheus --namespace monitoring")
    else:
        #print("stackpoint_env is yes")
        os.system("/tmp/alameter/helm/linux-amd64/helm install stable/prometheus-operator --version 5.5.1 --name prometheus --namespace monitoring")

def install_alamedaservice():
    os.system("kubectl create ns alameda")
    os.system("kubectl apply -f /tmp/alameter/helm/alamedaservice.yaml")

def install_alamedascaler():
    cmd = "kubectl apply -f /tmp/alameter/helm/alamedascaler.yaml"
    os.system(cmd)

if __name__ == '__main__':

    alameda_version = raw_input("Please input alameda version(ex:v0.3.25):")
    print(alameda_version)

    ####install_federator_operator
    install_federator_operator()

    ####install promisue
    install_prometheus()

    ####install_alamedaservice
    alamedaservice_edit_version(alamedaservice_path,alameda_version)
    install_alamedaservice()

    ####install_alamedascaler
    install_alamedascaler()
