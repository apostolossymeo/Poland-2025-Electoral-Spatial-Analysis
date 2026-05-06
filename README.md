## Overview

The paper analysis whether the anti-establishment vote in Poland's 2025 presidential first round constitutes a unified political phenomenon or two structurally distinct electorates, using commune-level electoral data across 2,494 units. The central finding is a robust negative spatial correlation between Mentzen (Confederation) and Zandberg (Razem) first-round vote shares (r = -0.418), with every structural predictor reversing sign between models, providing strong ecological evidence of a GAL-TAN cleavage rather than a unified populist formation.


## Data Sources

| File | Source | Description | Access |
|------|--------|-------------|--------|
| `pkw_2025_r1_communes.csv` | National Electoral Commission (PKW), 2025 | First round results by commune, absolute counts | https://prezydent2025.pkw.gov.pl/prezydent2025/en/dane_w_arkuszach |
| `pkw_2025_r2_communes.csv` | National Electoral Commission (PKW), 2025 | Second round results by commune, absolute counts | https://prezydent2025.pkw.gov.pl/prezydent2025/en/dane_w_arkuszach |
| `pkw_2020_r1_pct_communes.csv` | National Electoral Commission (PKW), 2020 | First round results by commune, percentages | https://prezydent20200628.pkw.gov.pl/prezydent20200628/pl/dane_w_arkuszach |
| `pkw_2020_r2_pct_communes.csv` | National Electoral Commission (PKW), 2020 | Second round results by commune, percentages | https://prezydent20200628.pkw.gov.pl/prezydent20200628/pl/dane_w_arkuszach |
| `gus_bdl_population_density_2023.csv` | GUS Local Data Bank (BDL), 2023 | Population density and urbanization rate by commune | https://bdl.stat.gov.pl |
| `gus_bdl_unemployment_2024.csv` | GUS Local Data Bank (BDL), 2024 | Registered unemployed persons by commune (December 2024) | https://bdl.stat.gov.pl |

Administrative boundaries used in Figure 5 are sourced from GUGiK (2024) via https://gis-support.pl/baza-wiedzy-2/dane-do-pobrania/granice-administracyjne/ and are not included in this repository due to file size. The shapefile (`gminy.shp`) should be placed in a `shapefiles/` directory and the path updated in `03_figures.R`.

Commune identifiers follow the Polish TERYT code system. All datasets are merged on the 6-digit TERYT commune code.


## Replication

**Requirements:** Python 3.9+, R 4.3+

Python packages: `pandas`, `numpy`, `statsmodels`

R packages: `ggplot2`, `dplyr`, `broom`, `sf`, `gridExtra`

**To replicate:**

```bash
cd scripts
python 01_build_dataset.py   # builds master_dataset.csv
python 02_analysis.py        # prints all regression and correlation output
Rscript 03_figures.R         # generates all five figures into figures/
```

Scripts are designed to run from the `scripts/` directory with relative paths to `../data/` and `../figures/`.


## Key Variables in master_dataset.csv

| Variable | Description |
|----------|-------------|
| `teryt` | 6-digit TERYT commune identifier |
| `mentzen_pct` | Mentzen first-round vote share (%) |
| `zandberg` | Zandberg first-round vote share (%) |
| `braun` | Braun first-round vote share (%) |
| `biejat` | Biejat first-round vote share (%) |
| `nawrocki_pct` | Nawrocki second-round vote share (%) |
| `turnout_r1` | First-round voter turnout (%) |
| `turnout_r2` | Second-round voter turnout (%) |
| `duda_2020` | Duda 2020 first-round vote share (%) — right-wing baseline |
| `pop_density` | Population per km2 (GUS BDL 2023) |
| `urban_rate` | Urbanization rate (GUS BDL 2023) |
| `commune_type` | Urban / Urban-Rural / Rural (derived from TERYT) |
| `right_bloc` | Mentzen + Braun combined first-round share |
| `left_bloc` | Zandberg + Biejat combined first-round share |

## Acknowledgements

The author thanks [@weronika-nitecka](https://github.com/weronika-nitecka) for substantive input during the conceptual development of this analysis. As a Polish national with direct familiarity with the 2025 electoral context, her insights on the political geography and candidate profiles of the Polish presidential race informed the framing of the research question.

## Notes

The BDL population density file uses a different territorial coding system than PKW. The merge in `01_build_dataset.py` strips the final digit from BDL 7-digit codes to match PKW 6-digit TERYT codes, recovering a match rate of approximately 1,886 of 2,494 communes for socioeconomic variables. All electoral analysis uses the full 2,494-commune dataset.
