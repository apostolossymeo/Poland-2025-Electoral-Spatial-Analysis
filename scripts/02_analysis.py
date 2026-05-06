import pandas as pd
import numpy as np
import statsmodels.formula.api as smf

df = pd.read_csv('../data/master_dataset.csv')

print("=== CORE FINDING: Mentzen vs Zandberg ===")
r = df['mentzen_pct'].corr(df['zandberg'])
print(f"r(Mentzen, Zandberg) = {r:.4f}, n = {len(df)}")

print("\n=== FULL ANTI-ESTABLISHMENT CORRELATION MATRIX ===")
vars_corr = ['mentzen_pct','braun','zandberg','biejat','duda_2020','turnout_r1','urban_rate','pop_density','nawrocki_pct','trzaskowski_r2']
cm = df[vars_corr].corr(method='pearson')
print(cm.round(3).to_string())

print("\n=== BLOC CORRELATIONS ===")
pairs = [
    ('mentzen_pct','braun'), ('zandberg','biejat'),
    ('mentzen_pct','biejat'), ('zandberg','braun'),
    ('mentzen_pct','zandberg'),
    ('right_bloc','duda_2020'), ('left_bloc','turnout_r1'),
]
for a, b in pairs:
    print(f"  r({a}, {b}) = {df[a].corr(df[b]):.4f}")

print("\n=== OLS MODEL: Mentzen ~ structural predictors ===")
m_mentzen = smf.ols('mentzen_pct ~ duda_2020 + turnout_r1 + pop_density + urban_rate', data=df).fit()
print(m_mentzen.summary().tables[1])
print(f"R² = {m_mentzen.rsquared:.4f}")

print("\n=== OLS MODEL: Zandberg ~ structural predictors ===")
m_zandberg = smf.ols('zandberg ~ duda_2020 + turnout_r1 + pop_density + urban_rate', data=df).fit()
print(m_zandberg.summary().tables[1])
print(f"R² = {m_zandberg.rsquared:.4f}")

print("\n=== STANDARDIZED MODELS ===")
df_std = df.copy()
for v in ['mentzen_pct','zandberg','duda_2020','turnout_r1','pop_density','urban_rate']:
    df_std[v+'_z'] = (df[v] - df[v].mean()) / df[v].std()

mm_std = smf.ols('mentzen_pct_z ~ duda_2020_z + turnout_r1_z + pop_density_z + urban_rate_z', data=df_std).fit()
mz_std = smf.ols('zandberg_z ~ duda_2020_z + turnout_r1_z + pop_density_z + urban_rate_z', data=df_std).fit()
print("Mentzen standardized betas:")
print(mm_std.params.round(4))
print(f"R² = {mm_std.rsquared:.4f}")
print("\nZandberg standardized betas:")
print(mz_std.params.round(4))
print(f"R² = {mz_std.rsquared:.4f}")

print("\n=== DISTRIBUTIONAL STATS ===")
for cand in ['mentzen_pct','braun','zandberg','biejat']:
    print(f"  {cand}: mean={df[cand].mean():.2f}%, sd={df[cand].std():.2f}%, min={df[cand].min():.2f}%, max={df[cand].max():.2f}%")

print("\n=== URBAN/RURAL BREAKDOWN ===")
urban_df = df[df['commune_type'].notna()].groupby('commune_type').agg(
    mentzen=('mentzen_pct','mean'), zandberg=('zandberg','mean'),
    right_bloc=('right_bloc','mean'), left_bloc=('left_bloc','mean'), n=('teryt','count')
).round(2)
print(urban_df.to_string())

print("\n=== 2020 vs 2025 BASELINE ===")
r_duda_nawrocki = df['duda_2020'].corr(df['nawrocki_pct'])
r_duda_nawrocki_r2 = df['duda_2020_r2'].corr(df['nawrocki_pct'])
print(f"  r(Duda 2020 R1, Nawrocki 2025 R2) = {r_duda_nawrocki:.4f}")
print(f"  r(Duda 2020 R2, Nawrocki 2025 R2) = {r_duda_nawrocki_r2:.4f}")
