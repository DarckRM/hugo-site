@echo off
chcp 65001
echo 检查原始代码更新
git add .
git commit -m "%date% %time% 代码更新"
echo 拉取远程代码
git pull
echo 上传远程代码
git push
echo 已完成原始代码更新，请按任意键编译并部署至服务器
pause
.\hugo -D
cd public
git add .
git commit -m "%date% %time% 更新内容"
git pull
git push
pause