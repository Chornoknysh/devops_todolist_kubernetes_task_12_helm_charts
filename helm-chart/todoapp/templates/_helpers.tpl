{{- define "todoapp.fullname" -}}
{{ printf "%s-%s" .Chart.Name (default .Release.Name .Release.Name) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "todoapp.name" -}}
{{ .Chart.Name }}
{{- end -}}
