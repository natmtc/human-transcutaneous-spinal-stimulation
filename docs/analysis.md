# Analysis decisions

Every number in this repository rests on the choices below. They are **decisions, not defaults**:
each one could reasonably have been made differently, and each is stated in the notebook that
uses it as well as here.

---

## 1 · The measurement

For a train, the response to pulse *k* is whatever happens between the end of pulse *k*'s own
stimulus artifact and the arrival of pulse *k+1*:

```
window_k = [ pulse_k onset + RESP_START_MS ,  pulse_(k+1) onset − GUARD_MS ]
p2p_k    = max(EMG) − min(EMG)  inside window_k            (mV)
```

with `RESP_START_MS = 8.0` and `GUARD_MS = 1.0` throughout, and the **first 10 pulses** of each
train analysed.

**Why the window starts 8 ms after the pulse.** The stimulus artifact outlasts the trigger pulse,
by a different amount on every channel — about 2 ms on the deltoid but over 11 ms on the thenar in
some recordings. A window that opens too early measures artifact decay and calls it a response.
Each notebook's diagnostics cell prints the measured artifact width per channel and flags any
channel that 8 ms does not clear, so the choice is checked against the recording rather than
assumed. Where a channel needs more, `RESP_START_MS` accepts a per-channel override.

**Peak detection is anchored** (`anchor="mean"`, `anchor_win_ms=3.0`): each pulse's maximum and
minimum are taken relative to the train average rather than independently, so a single noisy
excursion cannot define the peak-to-peak on its own.

Pulse detection comes from the recorded **trigger channel**, not from assumed timing.

---

## 2 · The intensity every muscle is read at

**Every muscle is analysed at its own hand-picked motor threshold.** Not one milliamp for the
whole arm, and not a step above threshold — `MT_STEPS = 0` everywhere.

Thresholds are detected automatically and then **corrected by hand** in
`notebooks/motor_thresholds/pick_motor_thresholds.ipynb`, which shows every intensity of a
recording stacked for one muscle and asks which trace is the first real response. The picks are
written to `results/<session>/mt_*.csv` and **read from disk by every other notebook**, which
never re-derives them. Re-picking one threshold and re-running updates every figure that uses it.

### A manipulation is read at its control's threshold

`VIB ON` is read at the threshold picked in its own `VIB off` recording; `lidocaine` at the
threshold picked `before`.

**Why.** If each block were read at its own threshold, a change in the response and a change in
the current needed to evoke it would be indistinguishable — the manipulation could halve the
response and the analysis would simply walk up the ladder until it looked the same. Holding the
current fixed at the control's threshold makes the response size the only thing free to move.

### Protocols and polarities never share a threshold

30 Hz and ARC-EX sit far apart in current — ARC-EX needs roughly **2.8×** as much — so each
protocol, and each polarity, carries its own ladder and its own threshold. Nothing crosses
between them.

### When a ladder does not contain the threshold

The two blocks of a comparison sometimes swept different ladders. Rather than drop the muscle,
`match="common"` moves the reading to the lowest intensity **shared by both blocks and ≥ the
threshold**, and prints every move it makes. The alternative — silently dropping muscles — hides
how much data a comparison actually rests on.

---

## 3 · The noise floor, and what "no response" means

Noise is measured **in the same trace, from the same recording**: the peak-to-peak of the
pre-stimulus baseline between **−95 and −5 ms**, in windows the **same length** as the response
window, averaged. A response criterion then compares the two — e.g. *signal ≥ 2 × noise*.

### Three things this gets right, and one trap

**A rejected reading always says which case it is.** A bar left out of a figure is labelled
`under its noise`, `< 2x noise`, `no control`, `pulse voided` or `not measured` — never a blank,
and never "no response".

**"Under its noise" is not "no response."** It means this recording cannot separate a response
from its own baseline. Those are different claims, and only the first is supported.

**The trap: a tendon vibrator raises the noise floor in the muscle it sits on, by 2–8×.** The
vibrator is a motor strapped to the limb; it injects movement artifact straight into the nearest
electrode. Any signal-to-noise criterion applied to the vibrated muscle therefore rejects it for
the wrong reason — and the vibrated muscle is precisely the one the experiment is about. In at
least one session the vibrated muscle's *response* grew while its signal-to-noise ratio collapsed,
purely because the denominator had grown faster.

Consequently **the vibration notebooks turn the noise criterion off** and mark weak readings
instead, and each carries:

- a **noise table** giving each muscle's noise floor in every block, so the rise is visible; and
- a **by-eye check** (`fig_noise_check`) that draws the response window beside the pre-stimulus
  windows *on one scale*, so a flagged reading can be judged directly rather than on a ratio.

