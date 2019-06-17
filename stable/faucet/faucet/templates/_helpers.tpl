{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "faucet.name" -}}
{{- default .Chart.Name .Values.Instance | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "faucet.fullname" -}}
{{- $name := default .Chart.Name .Values.Instance -}}
{{- if contains $name .Chart.Name -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Chart.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "namespace" -}}
{{- .Release.Namespace | trimPrefix "slate-vo-" | printf " %s" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "faucet.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}