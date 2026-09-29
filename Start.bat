@echo off
cd /d D:\Blog\su-security-blog

echo.
echo ==============================
echo       正在发布博客...
echo ==============================
echo.

git add .

git commit -m "Update blog"
git push

echo.
echo ==============================
echo       发布完成！
echo ==============================
pause