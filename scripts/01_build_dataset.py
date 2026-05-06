import pandas as pd
import numpy as np

r2025_r1 = pd.read_csv('../data/pkw_2025_r1_communes.csv', sep=';', encoding='utf-8-sig')
r2025_r2 = pd.read_csv('../data/pkw_2025_r2_communes.csv', sep=';', encoding='utf-8-sig')
r2020_r1 = pd.read_csv('../data/pkw_2020_r1_pct_communes.csv', sep=';', encoding='utf-8-sig')
r2020_r2 = pd.read_csv('../data/pkw_2020_r2_pct_communes.csv', sep=';', encoding='utf-8-sig')
pop = pd.read_csv('../data/gus_bdl_population_density_2023.csv', sep=';', encoding='utf-8-sig')
unemp = pd.read_csv('../data/gus_bdl_unemployment_2024.csv', sep=';', encoding='utf-8-sig')

r2025_r1['teryt'] = r2025_r1['TERYT Gminy'].astype(str).str.replace('.0','',regex=False).str.strip().str.zfill(6)
r2025_r2['teryt'] = r2025_r2['TERYT Gminy'].astype(str).str.replace('.0','',regex=False).str.strip().str.zfill(6)
r2020_r1['teryt'] = r2020_r1['Kod TERYT'].astype(str).str.strip().str.zfill(6)
r2020_r2['teryt'] = r2020_r2['Kod TERYT'].astype(str).str.strip().str.zfill(6)

r2025_r1['eligible'] = pd.to_numeric(r2025_r1['Liczba wyborców uprawnionych do głosowania'], errors='coerce')
r2025_r1['voted_r1'] = pd.to_numeric(r2025_r1['Liczba wyborców, którym wydano karty do głosowania w lokalu wyborczym oraz w głosowaniu korespondencyjnym (łącznie)'], errors='coerce')
r2025_r1['valid_r1'] = pd.to_numeric(r2025_r1['Liczba głosów ważnych oddanych łącznie na wszystkich kandydatów'], errors='coerce')
r2025_r1['turnout_r1'] = (r2025_r1['voted_r1'] / r2025_r1['eligible']) * 100

candidates_r1 = {
    'mentzen_pct': 'MENTZEN Sławomir Jerzy',
    'nawrocki_pct_r1': 'NAWROCKI Karol Tadeusz',
    'braun': 'BRAUN Grzegorz Michał',
    'holownia': 'HOŁOWNIA Szymon Franciszek',
    'biejat': 'BIEJAT Magdalena Agnieszka',
    'zandberg': 'ZANDBERG Adrian Tadeusz',
}
for col, cand in candidates_r1.items():
    r2025_r1[col] = (pd.to_numeric(r2025_r1[cand], errors='coerce') / r2025_r1['valid_r1']) * 100

r2025_r2['eligible_r2'] = pd.to_numeric(r2025_r2['Liczba wyborców uprawnionych do głosowania'], errors='coerce')
r2025_r2['voted_r2'] = pd.to_numeric(r2025_r2['Liczba wyborców, którym wydano karty do głosowania w lokalu wyborczym oraz w głosowaniu korespondencyjnym (łącznie)'], errors='coerce')
r2025_r2['valid_r2'] = pd.to_numeric(r2025_r2['Liczba głosów ważnych oddanych łącznie na wszystkich kandydatów'], errors='coerce')
r2025_r2['turnout_r2'] = (r2025_r2['voted_r2'] / r2025_r2['eligible_r2']) * 100
r2025_r2['nawrocki_pct'] = (pd.to_numeric(r2025_r2['NAWROCKI Karol Tadeusz'], errors='coerce') / r2025_r2['valid_r2']) * 100

r2020_r1['duda_2020'] = pd.to_numeric(r2020_r1['Andrzej Sebastian DUDA'].astype(str).str.replace(',','.'), errors='coerce')
r2020_r2['trzaskowski_2020_r2'] = pd.to_numeric(r2020_r2['Rafał Kazimierz TRZASKOWSKI'].astype(str).str.replace(',','.'), errors='coerce')
r2020_r2['duda_2020_r2'] = pd.to_numeric(r2020_r2['Andrzej Sebastian DUDA'].astype(str).str.replace(',','.'), errors='coerce')

pop['code_str'] = pop['Code'].astype(str)
pop_gmina = pop[(pop['code_str'].str.len()==7) & (~pop['code_str'].str.endswith('000'))].copy()
pop_gmina['pkw_code'] = pop_gmina['code_str'].str[:-1]
density = pop_gmina[pop_gmina['Indicators']=='population per 1 km2'][['pkw_code','Value']].rename(columns={'Value':'pop_density'}).drop_duplicates('pkw_code')
urban_r = pop_gmina[pop_gmina['Indicators']=='urbanization rate'][['pkw_code','Value']].rename(columns={'Value':'urban_rate'}).drop_duplicates('pkw_code')

unemp['code_str'] = unemp['Code'].astype(str).str.zfill(7)
unemp_gmina = unemp[(unemp['code_str'].str.len()==7) & (~unemp['code_str'].str.endswith('000')) & (unemp['Unemployed']=='total')].copy()
unemp_gmina['pkw_code'] = unemp_gmina['code_str'].str[:-1]
unemp_clean = unemp_gmina[['pkw_code','Value']].rename(columns={'Value':'unemployed'}).drop_duplicates('pkw_code')

cols_r1 = ['teryt','Gmina','Województwo','eligible','turnout_r1','mentzen_pct','nawrocki_pct_r1','braun','holownia','biejat','zandberg']
df = r2025_r1[cols_r1].merge(r2025_r2[['teryt','turnout_r2','nawrocki_pct']], on='teryt', how='inner')
df = df.merge(r2020_r1[['teryt','duda_2020']], on='teryt', how='inner')
df = df.merge(r2020_r2[['teryt','trzaskowski_2020_r2','duda_2020_r2']], on='teryt', how='left')
df = df.merge(density, left_on='teryt', right_on='pkw_code', how='left')
df = df.merge(urban_r, left_on='teryt', right_on='pkw_code', how='left')
df = df.merge(unemp_clean, left_on='teryt', right_on='pkw_code', how='left')

df['turnout_delta'] = df['turnout_r2'] - df['turnout_r1']
df['nawrocki_swing'] = df['nawrocki_pct'] - df['nawrocki_pct_r1']
df['trzaskowski_r2'] = 100 - df['nawrocki_pct']
df['trzaskowski_shift'] = df['trzaskowski_r2'] - df['trzaskowski_2020_r2']
df['right_bloc'] = df['mentzen_pct'] + df['braun']
df['left_bloc'] = df['zandberg'] + df['biejat']
df['bloc_diff'] = df['right_bloc'] - df['left_bloc']
df['commune_type'] = df['teryt'].str[-1].map({'1':'Urban','2':'Urban-Rural','3':'Rural','4':'Urban','5':'Rural'})
df['unemployed_rate'] = df['unemployed'] / df['eligible'] * 100

df.to_csv('../data/master_dataset.csv', index=False)
print(f"Master dataset: {len(df)} communes, {df.shape[1]} variables")
