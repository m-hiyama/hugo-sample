#!/bin/sh
# make-vars-partials.sh

# 変数名の行に # を含む場合は、その行は無視する（コメント）
# 変数名の行に ^ を含む場合は、値の表示を抑制する。
# スクリプトの引数はパーシャルテンプレートの出力先であるディレクトリ

function makeVarEntry {
    varName="$1"
    echo $varName | grep -q '#'
    foundHash=$?
    #	echo "$foundHash" > /dev/stderr
    if [ "$foundHash" -eq  0 ]; then
	echo "'$varName'" skipped > /dev/stderr
    else
	echo $varName | grep -q '\^'
	foundHash=$?
	if [ "$foundHash" -eq  0 ]; then
	    varName=$(echo $varName  | sed -e 's/\^//')
	    printf \
		"<tr><td>%s</td><td>{{printf \"%%T\" %s}}</td><td>...</td></tr>\n" \
		$varName $varName
	else
	    printf \
		"<tr><td>%s</td><td>{{printf \"%%T\" %s}}</td><td><code>{{printf \"%%+v\" %s}}</code></td></tr>\n" \
		$varName $varName $varName
	fi
    fi
}

function makeVarsTable {
    echo '{{if .Site.Params.inspect }}'
    echo '<div class="dump-vars">'
    printf '<h5>%s</h5>\n' "$1"
    echo '<table border="1">'
    echo '<tr><th>Variable </th><th>Type</th><th>Value</th></tr>'

    while read varName; do
	makeVarEntry "$varName"
    done
    echo '</table>'
    echo '</div>'
    echo '{{end}}'
}

if [ "$1" = "" ]; then
    destDir="partials"
else
    destDir="$1"
fi
echo "destination dir: $destDir/"

for varType in 'Node' 'Page' 'Taxonomy' 'Site' 'Hugo' ; do
    echo "=========== ${varType}Vars.txt"
    makeVarsTable "$varType Variables" < ${varType}Vars.txt > $destDir/${varType}Vars.html
done
