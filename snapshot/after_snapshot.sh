if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <node_result_dir> <branch name> <score_id> <server_id>"
  exit 1
fi
readonly node_result_dir=$1
readonly branch=$2
readonly score_id=$3
readonly server_id=$4

source "$(dirname "$0")/config.sh"

set -eux

# prepare
pushd ${REPO_ROOT_DIR}
readonly old_working_branch=$(git branch --show-current)
git fetch origin
git checkout ${branch}
git pull origin ${branch}

###
# collect result
###
mkdir -p $node_result_dir

# memcached
readonly memcached_result_dir=$node_result_dir/memcached
mkdir -p $memcached_result_dir
(echo "stats"; sleep 0.1; echo -e '\x1dclose\x0d';) | telnet localhost $MEMCACHED_PORT > $memcached_result_dir/stats.txt

# stop profile & analyze
curl "http://localhost:${GO_PORT}/api/pprof/stop"
readonly profile_result_dir=$node_result_dir/profile
mkdir -p $profile_result_dir
cp $PPORF_DIR/cpu.pprof ${profile_result_dir}/
$GO tool pprof --pdf $PPORF_DIR/cpu.pprof > ${profile_result_dir}/prof.pdf
# PATH=$PATH:/home/isucon/local/go/bin:/home/isucon/bin/FlameGraph:/home/isucon/go/bin go-torch -b $PPORF_DIR/cpu.pprof -f $PPORF_DIR/prof.svg

# alp
readonly alp_result_dir=$node_result_dir/alp
mkdir -p $alp_result_dir
sudo alp json --file $NGINX_ACCESS_LOG --sort=sum -r -m ${ALP_PATTERN} > $alp_result_dir/alp.txt

# analyze mysql slow query log
readonly mysql_result_dir=$node_result_dir/mysql
mkdir -p $mysql_result_dir
sudo pt-query-digest $MYSQL_SLOW_LOG > $mysql_result_dir/pt-query-digest.txt

# git push
sudo chown -R isucon $node_result_dir
sudo chgrp -R isucon $node_result_dir
git checkout -b "auto${node_result_dir}"
git add $node_result_dir
git commit -m "committed by after_snapshot.sh"
git push -u origin "auto${node_result_dir}"

# post to isuview
if isuview_login; then
  curl -X POST "${ISUVIEW_URL}/api/snapshot/${score_id}/${server_id}" -b "${ISUVIEW_COOKIE_PATH}" -F "file=@${node_result_dir}/alp/alp.txt" -F "file=@${node_result_dir}/mysql/pt-query-digest.txt" -F "file=@${node_result_dir}/profile/prof.pdf"
fi

# cleanup
git checkout "${old_working_branch}"
popd
