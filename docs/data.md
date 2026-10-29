# Data

## Availability

**No participant data is distributed in this repository.**

| | in this repository | |
|---|---|---|
| **Raw EMG recordings** | no | available on request |
| **Derived data** — picked motor thresholds, per-pulse amplitudes, latencies, signal-to-noise | no | available on request |
| **Session logs** (placement, timings, free-text notes) | no | held by the study team |

This repository contains **analysis code, notebooks and documentation only**. `tSCS_CHUV_data/`
and `results/` are both `.gitignore`d: running the notebooks populates them on your own machine
and they are never committed.

**Both the raw recordings and the derived data are available from the authors on request**,
subject to the consent and ethics terms of the study.
`TO CONFIRM — the contact point and any data-sharing agreement required.`

Raw recordings are withheld because they are the primary record of a human-subject study. The
derived measurements are withheld because, although they carry no identifiers, they are
per-participant data from a small cohort and their release is the study's decision to make, not a
side effect of publishing code. Session logs are withheld because they contain free-text clinical
notes.

Where participants are named in code or documentation they appear only as `P03`–`P06`. Session
dates are retained because the analysis depends on which recordings belong together.

The sections below document the **file formats**, so that data obtained from the authors can be
read and audited — not because the files are here.

---

## Derived data — `results/<session>/`

*Not distributed here; written by the notebooks when you run them. Format documented so the files
can be read and checked.*

One file per source recording, named `<prefix>_<source filename>.csv`. The source recording's
filename is preserved in every file and in a `source_file` column, so a derived row can always be
traced back.

### `mt_*.csv` — picked motor thresholds

The hand-picked motor threshold, one row per muscle. **This is the repository's one
irreproducible input** — a human judgement about which trace is the first real response. Its
history is in `git log -p results/`.

| column | |
|---|---|
| `source_file` | the recording this was picked in |
| `muscle`, `channel` | readable name, and the raw channel code |
| `mt_ma` | motor threshold in mA; **empty means not picked** (not "no threshold") |
| `electrode`, `mode` | montage and waveform, carried from the recording |

### `burstp2p_*.csv` — per-pulse response amplitude

One row per muscle × intensity × pulse. The main quantitative output.

| column | |
|---|---|
| `pulse`, `pulse_t_ms` | pulse number in the train, and its onset time |
| `win_start_ms`, `win_stop_ms` | the measurement window actually used |
| `p2p` | peak-to-peak in that window, **mV** |
| `p2p_norm_pct`, `norm_mode` | normalised value, and which normalisation produced it |
| `freq_hz`, `amp_ma` | pulse rate and stimulation intensity |
| `electrode`, `mode` | montage and waveform |

### `latency_*.csv` — single-pulse response latency

One row per muscle × intensity. `latency_ms` empty means no latency was picked at that intensity.

### `SNR_*.csv` — signal-to-noise

One row per muscle × intensity: `noise_rms`, `signal_rms`, `snr`, `snr_db`.

### Coverage

Picks exist where they were needed, not everywhere. Latency files exist for P04's two sessions
only; the other sessions have none, and the notebooks that want them say so rather than
substituting a value. Thresholds are picked per muscle **per recording**, so a muscle may be
picked in one block and not another — figures label that case explicitly.

---

## Raw recordings — format

Not in this repository either; this section documents the format so the derived files can be
audited against them.

One CSV per recording, named by protocol and timestamp:

```
Single_Pulse_autosave_<YYYYMMDD>_<HHMMSS>_<n>ms.csv
Paired_Pulse_autosave_…
Burst_autosave_…            30 Hz monophasic bursts
Modulated_autosave_…        ARC-EX (10 kHz carrier)
```

One row per **stimulation window** (one intensity of the recruitment sweep). Columns are located
**by name**, because the burst and modulated protocols insert extra parameter columns:

| column | |
|---|---|
| `window_id` | index of the stimulation window |
| `amplitude_ma` | stimulation intensity |
| `electrode` | montage number (1, 2, 3) |
| `pulse_width_us` | 500 for burst, 50 for ARC-EX |
| `mode` | waveform |
| `trigger_time_s` | wall-clock time of the trigger |
| `frequency_hz`, `burst_duration_ms` | burst and modulated files only |
| `time_ms` | the time base, as a literal list |
| *remaining columns* | one per recorded channel, each a literal list of samples; includes `Trigger A` |

Every column after `time_ms` is a signal channel, which is how the loader stays protocol-agnostic
— see [`src/functions/io.py`](../src/functions/io.py).

### Directory layout

Recordings sit under `tSCS_CHUV_data/<date folder>/<subject folder>/`. Place that tree at the
repository root and the notebooks find it.

### The recorder's folder names are not the session names

Three quirks, all reconciled in **one** place — `SESSIONS` in
[`src/functions/io.py`](../src/functions/io.py). Nothing downstream needs to know about them,
because results and figures are filed under the session name, not the folder name.

| folder | actually |
|---|---|
| `testSCS` | **P05.** The recorder was still set to a test profile that morning. |
| `28-08-2026` | the **28 September** session. The folder name is wrong; the files and the log both say `20260928`. |
| `29-09-2026` | also contains **a duplicate copy of all 32 recordings from 28-09**. Only files stamped `20260929` belong to this session. |

Because of the third quirk, **every notebook names its input files explicitly** rather than
globbing a directory. Each cross-participant notebook's config cell lists each recording with its
clock time and the session-log line it corresponds to.
