{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "admission-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "admission-controller.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "admission-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Use admission-controller.<namespace> as the Common Name in the certificate
*/}}
{{- define "admission-controller.certCommonName" -}}
{{- printf "admission-controller.%s.svc" .Release.Namespace -}}
{{- end -}}


{{/*
Generate certificates for admission-controller 
*/}}
{{- define "admission-controller.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "admission-controller.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "admission-controller.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "admission-controller-ca" 3650 -}}
{{- $cert := genSignedCert ( include "admission-controller.certCommonName" . ) nil $altNames 3650 $ca -}}
ca.crt: {{ $ca.Cert | b64enc }}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}
