#!/bin/bash

stats="`mktemp`" || exit 1
computed="`mktemp`" || exit 1
wget -O "$stats" https://mapa.covid.chat/export/csv
# the file begins with header, so we strip it
tail -n +2 "$stats" | awk 'BEGIN{ FS=";"; total_tests=0; total_infected=0; }{ total_tests += $5; total_infected += $6; print $1, $6 * 100 / $5, total_infected * 100 / total_tests; }' > "$computed"

today="`date +%d-%m-%y`"
if [ -n "$1" ];
then
	output="$1"
else
	output="| display png:-"
fi

cat <<EOF | gnuplot
set terminal png size 1920,1080
set output '$output'
set xdata time
set timefmt "%d-%m-%y"
set xrange ["06-03-2020":"$today"]
set format x "%d/%m"
plot '$computed' using 1:2 with linespoints title 'Daily percent', '$computed' using 1:3 with linespoints title 'Total percent'
EOF

rm -f "$stats" "$computed"
