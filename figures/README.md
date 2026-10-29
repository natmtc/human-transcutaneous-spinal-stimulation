# figures/

Where notebooks write figures when asked to, as `figures/<session>/` or
`figures/across_participants/`. The directories are created on demand.

**This folder is empty by design.** Saving is off by default — figures render inline in the
notebook, and the repository tracks code and derived data rather than rendered output. To save a
figure, pass `save="figures/<session>/<name>.png"` to a figure function, or set `DEP_SAVE = True`
in the notebooks that define it.

Figures are therefore regenerated rather than stored. See
[../docs/reproduce.md](../docs/reproduce.md) for what can be regenerated without the raw
recordings.
