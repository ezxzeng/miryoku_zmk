#!/bin/bash
# from https://gist.github.com/icheko/9ff2a0a90ef2b676a5fc8d76f69db1d3
# before running this script, run 
shield_name="bgkeeb"
remote_repo="ezxzeng/zmk-bgkeeb"
remote_branch="main"

git remote -v | grep -w ${shield_name} || git remote add ${shield_name} git@github.com:${remote_repo}.git
SOURCE_BRANCH="${shield_name}-source"
STAGING_BRANCH="${shield_name}-staging"

if [ -d "config/boards/shields/${shield_name}" ]; then
  shield_exists=true
else
  shield_exists=false
fi

echo
echo "Fetch new changes from ${shield_name}"
echo -----------------------------------------
git fetch ${shield_name} ${remote_branch}

LATEST_COMMIT=`git ls-remote ${shield_name} | grep "refs/heads/${remote_branch}" | awk '{ print $1}'`
echo
echo "${shield_name} latest commit: ${HELMCHARTS_LATEST_COMMIT}"
echo

# checkout source repo
git checkout -b ${SOURCE_BRANCH} ${shield_name}/${remote_branch}
# echo Hi. >> config/boards/shields/${shield_name}/test.txt
# git add config/boards/shields/${shield_name}/test.txt
# git commit -am "test"
# echo Hi. >> test.txt
# git add test.txt
# git commit -am "test_root"

# create new staging branch from all the commits impacting "/my-chart" from source repo
if $shield_exists; then
  git subtree split -P config/boards/shields/${shield_name} -b ${STAGING_BRANCH} --onto master
  # checkout master
  git checkout master
else
  git subtree split -P config/boards/shields/${shield_name} -b ${STAGING_BRANCH} 
  # checkout master
  git checkout master
  
  # take commits in the staging branch and set "/helm-charts/my-chart" as the commit root
  # after you run this script the first time, update the command below to:
  # "git subtree merge" with the same parameters
  echo
  echo "Add in changes"
  echo -----------------------------------------
  git subtree add -P config/boards/shields/${shield_name} ${STAGING_BRANCH} --message "Update ${shield_name} from https://github.com/${remote_repo}/commit/${HELMCHARTS_LATEST_COMMIT}"
fi


# clean up
echo
echo
git branch -D ${STAGING_BRANCH}
git branch -D ${SOURCE_BRANCH}