# HAP1: EviAnn (ref) + Helixer (add)

agat_sp_complement_annotations.pl \

  --ref  results/EviAnn-Annotation/drLotPedu.AARHUS.ETHZ.v1.hap1.combined_2026-05-27/drLotPedu.AARHUS.ETHZ.v1.hap1.2026-05-27.fa.pseudo_label.gff \

  --add  results/helixer-annotation/drLotPedu_h1Complete_hx.gff \

  --out  results/complemented-annotation/drLotPedu_hap1_eviann_plus_helixer.gff

  

# HAP2: EviAnn (ref) + Helixer (add)

agat_sp_complement_annotations.pl \

  --ref  results/EviAnn-Annotation/drLotPedu.AARHUS.ETHZ.v1.hap2.combined_2026-05-27/drLotPedu.AARHUS.ETHZ.v1.hap2.combined.2026-05-27.fa.pseudo_label.gff \

  --add  results/helixer-annotation/drLotPedu_h2Complete_hx.gff \

  --out  results/complemented-annotation/drLotPedu_hap2_eviann_plus_helixer.gff
