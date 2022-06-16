# Usage: awk -f org2hledger.awk < auto-km-descending.org
# Input must be in this format:
# ** <km> km <wer> [<desc>] [:tags:]
# [2020-06-21 Sun 21:18]
# ** ...
# in DESCENDING order.
# Pass -vextratag=auto:vw to add an extra tag "auto:vw" to
# all transactions.
BEGIN{
	OFS="\t"
	print ""
	if (extratag) extratag = ", " extratag
}
function printTransaction() {
	kmdiff = km - prevkm
	printf "%s  %s km %s | %s  ; tags:%s, time:%s%s\n", date, km, wer, description, tags, time, extratag
	print "  assets:km"
	n = length(wer)
	anteil = kmdiff / n
	for (i = 1; i <= n; i++) {
		person = substr(wer, i, 1)
		printf "  expenses:km:%s     %s km\n", person, anteil
	}
	print ""
}
/^\*\*/{
	if (km) {
		prevkm = $2
		printTransaction()
	}
	km = $2
	wer = toupper($4)
	if(wer=="") wer="X"
	i = match($0, /:([A-Za-z0-9:_-]+): *$/, arr)
	tags = arr[1]
	if (i == 0) i = 1000
	description = substr($0, 0, i - 1)
	description = gensub(/^[^ ]* *[^ ]* [^ ]* *[^ ]* */, "", 1,
				   gensub(/  +/, " ", "g",
				    gensub(/\t/, " ", "g", description)))
}
!/^\*/{
	date = substr($1, 2)
	time = substr($3, 1, 5)
}
