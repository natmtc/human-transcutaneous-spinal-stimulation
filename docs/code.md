# Code map

All analysis code is in [`src/functions/`](../src/functions/). Notebooks add `src/` to the path
and import from the package directly:

```python
from functions import set_style, load_run, thresholds_for, condition_table, fig_vibration
```

Everything public is re-exported from [`__init__.py`](../src/functions/__init__.py), which is the
quickest way to see the full surface.

---

## The modules

### Foundations

| module | |
|---|---|
| [`io.py`](../src/functions/io.py) | load a recording (`load_run`), find every pulse from the trigger channel (`detect_pulses`), and map a recording to its session (`SESSIONS`, `session_of`, `result_path`) |
| [`labels.py`](../src/functions/labels.py) | channel code → readable muscle name (`LABELS`, `pretty`) |
| [`style.py`](../src/functions/style.py) | one matplotlib style for every figure (`set_style`) |

`io.py` locates columns **by name**, so the same loader handles single-pulse, paired-pulse, burst
and modulated files despite their differing parameter columns. It is also the one place the
recorder's folder-naming quirks are reconciled — see
[data.md](data.md#the-recorders-folder-names-are-not-the-session-names).

### Measurement

| module | |
|---|---|
| [`burst.py`](../src/functions/burst.py) | the core measurement: per-pulse peak-to-peak along a train (`burst_p2p`), anchored peak detection, artifact width per channel (`artifact_extent`), the noise floor (`noise_p2p`), the response criterion (`responding_table`, `motor_threshold`), train figures and `diagnostics` |
| [`threshold.py`](../src/functions/threshold.py) | the interactive motor-threshold picker and its CSV (`threshold_picker`, `save_threshold_csv`, `thresholds_for`, `threshold_source`) |
| [`latency.py`](../src/functions/latency.py) | the single-pulse latency picker and its CSV |

`burst.py` is the module to read first if you want to check how a number is produced.
`diagnostics` prints the artifact width per channel, which trains pass the response criterion and
from which milliamp, and which channels clipped — it is the intended way to check a recording
before trusting its numbers.

### Comparison and figures

| module | |
|---|---|
| [`across.py`](../src/functions/across.py) | everything cross-session — the tables and figures the comparison notebooks are built from |
| [`plots.py`](../src/functions/plots.py) | waterfalls (`waterfall`, `waterfall_overlay`) and latency traces |
| [`paper.py`](../src/functions/paper.py) | publication-style figures: no grids, scale bars, one colour per condition |

### Earlier single-session analyses

| module | |
|---|---|
| [`quantify.py`](../src/functions/quantify.py), [`compare.py`](../src/functions/compare.py), [`average.py`](../src/functions/average.py) | still used by the per-session notebooks |
| [`snr.py`](../src/functions/snr.py) | **no longer called by any notebook.** Retained because it produced the committed `results/*/SNR_*.csv` files; kept so their provenance is not orphaned. |

---

## The functions worth knowing in `across.py`

This is the largest module. The notebooks lean on a handful of entry points:

**Building a comparison**

| | |
|---|---|
| `condition_table(runs, MT, muscles, conditions, base=…, match="common", group=…)` | the workhorse. Reads every recording at each muscle's threshold and returns one record per (panel, condition, muscle) holding `amp`, `p1`, `p2`, `rest`, `mean_all`, `snr`, `dep2`, `dep_rest`, `pct`, `pct_all`. `group` keeps protocols and polarities on separate ladders and thresholds; `match="common"` handles ladders that differ between blocks. Aliased as `vibration_table`. |
| `latency_table(runs, MT, muscles, conditions, k_sd=3.0, min_run=2)` | the same shape, for onset and peak time: `onset_ms`, `peak_ms`, `jitter_ms`, `n_onset`, `n_pulses`. |
| `snr_verdict(tab, key, base_cond, ratio)` | the **single source of truth** for whether a reading is reportable. Tables and figures both route through it, so they cannot disagree — they once did. |

**Figures**

| | |
|---|---|
| `fig_vibration(...)` | the condition bar figure: `key` selects which measure, `hatches` and `linestyles` encode a second factor without using colour, `ref` draws the control line |
| `fig_group_summary(...)`, `fig_group_panels(...)` | mean ± SD/SEM across muscles, with the individual readings as dots |
| `fig_bars(...)` | bars above the EMG traces they came from, one trace column per participant |
| `fig_threshold_grid(...)` | every intensity of every recording stacked, the picked threshold highlighted; `share_gain=True` puts rows on one scale |
| `fig_detection_grid(...)` | the measurement window and the peaks actually used, for every recording × muscle in one figure |
| `fig_noise_check(...)` | the response window beside the pre-stimulus windows **on one scale** — the by-eye check that a flagged reading really is noise |
| `fig_latency_example(...)` | ten pulses with the baseline band, per-pulse onsets, and the mean onset and peak, showing exactly how a latency number is taken |

**Guards**

`check_thresholds`, `mt_stamp` and `warn_if_stale` catch the mistakes that are easy to make and
hard to see: a missing pick, a threshold outside its ladder, or a figure drawn from a threshold
file that has since changed.

---

## Conventions in the figures

Decided once and used throughout, so a reader does not have to relearn each figure:

- **Protocol is colour** — 30 Hz grey, ARC-EX red.
- **Polarity is never colour** — it is a fill pattern (hatch) or a line style, so that the two
  factors stay separable, including in greyscale.
- **Muscles are ordered left arm first, then right.**
- **Dots are the individual readings**, coloured to match their bar.
- **`n` is printed on every bar**, and a bar that was excluded says which case it is — never a
  blank. See [analysis.md](analysis.md#3--the-noise-floor-and-what-no-response-means).
- **Clipped outliers show their real value** as text rather than being silently cut off.
- **Waterfalls mark stimulus onset**, so artifact is never mistaken for response.
