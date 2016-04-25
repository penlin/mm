#!/bin/sh
function open_url() {
	url=$1
	/usr/bin/open -a "/Applications/Google Chrome.app" $url 
}

function fetch_18mm() {
	OPEN_PROG="/usr/bin/curl"
	BASE="http://18av.mm-cg.com"
	RANDOM_PAGE_URL="/ioshow.html"
	TEMP=$1
	RES=$2
	
	$OPEN_PROG "$BASE$RANDOM_PAGE_URL" -o $TEMP 2>/dev/null
	grep "18av\/[0-9]*.html" $TEMP | tr "<" "\n" | sed -ne 's/.*\(http:\/\/18av.mm-cg.com\/18av\/[0-9]*.html\)\">\(.*\).*$/\1	\2/p' > $RES
	rm $TEMP
}

function mm() {
	TEMP_HTML="/tmp/temp.html"
	RESULT="/tmp/.result.url"

	FETCH=""

	if [[ "$1" == "-n" ]];then
		FETCH="true"
	fi

	NUM=$1
	[[ -n "${NUM##[0-9]*}" ]] && NUM=0

	DONE=""
	while [[ "$DONE" == "" ]]; do
		if [[ "$FETCH" == "true" ]] || [ ! -f $RESULT ];then
			fetch_18mm $TEMP_HTML $RESULT
			FETCH=""
		fi

		awk -v num=$NUM ' \
		function open_url (url) {
			print "open",url
			system("/usr/bin/open -a \"\/Applications\/Google Chrome.app\" "url);
		}
		BEGIN {
			FS=OFS="\t"
			idx=1
			print "#numer:           Title"
		}
		{
			split($1,number,"18av\/")
			if (repeat[number[2]]!=1) {
				urls[idx]=$1
				repeat[number[2]]=1
				if (length($2) < 5) {
					printf "#%d:\t%s\n",idx,$1
				} else {
					printf "#%d:\t%s\n",idx,$2
				}
				idx+=1
			}
		}
		END{
			if (num <= 0) {
				print "Enter numbers of mm separated in comma or space to open urls :"
				print "\"n-m\": open mm numbers between n and m"
				print "e, q: exit.  n : renew a mm list. "
				getline num < "-";
			}

			argc = 1;
			if (index(num,",") || index(num," ")) {
				argc=split(num,args,/[ ,]*/)
			} else {
				args[1]=num
			} 
			
			for (i = 1 ; i <= argc ; i++) {
				target=args[i]
				if (index(target,"-")) {
					split(target,period,/[ -]*/)
					if (period[1]!="" && period[1] > 0 && period[2]!="" && period[2] > 0) {
						for (x = period[1]; x <= period[2]; x++) {
							if(urls[x]!="")
								open_url(urls[x])
						}
					} else {
						print target," is invalid input!"
					}
				}
				else if (target == "e" || target == "q") {
					exit 0
				}else if (target == "n") {
					exit 2
				}else if (target <= 0) {
					print target," is not a valid mm number."
				} else if (urls[target]!="") {
					open_url(urls[target])
				} else {
					print target," is not a valid mm number."
				}
			}
			exit 0
		}' $RESULT

		case "$?" in
			"0") DONE="true"
				;;
			"1") NUM=0
				;;
			"2") FETCH="true"
				;;
			*);;
		esac
	done
}
