{{/*
# Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "riva-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "riva-server.fullname" -}}
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
{{- define "riva-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ngcPullSecret" }}
{{- with .Values.ngcCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end -}}
{{- end -}}

{{- define "joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := .root -}}{{- if $v.enabled }}{{- if not $local.first -}},{{- end -}}{{ $.prefix }}{{- $k -}}{{ $.suffix }}{{- $_ := set $local "first" false -}}{{- end -}}{{- end -}}
{{- end -}}

{{- define "artifacturl" -}}
{{- if (ne (len .Values.riva_ngc_team) 0) }}
{{- printf "%s/%s" .Values.riva_ngc_org .Values.riva_ngc_team }}
{{- else }}
{{- printf "%s" .Values.riva_ngc_org }}
{{- end }}
{{- end -}}

{{- define "image_version" -}}
{{- printf "%s" .Values.riva_ngc_image_version }}
{{- end -}}

{{- define "model_version" -}}
{{- printf "%s" .Values.riva_ngc_model_version }}
{{- end -}}

{{- define "server_image" -}}
{{- if .Values.rawServerImage }}
{{- printf "%s" .Values.rawServerImage }}
{{- else }}
{{- printf "%s/%s/%s:%s" .Values.imageurl (include "artifacturl" .) .Values.riva.speechImageName (include "image_version" .) }}
{{- end }}
{{- end -}}

{{- define "servicemaker_image" -}}
{{- if .Values.rawServicemakerImage }}
{{- printf "%s" .Values.rawServicemakerImage }}
{{- else }}
{{- printf "%s/%s/%s:%s-servicemaker" .Values.imageurl (include "artifacturl" .) .Values.modelRepoGenerator.imageName (include "image_version" .) }}
{{- end }}
{{- end -}}