#!/bin/bash
alameter_pwd=/tmp/alameter/helm
default_path=$alameter_pwd/linux-amd64/helm

while true
do
        read -p "First Install?(y or n): " answer

        if [ $answer == "y" ] || [ $answer == "Y" ]; then
                echo "========Download Alameter========"

                git clone https://github.com/prophetstorbrianchen/alameter.git /tmp/alameter

                echo "========Unzip helm tar.gz========"

                tar -C /tmp/alameter/helm -zxvf /tmp/alameter/helm/helm-v2.13.1-linux-amd64.tar.gz

                break
        elif [ $answer == "n" ] || [ $answer == "Y" ]; then
                break
        else
                echo "Please answer again"
        fi
done

echo "========Check Helm Tiller========"
tiller_number=`kubectl get pod -n kube-system | grep "tiller-deploy" | wc -l`
helm_client_version=`$default_path version | grep Client |awk '{print $2}' | sed 's/&version.Version{SemVer://g' | sed 's/,//g'`
helm_server_version=`$default_path version | grep Server |awk '{print $2}' | sed 's/&version.Version{SemVer://g' | sed 's/,//g'`
#echo $tiller_number
if [ $tiller_number == 0 ] || [ $helm_client_version != $helm_server_version ]; then
        echo "Need to install or upgrade Helm"
#        echo "$pwd/linux-amd64/helm"
        $alameter_pwd/linux-amd64/helm init --upgrade
        sleep 10
        $alameter_pwd/linux-amd64/helm init
        default_path=$alameter_pwd/linux-amd64/helm
        sleep 10
else
        echo "Helm Tiller had been installed"
fi

echo "========Install Alameda========"

python /tmp/alameter/helm/alameda_install.py

echo "========For old datahub name========"
sleep 5

#for i in `kubectl get pod -n alameda | grep datahub | awk '{print $1}'`;do kubectl expose pod $i --name datahub --type NodePort -n alameda --port 50050;done

echo "========Install Alameter========"
$default_path install $alameter_pwd/alameter-influxdb --name alameter-influxdb --namespace alameter

$default_path install $alameter_pwd/alameter --name alameter --namespace alameter

echo "========Check the helm list========"
$default_path list

echo "========Check the pod list========"
kubectl get pod --all-namespaces
