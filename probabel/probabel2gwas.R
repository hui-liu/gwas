args <- commandArgs(trailingOnly = TRUE)
infn = args[1]
outfn = args[2]
freqfn = args[3]

if (length(args) > 3) {
	freqmap = args[4]
} else {
	freqmap = NA
}

print("read probabel result")
probable = read.table(infn, h=T)
summary(probable)

#name A1 A2 Freq1 MAF Quality Rsq n Mean_predictor_allele chrom position beta_SNP_add sebeta_SNP_add chi2_SNP
#SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    AF_coded_all    HWE_pval        callrate        n_total imputed used_for_imp    oevar_imp
out = data.frame(
	SNP=probable$name,
	chr=probable$chrom,
	position=probable$position,
	coded_all=probable$A1,
	noncoded_all=probable$A2,
	strand_genome="+",
	beta=probable$beta_SNP_add,
	SE=probable$sebeta_SNP_add,
	pval=pchisq(probable$chi2_SNP, df=1, low=F),
	AF_coded_all=probable$Freq1,            # -1, wird ersetzt
	HWE_pval=1,
	callrate=probable$Quality,              # -1, wird ersetzt
	n_total=probable$n,
	imputed=0, 				# wird ersetzt
	used_for_imp=1, 			# wird ersetzt
	oevar_imp=1 				# haben wir derzeit nicht, aber "information" measure
	)
summary(out)

rm(probable)

print("read SNP freqs")
freqs = read.table(freqfn, h=T)
summary(freqs)

# SNPID RSID chromosome position A_allele B_allele minor_allele major_allele AA AB BB       AA_calls AB_calls BB_calls MAF HWE missing missing_calls information
# --- rs190080431 NA 16462950    G T T G                                     268.96 1.043 0 269 1 0                    0.0019315 -0 0 0 0.9012
# rs35416799 rs35416799 NA 16869887 G A A G                                  240 30 0       240 30 0                   0.055556 -0 0 0 1

freq_short = data.frame(
        SNP=freqs$RSID,
	A1FREQ=(2 * freqs$AA + freqs$AB)/(2*(freqs$AA+freqs$AB+freqs$BB)),
	CALLRA=1-freqs$missing,
	IMPUTD=(freqs$SNPID == "---"),
	INFORM=freqs$information)
rm(freqs)

if (!is.na(freqmap)) {
	#ORIG_SNP_ID     SHORTENED_SNP_ID
	#rs10875231:100000012:G:T        rs10875231
	print(paste("map freq SNP names", freqmap))
	fm = read.table(freqmap, h=T)
	print(summary(fm))
	freq_short2 = merge(freq_short, fm, by.x="SNP", by.y="ORIG_SNP_ID")
	print(nrow(freq_short))
	print(nrow(fm))
	print(nrow(freq_short2))
	freq_short2$SNP = NULL
	freq_short2$SNP = freq_short2$SHORTENED_SNP_ID
	freq_short2$SHORTENED_SNP_ID = NULL
	freq_short = freq_short2
	summary(freq_short)
}

final = merge(out, freq_short, all.x=T, by="SNP")

final$AF_coded_all = final$A1FREQ
final$callrate = final$CALLRA
final$imputed = ifelse(final$IMPUTD, 1, 0)
final$used_for_imp = ifelse(final$IMPUTD, 0, 1)
final$oevar_imp = final$INFORM

final$A1FREQ = NULL
final$CALLRA = NULL
final$IMPUTD = NULL
final$INFORM = NULL

final = final[order(final$position),]

write.table(final, outfn, row.names=F, col.names=T, quote=F, sep="\t")
