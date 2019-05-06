# Alameda Helm Chart

* Installs the brain of Kubernetes resource orchestration [Alameda](https://github.com/containers-ai/alameda)

## Alameda components
- operator
- alameda-ai
- datahub
- Prometheus
- InfluxDB
- Grafana (optional)

In this Helm chart, *operator*, *alameda-ai*, *datahub* will be deployed and connections to Prometheus and InfluxDB will be configured.

## Requirements

Alameda levarages Prometheus to collect metrics and InfluxDB to store predictions with the following requirements.

1. Alameda requires a running Prometheus with following data exporters and record rules:  
  - Data Exporters  
    - cAdvisor
    - [Node exporter](https://github.com/prometheus/node_exporter)
    - [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
  - Recording Rules:   
    ```
    groups:
    - name: k8s.rules
      rules:
      - expr: |
          sum(rate(container_cpu_usage_seconds_total{image!="", container_name!=""}[5m])) by (namespace)
        record: namespace:container_cpu_usage_seconds_total:sum_rate
      - expr: |
          sum by (namespace, pod_name, container_name) (
            rate(container_cpu_usage_seconds_total{container_name!=""}[5m])
          )
        record: namespace_pod_name_container_name:container_cpu_usage_seconds_total:sum_rate
      - expr: |
          sum(container_memory_usage_bytes{image!="", container_name!=""}) by (namespace)
        record: namespace:container_memory_usage_bytes:sum
        - expr: max by (kubernetes_node, kubernetes_namespace, kubernetes_pod) 
            (label_replace(
              label_replace(
                label_replace(kube_pod_info{job="kubernetes-service-endpoints"}, "kubernetes_node", "$1", "node", "(.*)"),
              "kubernetes_namespace", "$1", "namespace", "(.*)"),
            "kubernetes_pod", "$1", "pod", "(.*)"))
          record: "node_namespace_pod:kube_pod_info:"
        - expr: label_replace(node_cpu_seconds_total, "cpu", "$1", "cpu", "cpu(.+)")
          record: node_cpu
        - expr: label_replace(1 - avg by (kubernetes_node) (rate(node_cpu{job="kubernetes-service-endpoints",mode="idle"}[1m]) * on(kubernetes_namespace, kubernetes_pod) group_left(node) node_namespace_pod:kube_pod_info:), "node", "$1", "kubernetes_node", "(.*)")
          record: node:node_cpu_utilisation:avg1m
        - expr: node_memory_MemTotal_bytes
          record: node_memory_MemTotal
        - expr: node_memory_MemFree_bytes
          record: node_memory_MemFree
        - expr: node_memory_Cached_bytes
          record: node_memory_Cached
        - expr: node_memory_Buffers_bytes
          record: node_memory_Buffers
        - expr: label_replace(sum
            by (kubernetes_node) ((node_memory_MemFree{job="kubernetes-service-endpoints"} + node_memory_Cached{job="kubernetes-service-endpoints"}
            + node_memory_Buffers{job="kubernetes-service-endpoints"}) * on(kubernetes_namespace, kubernetes_pod) group_left(kubernetes_node)
            node_namespace_pod:kube_pod_info:), "node", "$1", "kubernetes_node", "(.*)")
          record: node:node_memory_bytes_available:sum
        - expr: label_replace(sum
            by(kubernetes_node) (node_memory_MemTotal{job="kubernetes-service-endpoints"} * on(kubernetes_namespace, kubernetes_pod)
            group_left(kubernetes_node) node_namespace_pod:kube_pod_info:), "node", "$1", "kubernetes_node", "(.*)")
          record: node:node_memory_bytes_total:sum
    ```
2. Alameda requires a running InfluxDB. It will create database *cluster_status*, *recommendation* and *prediction* if they does not exist.

## TL;DR;

```console
$ git clone https://github.com/containers-ai/alameda
$ cd alameda/helm/alameda
$ helm install --name alameda --namespace alameda .
```
It will deploy Alameda in *alameda* namespace with *alameda* release name.

## Installing the Chart

To install the chart into `my-namespace` namespace with the release name `my-release`:

```console
$ helm install --name my-release --namespace my-namespace .
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


