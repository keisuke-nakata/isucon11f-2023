readonly SSH="ssh -o StrictHostKeyChecking=no"

# readonlyな環境変数のリストを作る
readonly OTHER_APPSERVER_PRIVATE_IP_LIST=("10.11.0.102" "10.11.0.103")

readonly HOME_DIR=/home/isucon
readonly REPO_ROOT_DIR=${HOME_DIR}/webapp
readonly SNAPSHOT_SCRIPT_DIR=${HOME_DIR}/webapp/snapshot
readonly RESULT_BASE_DIR=${REPO_ROOT_DIR}/result
readonly CONF_DIR=${REPO_ROOT_DIR}/conf
readonly PPORF_DIR=${HOME_DIR}/pprof

# mysql
readonly MYSQL_CONF_SRC=$CONF_DIR/sql/mysqld.cnf
readonly MYSQL_SLOW_LOG=/var/log/mysql/mysql-slow.log
readonly MYSQL_CONF_DEST=/etc/mysql/mysql.conf.d/mysqld.cnf

# nginx
readonly NGINX_ROOT_CONF_SRC=$CONF_DIR/nginx/nginx.conf
readonly NGINX_ROOT_CONF_DEST=/etc/nginx/nginx.conf
readonly NGINX_SITE_CONF_SRC=$CONF_DIR/nginx/isucholar.conf
readonly NGINX_SITE_CONF_DEST=/etc/nginx/sites-available/isucholar.conf
readonly NGINX_ACCESS_LOG=/var/log/nginx/access.log
readonly NGINX_ERROR_LOG=/var/log/nginx/error.log

# memcache
readonly MEMCACHED_CONF_SRC=$CONF_DIR/memcached/memcached.conf
readonly MEMCACHED_CONF_DEST=/etc/memcached.conf
readonly MEMCACHED_PORT=11211

# env
readonly ENV_SRC=${CONF_DIR}/env.sh
readonly ENV_DEST=${HOME_DIR}/env.sh

# go
# readonly GO="${HOME_DIR}/local/go/bin/go"
readonly GO="go"
readonly GO_PORT=7000
readonly GO_APP_DIR=$REPO_ROOT_DIR/go
# readonly GO_APP_FILENAME=isucholar  # makefile が提供されてるならそっちを使ったほうが良いと思う
readonly GO_SERVICE_NAME=isucholar.go

# alp
readonly UUID_REGEX="[0-9a-f\-]{36}"
# readonly ALP_PATTERN="/api/condition/${UUID_REGEX}$,/api/isu/${UUID_REGEX}$,/api/isu/${UUID_REGEX}/graph$,/api/isu/${UUID_REGEX}/icon$"
readonly ALP_PATTERN="\"\""

# isuview (to use isuview, please specify the following environment variables)
# readonly ISUVIEW_URL="https://isuview.y011d4.com"
# readonly ISUVIEW_USERNAME="snapshot"
# readonly ISUVIEW_PASSWORD="2c9f9Xd99e0_wzklzBMocw"
# readonly ISUVIEW_COOKIE_PATH="/tmp/isuview_cookie.txt"
# isuview_login() {
#   if [[ -z "${ISUVIEW_URL}" || -z "${ISUVIEW_USERNAME}" || -z "${ISUVIEW_PASSWORD}" || -z "${ISUVIEW_COOKIE_PATH}" ]]; then
#     echo "Skip isuview"
#     return 1
#   else
#     csrf_token=$(curl "${ISUVIEW_URL}/api/auth/signin" -c "${ISUVIEW_COOKIE_PATH}" | sed -E 's/.+name="csrfToken" value="([0-9a-f]+)"(.*)$/\1/g')
#     curl -X POST "${ISUVIEW_URL}/api/auth/callback/credentials" -b "${ISUVIEW_COOKIE_PATH}" -c "${ISUVIEW_COOKIE_PATH}" -d "username=${ISUVIEW_USERNAME}&password=${ISUVIEW_PASSWORD}&csrfToken=${csrf_token}"
#     return 0
#   fi
# }
