powershell Start-Process powershell -Verb runAs -ArgumentList @('-NoExit', '-Command "cd ''%cd%'' "')