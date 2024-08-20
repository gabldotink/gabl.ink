@echo off
rem SPDX-License-Identifier: CC0-1.0

set "script=%~0"
set "root=%~dp0..\..\..\..\.."
set "index=%root%\index"

copy /b /v /y "%index%\en\meta\htaccess\index.htaccess" ^
              "%root%/.htaccess"
copy /b /v /y "%index%\en\meta\robots\index.txt" ^
              "%root%\robots.txt"
copy /b /v /y "%index%\en\meta\git\attributes\index.gitattributes" ^
              "%root%\.gitattributes"
copy /b /v /y "%index%\mul\meta\root\index.html" ^
              "%root%\index.html"
copy /b /v /y "%index%\en\meta\github\readme\index.md" ^
              "%root%\readme.md"
mkdir         "%root%\.github"
copy /b /v /y "%index%\en\meta\github\settings\index.yml" ^
              "%root%\.github\settings.yml"

echo "All operations were completed successfully."
@echo on
exit /b 0