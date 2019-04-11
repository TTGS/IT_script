# mv `ls |grep -vE 'run_save_sql.py|^[123]\.sql|desc|new_customer|spk_exec.sh|cycle|clear_file.sh'`  cycle/

dt=`date +%F_%T`
cycle_file=cycle

mkdir -p ./${cycle_file}

if [ $# -eq 0 ] ; then 

file_name=`ls |grep -vE 'run_save_sql.py|^[123]\.sql|desc|new_customer|spk_exec.sh|${cycle_file}|clear_file.sh'`

else 

file_name=$*

fi


for i  in ${file_name}
do
    mv   ${i}  ./${cycle_file}/${i}.${dt}
if [ $? -eq 0 ]; then 
    echo ${i}'  to  '${i}.${dt}
else 
    true 
fi 

done 

echo '>>>it is done.<<<'
