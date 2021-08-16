@echo off
chcp 65001
echo 开始编译
.\hugo -D
cd public
git add .
git commit -m "%date% %time% 更新内容"
git push
pause