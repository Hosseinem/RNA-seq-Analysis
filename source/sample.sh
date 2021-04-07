for file in $(ls raw_data/ENC*);
do {
    filename=$(gunzip -l -N $file | awk 'FNR == 2 {print $4}').gz;
    filename=${filename/raw*\//}
    filename=${filename/.gz/}
    mkdir -p ../example/raw_data
    gunzip -c $file | head -10000 > ../example/raw_data/$filename
    file=${file/ra*\//}
    gzip -c ../example/raw_data/$filename > ../example/raw_data/$file
    rm ../example/raw_data/$filename

}; done	

cp workflow.sh sleuth.R ../example
cp raw_data/Dros* ../example/raw_data
sed -i 's/results/test_results/g' ../example/workflow.sh ../example/sleuth.R
sed -i 's/sleuth_test_results/sleuth_results/g' ../example/sleuth.R
