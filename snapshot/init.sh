source "$(dirname "$0")/config.sh"

set -eux
cd $REPO_ROOT_DIR

# result
git checkout result 2>/dev/null || git checkout -b result
mkdir -p ${RESULT_BASE_DIR}
echo -e "|dt|score|commit id|change log|\n|--|--|--|--|" > ${RESULT_BASE_DIR}/summary.md
git add ${RESULT_BASE_DIR}/summary.md
git commit -m "summary.md"
git push origin result

cmd="cd ${REPO_ROOT_DIR} && git fetch origin && git checkout result 2>/dev/null || git checkout -b result --track origin/result && git checkout main"
for ip in ${OTHER_APPSERVER_PRIVATE_IP_LIST[@]}; do
  $SSH $ip $cmd
done

# main
git checkout main
git pull origin main

mkdir -p ${CONF_DIR}
mkdir -p ${CONF_DIR}/sql
touch ${CONF_DIR}/sql/.gitkeep
mkdir -p ${CONF_DIR}/nginx
touch ${CONF_DIR}/nginx/.gitkeep
mkdir -p ${CONF_DIR}/memcached
touch ${CONF_DIR}/memcached/.gitkeep
mkdir -p ${PPORF_DIR}  # これは git 管理しないので .gitkeep 不要
(
  cd $GO_APP_DIR
  $GO get github.com/pkg/profile github.com/mattn/go-isatty@v0.0.12
  # $GO build -o $GO_APP_FILENAME
  make all
)
sudo systemctl restart $GO_SERVICE_NAME

cp ${MYSQL_CONF_DEST} ${MYSQL_CONF_SRC}
cmd="sudo touch ${MYSQL_SLOW_LOG} && sudo chmod go+w ${MYSQL_SLOW_LOG}"  # なぜか最初は `-rw-r--r--` になってて書き込みできなくなってることがある
bash -c "$cmd"
for ip in ${OTHER_APPSERVER_PRIVATE_IP_LIST[@]}; do
  $SSH $ip $cmd
done
cp ${NGINX_ROOT_CONF_DEST} ${NGINX_ROOT_CONF_SRC}
cp ${NGINX_SITE_CONF_DEST} ${NGINX_SITE_CONF_SRC}
cp ${MEMCACHED_CONF_DEST} ${MEMCACHED_CONF_SRC}
cp ${ENV_DEST} ${ENV_SRC}

git add ${CONF_DIR} ${GO_APP_DIR}
git commit -m "initialize by init.sh"
git push origin main
