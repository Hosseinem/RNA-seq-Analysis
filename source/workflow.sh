#!/bin/bash
#
# ######################################################################################
#    This is an NGS Pipeline to re-analyze RNA-seq data from
#    Drosophila Sequencing projects present in the ENCODE
#
#    Treatment group:    ENCSR554IWH
#    Control group  :    ENCSR573JSS
#    Author         :    Hossein Eizadi Moghadam
#    Student ID     :    1821569
#
#    Sapienza University of Rome
#    Professor Matteo Pallocca
# ######################################################################################

# Keep the track of time
start=`date +%s`



# Quality check
echo $'Quality check using fastQC...\n'

mkdir -p drosophila_index ordered_data ../results/fastqcs &> process.log

for file in $(ls raw_data/ENC*);
do {
    echo "Processing $file..."
    fastqc $file --outdir=../results/fastqcs &>> process.log;    # FastQC check
    filename=$(gunzip -l -N $file | awk 'FNR == 2 {print $4}').gz;    # Extracting the full name to use it for finding the two pairs (1 and 2)
    filename=${filename/raw_data\//}
    ln -s $file ordered_data/$filename;
}; done



# kallisto index
echo $'\nBuilding an index file from the refference...\n'

if ! [ -a drosophila_index/trnscrptm.idx ]    # check if the index exists
    then
        kallisto index -i drosophila_index/trnscrptm.idx raw_data/Drosophila_melanogaster.BDGP6.22.cdna.all.fa.gz &>> process.log;
fi



# kallisto quantifications
echo $'Indexing Done.\n-----------------------------------------------------\n'
echo $'Running kallisto quantifications...\n'
echo "sample condition" > save.txt
for R1 in $(find ordered_data/*pair1*);
    do {
        R2=${R1/pair1/pair2};    # Finding pair2 by replacing them as they have the same names
        group=${R1:26:4};    # Finding the group which sample belongs to (e.g control, treatment)
        name=$(ls -ls $R1 | awk -F '->' '{print $2}'); name=${name/raw_data\//}; name=${name/.fa*gz/};    # Finding the corresponding files
        R1=$(ls -ls $R1 | awk -F '->' '{print $2}'); R2=$(ls -ls $R2 | awk -F '->' '{print $2}');
        echo "$name $group" >> save.txt;
        echo "Processing $name...";
        echo "$R1 , $R2";
        mkdir -p ../results/kallisto/${name:1};
        kallisto quant -i drosophila_index/trnscrptm.idx -o ../results/kallisto/${name:1} --bootstrap-sample=50 $R1 $R2 &>> process.log;
        echo "$name Done.";
        echo $'-----------------------------------------------------\n';
    }; done

mv save.txt metadata.txt



# Sleuth
echo $'\nRunning R codes for Sleuth analysis...\n'
Rscript sleuth.R &>> process.log



echo $'\nAnalysis Done!\n'
End=`date +%s`
Runtime=$((End-start))
Runtime_min=$((Runtime/60))
Runtime_sec=$((Runtime%60))
echo "The total Runtime of this Pipeline was $Runtime_min minutes and $Runtime_sec seconds"
