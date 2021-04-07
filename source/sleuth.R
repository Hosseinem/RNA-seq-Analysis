library("sleuth")

ENC_dir = dir(file.path('../results/kallisto/'))

Kal_dir = file.path('../results/kallisto', ENC_dir)

s2c <- read.table(file.path("metadata.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c <- dplyr::select(s2c, sample, condition)
s2c <-  s2c[order(s2c$sample),]
s2c <- dplyr::mutate(s2c, path = Kal_dir)

so <- sleuth_prep(s2c, extra_bootstrap_summary = TRUE)

so <- sleuth_fit(so, ~condition, 'full')

so <- sleuth_fit(so, ~1, 'reduced')

so <- sleuth_lrt(so, 'reduced' , 'full')

sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.5)

print("Table of Sleuth's Results:")
head(sleuth_significant, 20)

write.table(sleuth_significant, "../results/result.tsv", sep = "    ", eol = "\n", na = "NA", dec = ".", row.names = TRUE, col.names = TRUE)
