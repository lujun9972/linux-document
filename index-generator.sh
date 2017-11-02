#!/bin/bash

declare -A catalog_comment_dict
catalog_comment_dict=([examples]="读什么手册啊，跟着我来做就好了." [tools]="又有什么新玩意?"  [shell]="别不把shell当语言" [system]="系统管理相关内容" [game]="Linux好游戏" [common]="未分类的内容" [raw]="未翻译的内容,欢迎大家领取"  [processing]="正在翻译的内容,别人的东西可不要抢哦~")

catalogs=$(for catalog in ${!catalog_comment_dict[*]};do
               echo $catalog
           done |sort)

function get_contributors()
{
    echo "* Contributors"
    echo "感谢GitHub以及:"
    # git log --pretty='%an<%ae>'|grep -viEw 'darksun|lujun9972' |sort|uniq|sed -e 's/^/+ /'
    git shortlog --summary --email HEAD |grep -viEw 'darksun|lujun9972'|cut -f2|sed -e 's/^/+ /'
    echo ""
    echo "感谢大家的热情参与,也欢迎更多的志愿者参与翻译"
}

function generate_headline()
{
    local catalog="$*"
    echo "* $catalog"
    echo ${catalog_comment_dict[$catalog]}
    echo 
    generate_links $catalog |sort -t "<" -k2 -r
}

function generate_links()
{
    local catalog=$1
    if [[ ! -d $catalog ]];then
        mkdir -p $catalog
    fi
    posts=$(find $catalog -maxdepth 1 -type f)
    old_ifs=$IFS
    IFS="
"
    for post in $posts
    do
        modify_date=$(git log --date=short --pretty=format:"%cd" -n 1 $post) # 去除日期前的空格
        if [[ -n "$modify_date" ]];then # 没有修改日期的文件没有纳入仓库中,不予统计
            postname=$(grep '#+TITLE' $post|head -1|cut -c 9-)
            echo "+ [[https://github.com/lujun9972/linux-document/blob/master/$post][$postname]]		<$modify_date>"
        fi
    done|sort -k 2
    IFS=$old_ifs
}

get_contributors

for catalog in $catalogs
do
    generate_headline $catalog
done
