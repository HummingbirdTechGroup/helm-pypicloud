{{- define "pypicloud.configini" }}
[app:main]
use = egg:pypicloud

pyramid.reload_templates = False
pyramid.debug_authorization = false
pyramid.debug_notfound = false
pyramid.debug_routematch = false
pyramid.default_locale_name = en

pypi.default_read = authenticated

pypi.storage = gcs

storage.bucket = {{ .Values.storage.bucket }}
storage.region_name = {{ .Values.storage.region }}
{{- if .Values.storage.prefix }}
storage.prefix = {{ .Values.storage.prefix }}
{{- end }}

# storage.gcp_service_account_json_filename = /etc/pypicloud-secret/service_key.json
storage.gcp_use_iam_signer=true

{{- if .Values.redis.enabled }}
# Use redis as caching backend
pypi.db = redis
db.url = redis://:{{ .redisPassword }}@{{ .Values.redis.host }}:{{ .Values.redis.port }}/0
{{- end }}

auth.admins = {{ .adminUsername }}

user.{{ .adminUsername }} = {{ .adminPassword }}
user.{{ .userUsername }} = {{ .userPassword }}

# For beaker
session.encrypt_key = {{ .sessionEncryptKey }}
session.validate_key = {{ .sessionValidateKey }}

session.secure = True
session.invalidate_corrupt = true

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
# logging configuration
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
{{- end }}
