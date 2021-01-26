#!/bin/bash
read -p "请选择要提交的内容[p/a]" file
case $file in
	p|P)
		old_IFS=$IFS
		IFS=$'\n'
		mv thumbs/download.md download.md
		rm -rf thumbs
		mkdir thumbs
		cd images
		num=`ls *.png|wc -l|tr -d ' '`
		printf "### 点击小图标可跳转至模板下载页面  /  Click on the thumbnail to access the plugin  \n当前共有 ["$num"] 个模板 / Here are ["$num"] plugins now  \n****  \n\n" >> ../thumbs/thumbs.md
		printf "### 点击文字链接可跳转至模板下载页面  /  Click on the link to access the plugin  \n当前共有 ["$num"] 个模板 / Here are ["$num"] plugins now  \n****  \n\n" >> ../thumbs/textlist.md
		for i in `ls *.png`
		do
			sips -Z 256 -s format jpeg $i --out ../thumbs/${i%.*}.jpg
			pluginName=${i%.*}
			echo '<a href="https://cdn.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/plugins/'$pluginName'.zip"><img src="./'$pluginName'.jpg" alt="'$pluginName'" width="128" /></a>' >> ../thumbs/thumbs.md
			echo '['$pluginName'](https://cdn.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/plugins/'$pluginName'.zip)  ' >> ../thumbs/textlist.md
		done
		cd ..
		sed -i "" '$d' README.md
		echo '当前共有 ['$num'] 个模板 / Here are ['$num'] plugins now' >> README.md
		mv download.md thumbs/download.md
		IFS=$old_IFS
		git add *
		read -p "请输入commit信息: " commit
		git commit -m "$commit"
		git push origin master
		id=`git rev-parse HEAD`
		IFS=$'\n'
		for i in $(git show --pretty="" --name-only $id|grep -E "plugins/")
		do
			read -p "是否更新 ${i} 缓存?[y/n]" update
			case $update in
			 y|Y)
				echo "正在刷新 ${i} 缓存..."
				/usr/bin/curl -s "$(perl -MURI::Escape -e 'print uri_escape shift, , q{^A-Za-z0-9\-._~/:}' -- "https://purge.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/$i")" 1>/dev/null
				;;
			 n|N)
				:
				;;
			 *)
				echo "输入错误, 已取消更新缓存."
				;;
			esac
		done
		;;
	a|A)
		git add app/
		git commit -m "update app"
		git push origin master
		echo "正在刷新CDN缓存..."
		/usr/bin/curl -s https://purge.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/app/ver 1>/dev/null
		/usr/bin/curl -s https://purge.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/app/md5 1>/dev/null
		/usr/bin/curl -s https://purge.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/app/catalog 1>/dev/null
		/usr/bin/curl -s https://purge.jsdelivr.net/gh/lihaoyun6/capXDR-plugins/app/capXDR.dmg 1>/dev/null
		;;
	*)
		echo "输入错误, 已取消更新缓存."
		;;
	esac
echo "已完成!"