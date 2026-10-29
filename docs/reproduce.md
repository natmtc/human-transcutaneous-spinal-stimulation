# Reproducing the analysis

## 1 · Install

Python 3.14, with the exact versions the analysis was run at:

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## 2 · Add the raw recordings (for the full analysis)

Place the recordings tree at the repository root as `tSCS_CHUV_data/`, laid out as described in
[data.md](data.md#directory-layout). It is `.gitignore`d, so it will not be committed.

Raw recordings are available from the authors on request — see
[data.md](data.md#availability).

## 3 · Run

```bash
.venv/bin/jupyter lab
```

Open any notebook and run it top to bottom. **Notebooks locate the repository root themselves** —
the first code cell walks up until it finds `src/` — so it does not matter which directory the
kernel starts in.

Run order, if starting from scratch:

1. `notebooks/motor_thresholds/pick_motor_thresholds.ipynb` — picks every recording's per-muscle
   motor thresholds and writes `results/<session>/mt_*.csv`. Everything else depends on these.
2. `notebooks/<session>/` — the per-session notebooks, which check the recordings and write
   `results/<session>/burstp2p_*.csv`.
3. `notebooks/across_participants/` — the comparisons. These read `results/` and need no raw data
   for their summary figures, but do need it for the EMG trace panels.

The threshold pickers need an interactive backend (`ipympl`, installed by
`requirements.txt`); they will not work in a plain static renderer.

## What runs without the raw recordings

| | without raw data |
|---|---|
| threshold tables, amplitude bar figures, group summaries | **yes** — they read `results/` |
| waterfalls, EMG trace panels, peak-detection grids, noise checks, latency examples | no — these draw the traces |
| re-picking a motor threshold | no |

So the headline numbers can be checked from this repository alone; inspecting the traces behind
them needs the recordings.

## What the thresholds control

A notebook's thresholds are read from `results/<session>/mt_*.csv` **on every run**. Re-picking
one and re-running from the thresholds section onward updates every figure that uses it — nothing
is cached. `warn_if_stale` warns if a pick changed after a figure was drawn.

---

## For contributors — the notebook output filter

**Notebook outputs are kept out of the repository**, so that diffs are readable and base64 image
data does not accumulate. This is done with a git clean filter, declared in `.gitattributes`:

```
*.ipynb filter=nbstrip
```

A filter named in `.gitattributes` must be **configured locally** — git will not run a filter a
repository merely asks for. Run this once per clone:

```bash
bash tools/setup_git_filters.sh
```

or equivalently:

```bash
git config filter.nbstrip.clean "python3 tools/strip_outputs.py"
git config filter.nbstrip.smudge cat
```

**Without it, committed notebooks will carry their outputs.** Your working copies keep their
figures either way — only the committed version is stripped.

To check a clone is configured:

```bash
git config --get filter.nbstrip.clean      # should print the strip command
```
