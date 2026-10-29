# Methods

What was done in the laboratory. For how the resulting traces are turned into numbers, see
[analysis.md](analysis.md).

> **Sections marked `TO CONFIRM` are not recoverable from the data files and must be filled in
> from the study protocol before this repository accompanies a publication.** They are listed
> here rather than guessed at.

---

## 1 · Participants

Four healthy volunteers, pseudonymised `P03`–`P06`, studied in eight sessions (six analysed).

`TO CONFIRM` — number screened and enrolled, age range, sex, handedness, inclusion and exclusion
criteria, ethics committee and approval number, consent procedure.

No identifying information, and no session log, is included in this repository. The per-session
log spreadsheets that record electrode placement, timings and free-text notes are held by the
study team and are not public.

---

## 2 · Stimulation

Transcutaneous spinal cord stimulation delivered over the cervical spine.

`TO CONFIRM` — stimulator make and model, cathode and anode size and material, anatomical
placement of each numbered electrode and of the return, skin preparation.

Electrodes are referred to throughout by the number used during recording — **1**, **2** and
**3**. Electrode **2** carries the baseline comparisons for every participant, so that montage is
common to them all. P04's lidocaine session used electrodes **1** and **3**.

### The two protocols

Both are recorded as a **recruitment sweep**: one stimulation window per intensity, stepping up a
ladder (typically 10, 15, 20 … mA; the ladder differs by session and is printed by each notebook).

| | file prefix | waveform | pulse width | pulse rate |
|---|---|---|---|---|
| **30 Hz burst** | `Burst_*` | monophasic | 500 µs | 30 Hz |
| **ARC-EX** | `Modulated_*` | 10 kHz carrier | 50 µs | 30 Hz |

A burst file delivers one **train** per stimulation window — 30 Hz × 1000 ms = **30 pulses**,
**33.4 ms apart**. One file is therefore one recruitment sweep, with one train at each intensity,
and *train* and *intensity* mean the same thing in the analysis.

**The two protocols differ in waveform, not in rate.** Both deliver pulses at the same 33.4 ms
interval. Comparing them is a comparison of 500 µs monophasic pulses against 50 µs pulses carried
on a 10 kHz oscillation — it is **not** a frequency comparison. This matters because the
post-activation depression seen along a train depends on the interval, which the two share.

Single-pulse (`Single_Pulse_*`) and paired-pulse (`Paired_Pulse_*`) files were also recorded and
are used for response latency.

### Polarity

Recorded as `positive` / `negative` in the session logs, where **`negative` = cathodic**. This
convention is stated in free-text notes in both P06 logs and was confirmed with the experimenters.
P06's sessions also include a **biphasic** condition.

---

## 3 · EMG recording

Surface EMG from up to thirteen arm muscles, bilaterally, plus a trigger channel.

`TO CONFIRM` — amplifier make and model, sampling rate, hardware filter settings, electrode type
and inter-electrode distance, skin preparation.

The sample interval in the recordings is **≈0.8 ms**, which sets the floor on any latency
difference that can be resolved.

Channels, as named in the recordings and relabelled for figures:

| channel | muscle | | channel | muscle |
|---|---|---|---|---|
| `L_DELmed` | Deltoid med. (L) | | `R_DELmed` | Deltoid med. (R) |
| `L_BB` | Biceps (L) | | `R_BB` | Biceps (R) |
| `L_TBlg` | Triceps long (L) | | `R_TBlg` | Triceps long (R) |
| | | | `R_TR` | Trapezius (R) |
| `L_The_ED_FD_FCR A` | Thenar (L) | | `R_The_ED_FD_FCR A` | Thenar (R) |
| `L_The_ED_FD_FCR B` | Ext. digitorum (L) | | `R_The_ED_FD_FCR B` | Ext. digitorum (R) |
| `L_The_ED_FD_FCR C` | Flex. digitorum (L) | | `R_The_ED_FD_FCR C` | Flex. digitorum (R) |
| `L_The_ED_FD_FCR D` | Flex. carpi rad. (L) | | `R_The_ED_FD_FCR D` | Flex. carpi rad. (R) |

The four distal muscles on each side come from one four-contact sensor strip, whose contacts are
`A`–`D` in that order. The mapping lives in [`src/functions/labels.py`](../src/functions/labels.py).

**A trigger channel (`Trigger A`) is recorded alongside the EMG** and marks every pulse. It is
what the analysis uses to find the pulses, rather than any assumption about timing; it was
verified to step at 0.0 ms with eleven pulses at 33.4 ms spacing and nothing before zero.

---

## 4 · The manipulations

Each manipulation is recorded as a **control block and a manipulated block** within one session,
with the setup, electrodes and montage unchanged between them. The control always comes first.

### Lidocaine

Topical lidocaine applied to the skin beneath the stimulating electrode, to block cutaneous
afferents while leaving deeper structures stimulated.

`TO CONFIRM` — preparation, concentration, amount, area covered, dwell time before the second
block, and whether sensory block was verified.

Blocks: `before` → `lidocaine`. For P04 this was done separately on electrodes 1 and 3; for P05
and P06 it was crossed with polarity.

### Tendon vibration

A mechanical vibrator strapped over a wrist flexor tendon, intended to drive muscle spindle (Ia)
afferents and, through post-activation depression at the Ia synapse, to suppress any part of the
response that is routed through them.

`TO CONFIRM` — vibrator make and model, vibration frequency and amplitude, exact tendon and
placement, strap tension.

Blocks: `VIB off` → `VIB ON`. **`VIB off` means the vibrator is strapped on and silent** — it
shares the setup, the electrodes and the elapsed time with `VIB ON` and differs only in whether
the motor runs. That is why it, and not a separate baseline recording, is the control.

For P06 (2026-09-29) the vibrator was on the **left flexor tendon**, confirmed with the
experimenter; the session log is unreliable on this point. See the open question in
[analysis.md](analysis.md#open-questions).

### Polarity

Cathodic, anodic and (P06 only) biphasic, otherwise identical. Crossed with lidocaine in P05 and
P06, and with vibration in P06.

### Pulse rate

P06's 2026-09-28 session includes a 1 / 30 / 50 Hz series. **This series is recorded but not yet
analysed** in this repository.

---

## 5 · Statistics

`TO CONFIRM` — the statistical plan as written for the manuscript.

What the code currently reports, and the reasoning behind each choice, is in
[analysis.md](analysis.md). In brief: descriptive statistics within participants, with
mean ± SD or ± SEM across muscles stated per figure, and a sign test where a direction is counted
across muscles. With four participants the repository deliberately reports effect direction and
size per participant rather than inferential tests across them, and says so wherever a count is
given.
