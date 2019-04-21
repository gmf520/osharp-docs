:: http://127.0.0.1:4205
docker run --name osharp-docs --rm -it -p 4205:8000 -v /d/WorkSpace/Source/Repos/osharp-docs:/docs squidfunk/mkdocs-material

:: docker run --rm -it -v /d/WorkSpace/Source/Repos/osharp-docs:/docs squidfunk/mkdocs-material build