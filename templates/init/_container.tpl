{{/*
Create helm partial for gitea server
*/}}
{{- define "init" }}
- name: init
  image: {{ .Values.images.gitea }}
  imagePullPolicy: {{ .Values.images.pullPolicy }}
  env:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ template "db.fullname" . }}
        key: dbPassword
  - name: SCRIPT
    value: &script |-
      mkdir -p /datatmp/gitea/conf
      chown -R root:root /datatmp/
      chown -R root:root /etc/gitea
      #if [ ! -f /datatmp/gitea/conf/app.ini ]; then
        sed "s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/g" < /etc/gitea/app.ini > /datatmp/gitea/conf/app.ini
      #fi
  command: ["/bin/sh",'-c', *script]
  - name: gitea-config
    mountPath: /etc/gitea
{{- end }}
