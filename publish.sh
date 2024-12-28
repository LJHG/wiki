# 设置目标仓库的 URL 和分支
REPO_URL="https://github.com/LJHG/ljhg.github.io.git"
BRANCH="master"  # 使用 master 作为分支名

# 检查并创建 mysite 文件夹
if [ ! -d "./mysite" ]; then
    mkdir mysite
    cd ./mysite
    git init
    git remote add origin $REPO_URL
    cd ..
fi

# 构建新内容到 mysite 文件夹
gitbook build . ./mysite
if [ $? -ne 0 ]; then
    echo "Error: GitBook build failed!"
    exit 1
fi

# 进入 mysite 并提交更改
cd ./mysite

# 切换到 master 分支（如果不存在则创建）
git checkout $BRANCH || git checkout -b $BRANCH

# 提交并推送更改
git add -A
git commit -m "Initial commit: Update site content from GitBook"
git push -u origin $BRANCH
if [ $? -ne 0 ]; then
    echo "Error: Failed to push changes to $REPO_URL"
    exit 1
fi

echo "Site successfully built and pushed to $REPO_URL on branch $BRANCH"
