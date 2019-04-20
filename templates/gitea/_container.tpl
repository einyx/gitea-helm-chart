{{/*
Create helm partial for gitea server
*/}}
{{- define "gitea" }}
- name: gitea
  command: ["/app/gitea/gitea", "--port", "3000"]
  image: {{ .Values.images.gitea }}
  imagePullPolicy: {{ .Values.images.pullPolicy }}
  env:
  - name: USER_UID
    value: "1000"
  - name: USER_GID
    value: "1000"
  ports:
  - name: ssh
    containerPort: {{ .Values.service.ssh.port  }}
  - name: http
    containerPort: {{ .Values.service.http.port  }}
  volumeMounts:
  - name: gitea-data
    mountPath: /data/
  - name: gitea-config
    mountPath: /etc/gitea
  - name: gitea-data
    mountPath: /app/gitea/data/
{{- end }}
