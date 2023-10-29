if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <change log> <branch name>"
  exit 1
fi
readonly changelog=$1
readonly branch=$2

source "$(dirname "$0")/config.sh"

set -eux

# prepare
pushd "${REPO_ROOT_DIR}"
readonly old_working_branch=$(git branch --show-current)
git fetch origin
git checkout "${branch}"
git pull origin "${branch}"

readonly commit_id=$(git rev-parse HEAD)

# create result dir
readonly dt=$(date +%Y%m%d-%H%M%S)
readonly result_dir=${RESULT_BASE_DIR}/${dt}_${commit_id}
mkdir -p $result_dir

###
# run before_snapshot.sh
###
cmd="bash ${SNAPSHOT_SCRIPT_DIR}/before_snapshot.sh ${branch}"
# appserver 1 (this)
set +x
bash -c "$cmd"
set -x
for ip in ${OTHER_APPSERVER_PRIVATE_IP_LIST[@]}; do
  set +x
  echo "========================== BEGIN appserver $ip =========================="
  $SSH $ip $cmd
  echo "========================== END appserver $ip =========================="
  set -x
done

###
# run benchmark
###
echo "Run benchmark, and input your score: "
read score

###
# record score
###
# result branch に最新の main branch をマージ
git fetch origin
git checkout result
git merge --no-edit "remotes/origin/main"
# 実行対象が main ブランチである場合のみ、result ブランチで summary.md に記録。それ以外のブランチだとコンフリクトが発生するため何もしない
if [[ "${branch}" == "main" ]]; then
  git checkout result
  echo "|${dt}|${score}|${commit_id}|${changelog}|" >> $RESULT_BASE_DIR/summary.md
  git add $RESULT_BASE_DIR/summary.md
  git commit -m "${commit_id}" -m "committed by snapshot.sh"
  git push origin result # after snapshot は非常に重いので summay だけ先に push
fi
git checkout "${branch}"

if isuview_login; then
  score_id=$(curl -X POST "${ISUVIEW_URL}/api/snapshot" -b "${ISUVIEW_COOKIE_PATH}" -H "Content-Type:application/json" -d "{\"score\":${score},\"changeLog\":\"${changelog}\",\"commitHash\":\"${commit_id}\"}")
else
  score_id=""
fi

###
# run after_snapshot.sh
###
# appserver 1 (this)
node_result_dir=${result_dir}/appserver1
cmd="bash ${SNAPSHOT_SCRIPT_DIR}/after_snapshot.sh ${node_result_dir} ${branch} \"${score_id}\" 1"
set +x
bash -c "$cmd"
set -x
git checkout result
git merge --no-edit "remotes/origin/auto${node_result_dir}"
# other appservers
i_appserver=2
for ip in ${OTHER_APPSERVER_PRIVATE_IP_LIST[@]}; do
  node_result_dir=${result_dir}/appserver${i_appserver}
  cmd="bash ${SNAPSHOT_SCRIPT_DIR}/after_snapshot.sh ${node_result_dir} ${branch} \"${score_id}\" 2"
  set +x
  echo "========================== BEGIN appserver ${i_appserver} =========================="
  $SSH $ip $cmd
  echo "========================== END appserver ${i_appserver} =========================="
  set -x
  git checkout result
  git fetch origin
  git merge --no-edit "remotes/origin/auto${node_result_dir}"
  i_appserver=$((i_appserver+1))
done

# push the result
git push origin result

# cleanup
git checkout "${old_working_branch}"
popd
