# THE publish depends on github actions. DO NOT run this script loaclly unless you insist to.

# 设置目标仓库的 URL 和分支
REPO_URL="https://${GH_TOKEN}@github.com/LJHG/ljhg.github.io.git"
BRANCH="master"  # 使用 master 作为分支名

# 检查并创建 mysite 文件夹（在父级目录）
if [ ! -d "../mysite" ]; then
    mkdir ../mysite
fi

# 构建新内容到 ../mysite 文件夹
gitbook build . ../mysite
if [ $? -ne 0 ]; then
    echo "Error: GitBook build failed!"
    exit 1
fi

# 进入 mysite 文件夹并初始化 git 仓库
cd ../mysite

# 初始化或更新 Git 仓库
if [ ! -d ".git" ]; then
    git init
    git remote add origin $REPO_URL
    git checkout -b $BRANCH  # 如果没有分支则创建 master 分支
else
    git remote set-url origin $REPO_URL
    git fetch origin
    git checkout $BRANCH || git checkout -b $BRANCH
fi

# 提交并推送更改
git add -A
git commit -m "Initial commit: Update site content from GitBook"
git push -u origin $BRANCH -f
if [ $? -ne 0 ]; then
    echo "Error: Failed to push changes to $REPO_URL"
    exit 1
fi

echo "Site successfully built and pushed to $REPO_URL on branch $BRANCH"