This is the one place where an automatic criterion was found to be actively misleading, and it is
why the repository prefers labelled exclusions over silent ones everywhere else.

---

## 4 · Normalisation — and the rule that governs every comparison

> **No millivolt or milliamp value is ever compared between participants.**

Different anatomy, electrode placement, skin impedance and EMG gain make raw values meaningless
across people. Every figure normalises *within* a participant first:

| quantity | normalised to |
|---|---|
| intensity | that muscle's own motor threshold (`× MT`) |
| amplitude | that muscle's own largest response in that recording (`%`), or its control block (`%`) |

What is then compared between people is a **ratio** or a **shape** — never a raw number.

### Within-train versus between-block normalisation

Two different normalisations appear, and they are not equally robust:

| | what it is | robust to a raised noise floor? |
|---|---|---|
| `dep2`, `dep_rest` | pulse 2, or the mean of pulses 2–10, as % of **pulse 1 of the same train** | **yes** — numerator and denominator share the trace |
| `pct`, `pct_all` | a block as % of **its control block** | **no** — the two blocks can have different noise floors |

Where the vibrator is running, the within-train measures carry the weight.

---

## 5 · Why the train itself is informative

At 30 Hz the pulses are **33.4 ms apart**, which is close to the interval of maximal
**post-activation depression** at the Ia synapse. A response routed through that synapse is
therefore expected to shrink from the first pulse to the second and stay low. A response driven
directly down motor axons has no such synapse to deplete and follows each pulse 1:1.

So the second pulse of a 30 Hz train is, in effect, an **accidental paired-pulse test** of how
much of the response is afferent-mediated — available in every burst recording, at no extra cost.
This is what the `dep2` and `dep_rest` columns measure, and why they are reported per muscle.

Note the direction of the inference carefully: depression along the train is *consistent with* an
afferent-mediated response; absence of depression argues against one. Neither is decisive on its
own, which is why the lidocaine and vibration manipulations exist.

---

## 6 · Latency

Measured in `P06_detailed_analysis.ipynb`, per pulse: the time at which the EMG first leaves a
baseline band of **mean ± k·SD** (`k_sd = 3.0`) of the pre-stimulus period and stays outside it
for at least `min_run = 2` consecutive samples, plus the time of the peak. Reported with the
spread across pulses (`jitter_ms`) and how many pulses yielded an onset at all.

That notebook shows **worked examples** (`fig_latency_example`): ten pulses with the baseline
band, the per-pulse onsets, the max and min actually used, and the mean onset and peak drawn on
top — so each reported number can be checked against the trace it came from.

**Two limits, stated because they bound the interpretation.** The sample interval is ≈0.8 ms, so
differences below about 2 ms are not resolvable. And with spinal stimulation a direct motor
response and a reflex response are separated by only ~1–2 ms, not the ~5 ms that would make
latency a clean discriminator between them. Latency here is reported as a measurement, not as
proof of pathway.

---

## 7 · Provenance

Notebook outputs are stripped before commit (see [reproduce.md](reproduce.md)), so the repository
records *code and derived data*, not rendered figures. The hand-picked thresholds in `results/`
are the one irreproducible input, and they are version-controlled: `git log -p results/` is the
complete history of every pick.

Each notebook also calls `warn_if_stale`, which compares the threshold file's timestamp against
the figures being drawn and warns if a pick has changed since.

---

## Open questions

Recorded here because they bear on how the results should be read.

**The left-arm channel labels are not fully resolved.** For P06's vibration session the
experimenter confirms the vibrator was on the **left flexor** tendon, but the noise floor rises
most in `Ext. digitorum (L)`. Either the session note is wrong, or the left sensor strip's `A`–`D`
contacts are mapped to the wrong muscles — which would mis-name every left distal muscle.
**Any left-arm, muscle-specific claim should be treated as provisional until this is settled**
against the placement photographs. Right-arm channels and all non-muscle-specific results are
unaffected.

**Vibration and train depression point different ways.** In the vibration sessions the vibrated
muscle's response is suppressed, which argues for an afferent contribution; but the second pulse
of the 30 Hz train shows little depression, which argues against a purely reflex response. The
most likely reconciliation is a mixed response — partly direct, partly afferent — but the test
that would settle it is the **1 / 30 / 50 Hz series** in P06's 2026-09-28 session, which is
recorded and not yet analysed.

**Supra-threshold recruitment cannot be compared.** The ladders stop at 1.0–1.2 × motor
threshold, and P04's ARC-EX sweep stops exactly *at* threshold. Nothing above threshold is
constrained by these recordings.
