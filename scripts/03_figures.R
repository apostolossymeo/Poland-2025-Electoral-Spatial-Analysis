library(ggplot2)
library(dplyr)
library(broom)
library(sf)
sf_use_s2(FALSE)

BASE_FONT <- "TeX Gyre Heros"
col_m <- "#C0392B"
col_z <- "#1A5276"

tp <- function(base_size=12) {
  theme_minimal(base_family=BASE_FONT, base_size=base_size) +
  theme(
    plot.background=element_rect(fill="white",color=NA),
    panel.background=element_rect(fill="white",color=NA),
    panel.grid.major=element_line(color="#EBEBEB",linewidth=0.32),
    panel.grid.minor=element_blank(),
    axis.line=element_line(color="#BBBBBB",linewidth=0.32),
    axis.ticks=element_line(color="#BBBBBB",linewidth=0.28),
    axis.text=element_text(size=base_size*0.88,color="#444444"),
    axis.title=element_text(size=base_size,color="#111111",face="bold"),
    plot.title=element_text(size=base_size*1.22,face="bold",color="#0D0D0D",
                            margin=margin(b=4),hjust=0,lineheight=1.1),
    plot.title.position="plot",
    plot.subtitle=element_text(size=base_size*0.88,color="#555555",
                                margin=margin(b=12),hjust=0,lineheight=1.32),
    plot.caption=element_text(size=base_size*0.70,color="#888888",hjust=0,
                               margin=margin(t=10),lineheight=1.25),
    plot.caption.position="plot",
    legend.position="top",
    legend.justification="left",
    legend.text=element_text(size=base_size*0.85,color="#333333"),
    legend.title=element_text(size=base_size*0.85,color="#333333",face="bold"),
    legend.key.size=unit(0.85,"lines"),
    plot.margin=margin(16,20,14,16),
    strip.text=element_text(face="bold",size=base_size*0.95,color="#111111")
  )
}

df <- read.csv('/home/claude/final_dataset.csv')

# FIG 1
r1 <- round(cor(df$mentzen_pct, df$zandberg, use="complete.obs"),3)
p1 <- ggplot(df, aes(mentzen_pct, zandberg)) +
  geom_point(alpha=0.12, size=0.78, color="#6C3483", shape=16) +
  geom_smooth(method="lm", se=TRUE, color="#1C2833", fill="#CACFD2",
              linewidth=0.85, alpha=0.22) +
  annotate("label",
           x=quantile(df$mentzen_pct,0.97,na.rm=T),
           y=quantile(df$zandberg,0.92,na.rm=T),
           label=paste0("r = ",r1,"\nn = 2,494 communes"),
           hjust=1, size=3.8, fontface="bold", color="#1C2833",
           family=BASE_FONT, fill="white", label.size=0.25,
           label.padding=unit(0.38,"lines")) +
  scale_x_continuous(labels=function(x) paste0(x,"%")) +
  scale_y_continuous(labels=function(x) paste0(x,"%")) +
  labs(
    title="Figure 1. Two Distinct Anti-Establishment Electorates",
    subtitle="Mentzen and Zandberg first-round shares are negatively correlated across communes,\nrefuting the hypothesis of a unified anti-system electorate",
    x="Mentzen (Confederation) first-round vote share",
    y="Zandberg (Razem) first-round vote share",
    caption="Note: Each point represents one commune (n = 2,494). OLS regression line with 95% confidence interval.\nSource: National Electoral Commission (PKW), Polish Presidential Election, First Round, May 2025."
  ) + tp()
ggsave("/home/claude/fig1_scatterplot.png",p1,width=10,height=7.2,dpi=320,bg="white")
cat("Fig1\n")

# FIG 2
vars2 <- c("mentzen_pct","braun","zandberg","biejat","duda_2020","turnout_r1","urban_rate","pop_density")
lbls2 <- c("Mentzen","Braun","Zandberg","Biejat","Duda 2020 R1","Turnout R1","Urbanization","Pop. Density")
cm2 <- cor(df[,vars2], use="pairwise.complete.obs")
rownames(cm2) <- lbls2; colnames(cm2) <- lbls2
cd2 <- expand.grid(var1=lbls2, var2=lbls2, stringsAsFactors=FALSE)
cd2$value <- mapply(function(r,c) cm2[r,c], cd2$var1, cd2$var2)
cd2$var1 <- factor(cd2$var1, levels=rev(lbls2))
cd2$var2 <- factor(cd2$var2, levels=lbls2)
cd2$tc <- ifelse(abs(cd2$value)>0.52,"white","#333333")

