#!/bin/bash
pwd=`pwd`
alameter_pwd=/tmp/alameter/helm
default_path=$alameter_pwd/linux-amd64/helm

echo "====Alameda Remove===="
$default_path delete alameda --purge

$default_path delete alameda-grafana --purge

$default_path delete alameda-influxdb --purge

$default_path delete prometheus --purge

kubectl delete crd/alertmanagers.monitoring.coreos.com crd/prometheuses.monitoring.coreos.com crd/prometheuses.monitoring.coreos.com crd/prometheusrules.monitoring.coreos.com crd/servicemonitors.monitoring.coreos.com

echo "====Alameter Remove===="
$default_path delete alameter --purge

$default_path delete alameter-influxdb --purge

echo "====Check Helm List===="
$default_path list

kubectl delete ns alameda
