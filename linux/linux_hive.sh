#!/bin/sh

# to initatior this file dolar 
mkdir -p cycle/
mv -f `ls |grep -v $0 |grep -v cycle` cycle/ 

dbname_file=dbname.log


# hive
pq(){
hive<<!
$1
$2
quit;
!
}


# show database ; 
pq 'show databases;' ';' 1>${dbname_file}
grep -v 'hive>'  ${dbname_file}  1>${dbname_file}.bk
mv -f ${dbname_file}.bk ${dbname_file}



# show tables 
for i in `cat ${dbname_file}`
do

echo ">>>>>>>>>>>>>>>>>>>>>>>>"${i} 
mkdir -p ./${i} 

pq 'use '${i}';' 'show tables;' >./${i}/${i}.db
grep -v 'hive>'  ./${i}/${i}.db   1>./${i}/${i}.db.bk
mv -f ./${i}/${i}.db.bk ./${i}/${i}.db


# desc tables 
for j in `cat ./${i}/${i}.db`
do

echo ">>>>>>>>>>>>>>>>>>>>>>>>"${i}"."${j}
pq 'use '${i}';' 'desc '${j}' ;' >./${i}/${i}.${j}.table

done 

echo "${i} is done"
done 
