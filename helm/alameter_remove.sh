#!/bin/bash
pwd=`pwd`
alameter_pwd=/tmp/alameter/helm
default_path=$alameter_pwd/linux-amd64/helm

echo "====Alameda Remove===="
python alameda_remove.py

echo "====Alameter Remove===="
$default_path delete alameter --purge

$default_path delete alameter-influxdb --purge

kubectl delete ns alameter

echo "====Check Helm List===="
$default_path list

echo "====Check Pod List===="
kubectl get pod --all-namespaces
