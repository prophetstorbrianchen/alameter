#!/bin/bash
pwd=`pwd`
default_path=$pwd/linux-amd64/helm

while true
do 
	read -p "First Install?(y or n): " answer

	if [ $answer == "y" ] || [ $answer == "Y" ]; then
		echo "========Download Alameda========"

		git clone https://github.com/containers-ai/alameda

    cp -r $pwd/alameda/example/samples .

		cp -r $pwd/alameda/helm/prometheus-operator .

		cp -r $pwd/alameda/helm/influxdb .

		cp -r $pwd/alameda/helm/grafana .

		cp -r $pwd/alameda/helm/alameda $pwd/temp_alameda

		rm -rf $pwd/alameda

		mv $pwd/temp_alameda $pwd/alameda

		echo "========Unzip helm tar.gz========"

		tar -zxvf helm-v2.13.1-linux-amd64.tar.gz

		break
	elif [ $answer == "n" ] || [ $answer == "Y" ]; then
		break
	else
		echo "Please answer again"
	fi
done

echo "========Check Helm Tiller========"
tiller_number=`kubectl get pod -n kube-system | grep "tiller-deploy" | wc -l`
#echo $tiller_number
if [ $tiller_number == 0 ]; then
	echo "Need to install Helm"
#        echo "$pwd/linux-amd64/helm"
	$pwd/linux-amd64/helm init --upgrade
        $pwd/linux-amd64/helm init
	default_path=$pwd/linux-amd64/helm
	sleep 5
else
	echo "Helm Tiller had been installed"
fi

echo "========Install Alameda========"
$default_path install stable/influxdb --version 1.1.0 --name influxdb --namespace monitoring

$default_path install stable/prometheus-operator --version 4.3.1 --name prometheus --namespace monitoring -f ./prometheus-operator/values.yaml

$default_path install --name alameda --namespace alameda ./alameda --set image.repository=containersai/alameda-operator-rhel --set image.tag=masterdev.5 --set image.pullPolicy=Always --set evictioner.image.repository=containersai/alameda-evictioner-rhel --set evictioner.image.tag=0.3.6 --set image.pullPolicy=Always --set admission-controller.image.repository=containersai/alameda-admission-rhel --set admission-controller.image.tag=0.3.6 --set image.pullPolicy=Always --set datahub.image.repository=containersai/alameda-datahub-rhel --set datahub.image.tag=masterdev.5 --set datahub.image.pullPolicy=Always --set alameda-ai.image.repository=containersai/alameda-ai --set alameda-ai.image.tag=ri.7 --set alameda-ai.image.pullPolicy=Always --set alameda-ai.image.accessToken=ewogICAgImF1dGhzIjogewogICAgICAgICJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOiB7CiAgICAgICAgICAgICJhdXRoIjogIlkyOXVkR0ZwYm1WeWMyRnBPbVZ1YldsMGVTMXVaV1F0YTJ0ciIKICAgICAgICB9CiAgICB9Cn0K

$default_path install --name grafana --namespace monitoring ./grafana/

echo "========For old datahub name========"
sleep 5
for i in `kubectl get pod -n alameda | grep datahub | awk '{print $1}'`;do kubectl expose pod $i --name datahub --type NodePort -n alameda --port 50050;done

echo "========Install Alameter========"
$default_path install ./alameter-influxdb --name alameter-influxdb --namespace alameter

$default_path install ./alameter --name alameter --namespace alameter

echo "========Check the helm list========"
$default_path list