p2 <- ggplot(cd2, aes(var2,var1,fill=value)) +
  geom_tile(color="white",linewidth=0.65) +
  geom_text(aes(label=sprintf("%.2f",value), color=tc),
            size=3.45, fontface="bold", family=BASE_FONT) +
  scale_color_identity() +
  scale_fill_gradient2(low=col_z, mid="#F5F6FA", high=col_m,
    midpoint=0, limits=c(-1,1), name="Pearson r",
    breaks=c(-1,-0.5,0,0.5,1), labels=c("-1.0","-0.5","0","0.5","1.0"),
    guide=guide_colorbar(barwidth=9,barheight=0.5,title.position="top",
                         title.hjust=0.5,direction="horizontal")) +
  labs(
    title="Figure 2. Two Internally Coherent Anti-Establishment Blocs",
    subtitle="Right-populist bloc (Mentzen, Braun) shares right-wing geographic roots;\nleft-protest bloc (Zandberg, Biejat) shares urban and high-turnout geography",
    x=NULL, y=NULL,
    caption="Note: Pearson correlation coefficients computed across 2,494 communes.\nSource: PKW (2025); GUS Local Data Bank (2023) for urbanization and population density."
  ) +
  tp(base_size=11) +
  theme(axis.text.x=element_text(angle=38,hjust=1,size=10.5),
        axis.text.y=element_text(size=10.5),
        panel.grid=element_blank(), legend.position="bottom",
        legend.justification="center")
ggsave("/home/claude/fig2_heatmap.png",p2,width=10.5,height=9,dpi=320,bg="white")
cat("Fig2\n")

# FIG 3 — diverging bar chart
ds <- df
for(v in c("mentzen_pct","zandberg","duda_2020","turnout_r1","pop_density","urban_rate"))
  ds[[paste0(v,"_z")]] <- as.numeric(scale(df[[v]]))
mm <- lm(mentzen_pct_z~duda_2020_z+turnout_r1_z+pop_density_z+urban_rate_z, data=ds)
mz <- lm(zandberg_z~duda_2020_z+turnout_r1_z+pop_density_z+urban_rate_z, data=ds)
tm <- broom::tidy(mm,conf.int=TRUE) %>% filter(term!="(Intercept)") %>% mutate(model="Mentzen")
tz <- broom::tidy(mz,conf.int=TRUE) %>% filter(term!="(Intercept)") %>% mutate(model="Zandberg")
cf <- rbind(tm,tz)
tlabs <- c("duda_2020_z"="Right-wing baseline (Duda 2020 R1)",
           "urban_rate_z"="Urbanization rate",
           "pop_density_z"="Population density",
           "turnout_r1_z"="Voter turnout (R1)")
cf$predictor <- factor(tlabs[cf$term], levels=rev(tlabs))
cf$model <- factor(cf$model, levels=c("Mentzen","Zandberg"))

