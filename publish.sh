# 设置目标仓库的 URL 和分支
REPO_URL="https://github.com/LJHG/ljhg.github.io.git"
BRANCH="main"

# 检查并创建 mysite 文件夹
if [ ! -d "./mysite" ]; then
    mkdir mysite
    cd ./mysite
    git init
    git remote add origin $REPO_URL
    git fetch origin
    git checkout $BRANCH || git checkout -b $BRANCH
    cd ..
fi

# 构建新内容到 mysite 文件夹
gitbook build . ./mysite
if [ $? -ne 0 ]; then
    echo "Error: GitBook build failed!"
    exit 1
fi

# 提交并推送更改
cd ./mysite
git add -A
git commit -m "Update site content from GitBook"
git push origin $BRANCH
if [ $? -ne 0 ]; then
    echo "Error: Failed to push changes to $REPO_URL"
    exit 1
fi

echo "Site successfully built and pushed to $REPO_URL"
