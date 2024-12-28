gitbook build . ../tmp_mysite
if [ $? -ne 0 ]; then
    echo "Error: GitBook build failed!"
    exit 1
fi

function publish_to()
{
    repo_name=$1
    target_dir="../${repo_name}"

    echo "Target directory: $target_dir"
    if [ ! -d "$target_dir" ]; then
        echo "Error: Target directory $target_dir does not exist!"
        exit 1
    fi

    cd "$target_dir" || exit

    if [ ! -d ".git" ]; then
        echo "Error: $target_dir is not a Git repository!"
        exit 1
    fi

    echo "Current working directory: $(pwd)"

    rm -rf `ls | grep -v .git`
    cp -r ../tmp_mysite/* "$target_dir"

    git add -A
    git commit -m 'update from gitbook'
    git push
}

publish_to mysite

rm -rf ../tmp_mysite
