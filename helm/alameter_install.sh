#!/bin/bash
pwd=`pwd`
alameter_pwd=/tmp/alameter/helm
default_path=$alameter_pwd/linux-amd64/helm

while true
do
        read -p "First Install?(y or n): " answer

        if [ $answer == "y" ] || [ $answer == "Y" ]; then
                echo "========Download Alameda========"

                git clone https://github.com/containers-ai/alameda

                cp -r $pwd/alameda/example/samples $alameter_pwd

                cp -r $pwd/alameda/helm/prometheus-operator $alameter_pwd

                cp -r $pwd/alameda/helm/influxdb $alameter_pwd

                cp -r $pwd/alameda/helm/grafana $alameter_pwd

                cp -r $pwd/alameda/helm/alameda $alameter_pwd/alameda

                rm -rf $pwd/alameda

                #mv $pwd/temp_alameda $pwd/alameda

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
$default_path install stable/influxdb --version 1.1.0 --name influxdb --namespace monitoring

$default_path install stable/prometheus-operator --version 4.3.1 --name prometheus --namespace monitoring -f $alameter_pwd/prometheus-operator/values.yaml

$default_path install --name alameda --namespace alameda $alameter_pwd/alameda --set image.repository=containersai/alameda-operator-rhel --set image.tag=masterdev.5 --set image.pullPolicy=Always --set evictioner.image.repository=containersai/alameda-evictioner-rhel --set evictioner.image.tag=0.3.6 --set image.pullPolicy=Always --set admission-controller.image.repository=containersai/alameda-admission-rhel --set admission-controller.image.tag=0.3.6 --set image.pullPolicy=Always --set datahub.image.repository=containersai/alameda-datahub-rhel --set datahub.image.tag=masterdev.5 --set datahub.image.pullPolicy=Always --set alameda-ai.image.repository=containersai/alameda-ai --set alameda-ai.image.tag=ri.7 --set alameda-ai.image.pullPolicy=Always --set alameda-ai.image.accessToken=ewogICAgImF1dGhzIjogewogICAgICAgICJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOiB7CiAgICAgICAgICAgICJhdXRoIjogIlkyOXVkR0ZwYm1WeWMyRnBPbVZ1YldsMGVTMXVaV1F0YTJ0ciIKICAgICAgICB9CiAgICB9Cn0K

$default_path install --name grafana --namespace monitoring $alameter_pwd/grafana

echo "========For old datahub name========"
sleep 5

for i in `kubectl get pod -n alameda | grep datahub | awk '{print $1}'`;do kubectl expose pod $i --name datahub --type NodePort -n alameda --port 50050;done

echo "========Install Alameter========"
$default_path install $alameter_pwd/alameter-influxdb --name alameter-influxdb --namespace alameter

$default_path install $alameter_pwd/alameter --name alameter --namespace alameter

echo "========Check the helm list========"
$default_path list