p3 <- ggplot(cf, aes(x=estimate, y=predictor, fill=model)) +
  geom_col(data=filter(cf, model=="Mentzen"), width=0.38, alpha=0.92,
           position=position_nudge(y=0.20)) +
  geom_col(data=filter(cf, model=="Zandberg"), width=0.38, alpha=0.92,
           position=position_nudge(y=-0.20)) +
  geom_errorbar(data=filter(cf, model=="Mentzen"),
                aes(xmin=conf.low,xmax=conf.high),
                width=0.06, linewidth=0.7, color="#333333", alpha=0.6,
                position=position_nudge(y=0.20)) +
  geom_errorbar(data=filter(cf, model=="Zandberg"),
                aes(xmin=conf.low,xmax=conf.high),
                width=0.06, linewidth=0.7, color="#333333", alpha=0.6,
                position=position_nudge(y=-0.20)) +
  geom_vline(xintercept=0, color="#555555", linewidth=0.7) +
  scale_fill_manual(values=c("Mentzen"=col_m,"Zandberg"=col_z), name=NULL) +
  scale_x_continuous(limits=c(-0.78,0.78),
                     labels=function(x) ifelse(x==0,"0",sprintf("%+.2f",x)),
                     breaks=c(-0.6,-0.4,-0.2,0,0.2,0.4,0.6)) +
  labs(
    title="Figure 3. Structural Predictors Move in Opposite Directions",
    subtitle="Every variable predicts Mentzen and Zandberg with opposite sign,\nconfirming two structurally distinct electoral logics",
    x="Standardized beta coefficient (with 95% CI)",
    y=NULL,
    caption="Note: Standardized OLS regression coefficients. n = 1,886 communes with complete socioeconomic data.\nSource: PKW (2025); GUS Local Data Bank (2023)."
  ) +
  theme_minimal(base_family=BASE_FONT, base_size=12) +
  theme(
    plot.background=element_rect(fill="white",color=NA),
    panel.background=element_rect(fill="white",color=NA),
    panel.grid.major.y=element_blank(),
    panel.grid.major.x=element_line(color="#EBEBEB",linewidth=0.32),
    panel.grid.minor=element_blank(),
    axis.line.x=element_line(color="#BBBBBB",linewidth=0.32),
    axis.ticks.x=element_line(color="#BBBBBB",linewidth=0.28),
    axis.ticks.y=element_blank(),
    axis.text.x=element_text(size=10.5,color="#444444"),
    axis.text.y=element_text(size=12,color="#111111",lineheight=1.2,
                              margin=margin(r=6)),
    axis.title.x=element_text(size=12,color="#111111",face="bold",
                               margin=margin(t=8)),
    plot.title=element_text(size=14.5,face="bold",color="#0D0D0D",
                            margin=margin(b=4),hjust=0,lineheight=1.1),
    plot.title.position="plot",
    plot.subtitle=element_text(size=10.5,color="#555555",
                                margin=margin(b=12),hjust=0,lineheight=1.32),
    plot.caption=element_text(size=9,color="#888888",hjust=0,
                               margin=margin(t=10),lineheight=1.25),
    plot.caption.position="plot",
    legend.position="top",
    legend.justification="left",
    legend.text=element_text(size=11,color="#333333"),
    plot.margin=margin(16,20,14,16)
  )
ggsave("/home/claude/fig3_coefplot.png",p3,width=10.5,height=6.5,dpi=320,bg="white")
cat("Fig3\n")

# FIG 4
dk <- rbind(
  data.frame(share=df$mentzen_pct, cand="Mentzen (Confederation)", bloc="Right anti-establishment"),
  data.frame(share=df$braun, cand="Braun (KKP)", bloc="Right anti-establishment"),
  data.frame(share=df$zandberg, cand="Zandberg (Razem)", bloc="Left anti-establishment"),
  data.frame(share=df$biejat, cand="Biejat (Lewica)", bloc="Left anti-establishment")
)
dk$cand <- factor(dk$cand, levels=c("Mentzen (Confederation)","Braun (KKP)",
                                     "Zandberg (Razem)","Biejat (Lewica)"))
var_df <- dk %>% group_by(cand,bloc) %>%
  summarise(sd_v=round(sd(share,na.rm=T),2), mu=round(mean(share,na.rm=T),2), .groups="drop") %>%
  mutate(lbl=paste0("Mean: ",mu,"%  SD: ",sd_v,"%"))

