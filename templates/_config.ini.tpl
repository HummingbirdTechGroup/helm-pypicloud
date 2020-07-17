{{- define "pypicloud.configini" }}
[app:main]
use = egg:pypicloud

pyramid.reload_templates = False
pyramid.debug_authorization = false
pyramid.debug_notfound = false
pyramid.debug_routematch = false
pyramid.default_locale_name = en

###
# Top level PyPI config
###
{{- range $k, $v := .Values.pypi }}
pypi.{{ $k }}: {{ $v }}
{{- end }}

###
# Storage configuration
# https://pypicloud.readthedocs.io/en/latest/topics/storage.html
###
{{- range $k, $v := .Values.storage }}
storage.{{ $k }}: {{ $v }}
{{- end }}

{{- if .Values.gcsSecret }}
storage.gcp_service_account_json_filename = /etc/pypicloud-secret/service_key.json
{{- end }}

###
# Caching
###
{{- if .Values.redis.enabled }}
# Use redis as caching backend
db.url = redis://:{{ .redisPassword }}@{{ .Values.redis.host }}:{{ .Values.redis.port }}/0
{{- end }}

###
# Authentication
###
{{- range $k, $v := .Values.auth }}
auth.{{ $k }}: {{ $v }}
{{- end }}

user.{{ .adminUsername }} = $ADMIN_PASSWORD
user.{{ .userUsername }} = $USER_PASSWORD

###
# Session management
###

session.secure = True
session.invalidate_corrupt = true

# For beaker
session.encrypt_key = {{ .sessionEncryptKey }}
session.validate_key = {{ .sessionValidateKey }}

###
# wsgi server configuration
###

[uwsgi]
paste = config:%p
paste-logger = %p
master = true
uid = pypicloud
gid = pypicloud
processes = 20
reload-mercy = 15
worker-reload-mercy = 15
max-requests = 1000
enable-threads = true
http = 0.0.0.0:8080

###
# Logging configuration
# http://docs.pylonsproject.org/projects/pyramid/en/latest/narr/logging.html
###

[loggers]
keys = root

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = {{ .Values.logLevel }}
handlers = console

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)s %(asctime)s [%(name)s] %(message)s
{{ end }}

{{ .Values.additionalConfig }}
