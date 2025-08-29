{{- define "go-web.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "go-web.fullname" -}}
{{- include "go-web.name" . -}}
{{- end -}}

{{- define "go-web.labels" -}}
app.kubernetes.io/name: {{ include "go-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end -}}

{{- define "go-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "go-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
