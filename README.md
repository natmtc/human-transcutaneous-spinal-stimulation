# Human transcutaneous spinal cord stimulation — EMG analysis

Analysis code and derived data for a study of **arm muscle EMG responses to transcutaneous
spinal cord stimulation (tSCS)** in healthy volunteers.

Four participants were stimulated over the cervical spine while EMG was recorded from up to
thirteen arm muscles. Two stimulation protocols were compared — **30 Hz monophasic bursts** and
**ARC-EX** (a 10 kHz carrier delivered at the same 30 Hz pulse rate) — under four manipulations:

| manipulation | what it tests |
|---|---|
| **lidocaine** applied to the skin under the electrode | how much of the response depends on cutaneous afferents |
| **tendon vibration** of a wrist flexor | whether the response is routed through muscle spindle (Ia) afferents |
| **stimulation polarity** — cathodic, anodic, biphasic | whether polarity changes threshold or response size |
| **pulse rate** — 1, 30, 50 Hz | how the response behaves as pulses arrive closer together |

**No participant data is distributed here** — neither the raw recordings nor the derived
per-participant measurements. Both are available from the authors on request, subject to the
consent and ethics terms of the study. See **[docs/data.md](docs/data.md)**.

---

## Start here

| if you want to… | read |
|---|---|
| understand the experiment | **[docs/methods.md](docs/methods.md)** |
| know why the numbers are computed the way they are | **[docs/analysis.md](docs/analysis.md)** |
| find or re-use the data | **[docs/data.md](docs/data.md)** |
| run the notebooks yourself | **[docs/reproduce.md](docs/reproduce.md)** |
| read or extend the code | **[docs/code.md](docs/code.md)** |
| know what may be re-used, and what is not licensed here | **[docs/licensing.md](docs/licensing.md)** |

The single most important thing to know before reading any figure is in
[docs/analysis.md](docs/analysis.md): **no millivolt or milliamp value is ever compared between
participants.** Every cross-participant statement in this repository is a ratio taken within one
participant, or a comparison of such ratios.

---

## Participants and sessions

Participants are pseudonymous (`P03`–`P06`); no identifying information is in this repository.

| participant | date | session | manipulation |
|---|---|---|---|
| **P03** | 2026-07-08 | `P03_2026-07-08` | baseline (screening; no analysis) |
| **P03** | 2026-07-15 | `P03_2026-07-15_tendon_vibration` | vibration on / off |
| **P04** | 2026-07-16 | `P04_2026-07-16_tendon_vibration` | vibration on / off |
| **P04** | 2026-07-17 | `P04_2026-07-17_lidocaine` | before / with lidocaine, electrodes 1 and 3 |
| **P04** | 2026-07-24 | `P04_2026-07-24` | baseline (screening; no analysis) |
| **P05** | 2026-07-24 | `P05_2026-07-24_polarity_lidocaine` | polarity × lidocaine |
| **P06** | 2026-09-28 | `P06_2026-09-28_polarity_lidocaine` | polarity × lidocaine × pulse rate |
| **P06** | 2026-09-29 | `P06_2026-09-29_tendon_vibration` | polarity × vibration |

Six of the eight sessions carry analysis; the two marked *screening* were setup sessions and have
no notebook or results.

---

## What each analysis asks

**Per session** — `notebooks/<session>/` holds one notebook per protocol (`single_pulse`, `burst`,
`arcex`). These check the recordings and produce that session's own figures.

**Across participants** — `notebooks/across_participants/` holds the comparisons:

| notebook | the question |
|---|---|
| `P03_P04_P05_P06_baseline_30Hz_vs_arcex` | how much more current does ARC-EX need, and do the two protocols recruit the arm the same way? |
| `P04_P05_P06_lidocaine_30Hz_vs_arcex` | what does blocking cutaneous afferents cost each protocol? |
| `P03_P04_P06_tendon_vibration` | does vibrating a tendon suppress the response in that muscle? |
| `P05_cathodic_vs_anodic`, `P06_cathodic_vs_anodic`, `P05_P06_cathodic_vs_anodic` | does polarity change threshold and response size? |
| `P06_lidocaine_polarity` | the cutaneous block, in all three polarities |
| `P06_tendon_vibration_polarity` | vibration, in both polarities |
| `P06_detailed_analysis` | one session on every muscle: response **amplitude** and **latency** |

**Motor thresholds** — `notebooks/motor_thresholds/pick_motor_thresholds.ipynb` picks every
recording's per-muscle motor threshold once, in one place. Every other notebook reads those
picks from disk and never re-derives them.

---

## Layout

```
src/functions/         all analysis code (see docs/code.md)
notebooks/             one folder per session, plus across_participants/ and motor_thresholds/
results/<session>/     derived data — NOT distributed; written here when you run the notebooks
figures/               where notebooks save figures when asked to; empty by default
docs/                  methods, analysis decisions, data, reproduction, code map
tools/                 the git filter that keeps notebook outputs out of the repository
```

**Neither the raw recordings nor the derived data are in this repository.** Both directories are
`.gitignore`d, so running the notebooks populates them locally without ever committing them.
See [docs/data.md](docs/data.md).

---

## Reproducing

```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/jupyter lab          # then run any notebook; they locate the repository root themselves
```

[docs/reproduce.md](docs/reproduce.md) covers what runs without the raw data, what needs it, and
the one-time git configuration for contributors.

---

## Citing

See [CITATION.cff](CITATION.cff).

## Licence

Code (`src/`, `notebooks/`, `tools/`) is **MIT** — see [LICENSE](LICENSE). The documentation in
`docs/` is **CC BY 4.0** — see [LICENSE-DATA](LICENSE-DATA). Participant data is covered by
neither licence and is not distributed here; details in [docs/licensing.md](docs/licensing.md).