p4 <- ggplot(dk, aes(share,fill=bloc,color=bloc)) +
  geom_density(alpha=0.2, linewidth=0.92) +
  geom_text(data=var_df, aes(x=Inf, y=Inf, label=lbl, color=bloc),
            hjust=1.06, vjust=1.5, size=3.2, fontface="bold",
            family=BASE_FONT, inherit.aes=FALSE) +
  facet_wrap(~cand, scales="free", ncol=2) +
  scale_fill_manual(values=c("Right anti-establishment"=col_m,
                             "Left anti-establishment"=col_z), name=NULL) +
  scale_color_manual(values=c("Right anti-establishment"=col_m,
                              "Left anti-establishment"=col_z), name=NULL) +
  scale_x_continuous(labels=function(x) paste0(x,"%")) +
  labs(
    title="Figure 4. Territorial Dispersion vs. Concentration of Anti-Establishment Vote",
    subtitle="Right-populist candidates show broader geographic spread across communes;\nleft-protest vote is more tightly concentrated in a narrower urban band",
    x="First-round vote share (%)", y="Density",
    caption="Note: Kernel density estimates across 2,494 communes.\nSource: PKW (2025), Polish Presidential Election, First Round, May 2025."
  ) + tp() +
  theme(strip.text=element_text(size=11,face="bold"),
        legend.justification="left")
ggsave("/home/claude/fig4_density.png",p4,width=11,height=8,dpi=320,bg="white")
cat("Fig4\n")

# FIG 5 — Map
gminy <- st_read("/home/claude/gminy_shp/gminy.shp", quiet=TRUE)
gminy$teryt6 <- substr(as.character(gminy$JPT_KOD_JE), 1, 6)
df$teryt6 <- sprintf("%06d", as.integer(df$teryt))
merged <- merge(gminy, df[,c("teryt6","mentzen_pct","zandberg")], by="teryt6", all.x=FALSE)
merged <- st_transform(merged, crs=4326)
merged <- st_make_valid(merged)
med_m <- median(merged$mentzen_pct, na.rm=TRUE)
med_z <- median(merged$zandberg, na.rm=TRUE)
merged$bivar <- factor(case_when(
  merged$mentzen_pct >= med_m & merged$zandberg <  med_z ~ "A",
  merged$mentzen_pct <  med_m & merged$zandberg >= med_z ~ "B",
  merged$mentzen_pct >= med_m & merged$zandberg >= med_z ~ "C",
  TRUE ~ "D"
), levels=c("A","B","C","D"))
bivar_colors <- c("A"="#C0392B","B"="#1A5276","C"="#7E5A8A","D"="#B2BEC3")
bivar_labels <- c(
  "A"="Right-populist stronghold (High Mentzen, Low Zandberg)",
  "B"="Left-protest stronghold (Low Mentzen, High Zandberg)",
  "C"="High anti-establishment (both)",
  "D"="Low anti-establishment (both)"
)
outline <- merged %>% summarise(geometry=st_union(geometry))

p5 <- ggplot(merged) +
  geom_sf(aes(fill=bivar), color=NA) +
  geom_sf(data=outline, fill=NA, color="#DDDDDD", linewidth=0.28) +
  scale_fill_manual(values=bivar_colors, labels=bivar_labels, name=NULL,
    guide=guide_legend(nrow=2,byrow=TRUE,override.aes=list(color=NA))) +
  labs(
    title="Figure 5. Territorial Separation of Anti-Establishment Electorates",
    subtitle="Right-populist strength concentrated in rural south and east;\nleft-protest strength concentrated in urban northern and western communes",
    caption="Note: Classification by commune-level median splits of Mentzen and Zandberg first-round vote shares.\nSource: PKW (2025); GUGiK administrative boundaries (2024)."
  ) +
  theme_void(base_family=BASE_FONT) +
  theme(
    plot.background=element_rect(fill="white",color=NA),
    plot.title=element_text(size=14.5,face="bold",color="#0D0D0D",
                            margin=margin(b=4),hjust=0,lineheight=1.1),
    plot.title.position="plot",
    plot.subtitle=element_text(size=10.5,color="#555555",
                                margin=margin(b=10),hjust=0,lineheight=1.35),
    plot.caption=element_text(size=9,color="#888888",hjust=0,
                               margin=margin(t=10),lineheight=1.25),
    plot.caption.position="plot",
    legend.position="bottom",
    legend.justification="left",
    legend.text=element_text(size=9.5,color="#333333",lineheight=1.3),
    legend.key.size=unit(1.1,"lines"),
    legend.spacing.x=unit(0.4,"cm"),
    plot.margin=margin(16,20,14,16)
  )
ggsave("/home/claude/fig5_map.png", p5, width=11, height=10, dpi=320, bg="white")
cat("Fig5\n")
cat("ALL DONE\n")
