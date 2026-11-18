{{/*
Expand the name of the chart.
*/}}
{{- define "mine-kube.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create namespace name, fall back to chart name
*/}}
{{- define "mine-kube.namespace" -}}
{{- default .Values.namespace.name (include "mine-kube.name" .) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mine-kube.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mine-kube.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mine-kube.labels" -}}
helm.sh/chart: {{ include "mine-kube.chart" . }}
{{ include "mine-kube.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mine-kube.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mine-kube.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mine-kube.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mine-kube.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "mine-kube.server.type" -}}
{{- if .type }}
{{- .type }}
{{- else if (and .curseforge .curseforge.page_url) -}}
AUTO_CURSEFORGE
{{- else -}}
VANILLA
{{- end }}
{{- end }}

{{- define "mine-kube.server.version" -}}
{{- .version | default "latest" }}
{{- end }}

{{- define "mine-kube.server.image" -}}
"{{ .image.repository | default "itzg/minecraft-server" }}:{{ .image.tag | default "latest" }}"
{{- end }}

{{- define "mine-kube.server.labels" -}}
mine-kube.null-it.org/server-name: {{ .name }}
mine-kube.null-it.org/minecraft-version: {{ include "mine-kube.server.version" . }}
mine-kube.null-it.org/server-type: {{ include "mine-kube.server.type" . }}
{{- end }}

{{- define "mine-kube.server.env" -}}
EULA: {{ .eula | default "" | quote }}
TYPE: {{ include "mine-kube.server.type" . | quote }}
VERSION: {{ include "mine-kube.server.version" . | quote }}
ENABLE_WHITELIST: {{ .enable_whitelist | default "TRUE" | quote }}
WHITELIST: {{ join "," .whitelist | quote }}
OPS: {{ join "," .ops | quote }}
MOTD: {{ .motd | quote }}
ICON: {{ .icon | quote }}
MODE: {{ .mode | quote }}
HARDCORE: {{ .hardcore | quote }}
ENABLE_RCON: "TRUE"
OVERRIDE_ICON: "TRUE"
USE_AIKAR_FLAGS: {{ .use_aikar_flags | quote }}
USE_MEOWICE_FLAGS: {{ .use_meowice_flags | quote }}
USE_FLARE_FLAGS: {{ .use_flare_flags | quote }}
USE_SIMD_FLAGS: {{ .use_simd_flags | quote }}
PROXY: {{ .proxy | quote }}
CONSOLE: {{ .console | quote }}
GUI: {{ .gui | quote }}
SETUP_ONLY: {{ .setup_only | quote }}

{{- with .schedule }}
STOP_SERVER_ANNOUNCE_DELAY: {{ .stop_server_announce_delay | quote }}
STOP_SERVER_DELAY_COMMAND: {{ .stop_server_delay_command | quote}}
STOP_DURATION: {{ .stop_duration | quote }}
PRE_START_SCRIPT: {{ .pre_start_script | quote }}
RCON_CMDS_STARTUP: {{ .startup_cmd | quote }}
RCON_CMDS_ON_CONNECT: {{ .on_connect_cmd | quote }}
RCON_CMDS_FIRST_CONNECT: {{ .first_connect_cmd | quote }}
RCON_CMDS_ON_DISCONNECT: {{ .on_disconnect_cmd | quote }}
RCON_CMDS_LAST_DISCONNECT: {{ .last_disconnect_cmd | quote }}
{{- end }}

{{- with .auto_pause }}
ENABLE_AUTOPAUSE: "TRUE"
AUTOPAUSE_TIMEOUT_EST: {{ .timeout_est | quote }}
AUTOPAUSE_TIMEOUT_INIT: {{ .timeout_init | quote }}
AUTOPAUSE_TIMEOUT_KN: {{ .timeout_kn | quote }}
AUTOPAUSE_PERIOD: {{ .period | quote }}
AUTOPAUSE_KNOCK_INTERFACE: {{ .knock_interface | quote }}
DEBUG_AUTOPAUSE: {{ .debug | quote }}
{{- end }}

{{- with .auto_stop }}
ENABLE_AUTOSTOP: "TRUE"
AUTOSTOP_TIMEOUT_EST: {{ .timeout_est | quote }}
AUTOSTOP_TIMEOUT_INIT: {{ .timeout_init | quote }}
AUTOSTOP_PERIOD: {{ .period | quote }}
DEBUG_AUTOSTOP: {{ .debug | quote }}
{{- end }}

{{- with .curseforge }}
CF_PAGE_URL: {{ .page_url | quote }}
CF_EXCLUDE_INCLUDE_FILE: {{ .exclude_include_file | quote }}
CF_EXCLUDE_MODS: {{ join "," .exclude_mods | quote }}
CF_FORCE_INCLUDE_MODS: {{ join "," .force_include_mods | quote }}
CF_IGNORE_MISSING_FILES: {{ join "," .ignore_missing_files | quote }}
CF_FORCE_SYNCHRONIZE: {{ .force_synchronize | quote }}
CF_SET_LEVEL_FROM: {{ .set_level_from | quote }}
CF_PARALLEL_DOWNLOADS: {{ .parallel_downloads | quote }}
CF_OVERRIDE_SKIPS_EXISTING: {{ .override_skips_existing | quote }}
CF_MOD_LOADER_VERSION: {{ .mod_loader_version | quote }}
{{- end }}

{{- with .gtnh }}
GTNH_PACK_VERSION: {{ .pack_version | quote}}
GTNH_DELETE_BACKUPS: {{ .delete_backups | quote }}
SKIP_GTNH_UPDATE_CHECK: {{ .skip_update_check | quote }}
{{- end }}

{{- with .resource }}
{{- with .resources.java }}
MEMORY: {{ .memory | quote }}
INIT_MEMORY: {{ .init_memory | default "" | quote }}
MAX_MEMORY: {{ .max_memory | default "" | quote }}
{{- end }}
{{- end }}
{{- range $key, $val := .extra_env }}
{{ $key }}: {{ $val | quote }}
{{ end -}}
{{- end }}

{{- define "mine-kube.backup.image" -}}
"{{ (.image | default dict).repository | default "itzg/mc-backup" }}:{{ (.image | default dict).tag | default "latest" }}"
{{- end }}