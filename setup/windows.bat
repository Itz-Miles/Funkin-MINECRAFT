@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install flixel 5.8.0
haxelib set flixel 5.8.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-addons 3.3.2
haxelib set flixel-addons 3.3.2
haxelib install flixel-ui 2.6.3
haxelib set flixel-ui 2.6.3
haxelib install hxcpp
haxelib install parallaxlt 0.0.4
haxelib install hxcpp-debug-server
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
del vs_Community.exe
echo Finished!
pause
