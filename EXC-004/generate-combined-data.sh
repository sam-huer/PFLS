mkdir -p COMBINED-DATA

for i in $(ls RAW-DATA | grep "D")
do

#extract XXX
culture_name=$(grep "$i" RAW-DATA/sample-translation.txt | awk '{print $2}')                      

#copying unbinned, checkm and gtdb
cp RAW-DATA/$i/bins/bin-unbinned.fasta COMBINED-DATA/${culture_name}_UNBINNED.fa         
cp RAW-DATA/$i/checkm.txt COMBINED-DATA/${culture_name}-CHECKM.txt 
cp RAW-DATA/$i/gtdb.gtdbtk.tax COMBINED-DATA/${culture_name}-GTDB-TAX.txt

#set YYY counter for MAG and BIN numbers to 0
numbering_MAG=0
numbering_BIN=0

    for g in $(ls RAW-DATA/$i/bins/ | grep -v "unbinned" | awk 'BEGIN{FS=".fasta"}{print $1}') #grep all files which do not contain "unbinned"
    do

    #extract information for YYY and round numbers to integers
    completeness=$(awk -v pattern=$g '$0 ~ pattern {print $13}' RAW-DATA/$i/checkm.txt) 
    contamination=$(awk -v pattern=$g '$0 ~ pattern {print $14}' RAW-DATA/$i/checkm.txt)                                              
        
        # choose if YYY is MAG or BIN
        if [ $(echo $completeness | awk -F "." '{print $1}') -ge 50 ] && [ $(echo $contamination | awk -F "." '{print $1}') -lt 5 ]; then               
            genome_type="MAG"
            
            #adjust numbering of MAG
            numbering_MAG=$((numbering_MAG + 1))
            numbering_MAG_decimal=$(printf "%03d" $numbering_MAG)

            #change contig names to unique defline with XXX information
            sed -e "s/>.*:/>mag_${numbering_MAG_decimal}_${culture_name}:/" RAW-DATA/$i/bins/${g}.fasta > COMBINED-DATA/${culture_name}_${genome_type}_${numbering_MAG_decimal}.fa
            echo "$g is a mag with $completeness completeness and $contamination contamination: ${culture_name}_${genome_type}_${numbering_MAG_decimal}.fa"
        else 
            genome_type="BIN" 

            #adjust numbering of BIN
            numbering_BIN=$((numbering_BIN + 1))
            numbering_BIN_decimal=$(printf "%03d" $numbering_BIN)

            #change contig names to unique defline with XXX information
            sed -e "s/>.*:/>bin_${numbering_BIN_decimal}_${culture_name}:/" RAW-DATA/$i/bins/${g}.fasta > COMBINED-DATA/${culture_name}_${genome_type}_${numbering_BIN_decimal}.fa              
            echo "$g stays a bin with $completeness completeness and $contamination contamination: ${culture_name}_${genome_type}_${numbering_BIN_decimal}.fa"
        fi
    

    done
done








