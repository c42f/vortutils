Utilities for tracing vortex lines
==================================

This repo contains some utilities for finding vortices in a complex-valued
field sampled on a regular grid in 2D or 3D.  This is quite straightforward over
a 2D grid, but tracing vortex lines in 3D is a bit more involved.

This code was written at The University of Queensland during my PhD; my thesis
rests in peace here: http://arxiv.org/abs/1302.0470

The functions have resonably complete documentation comments, but here's an
overview of the more interesting functions to get you started:


3D functions
------------

* `vortex_lines_example.m` is an example script showing how to compute a 3D
  visualization of the vortex lines passing through a 3D complex field.  Running
  this and examining the code should give you an idea of where to start.

* `vortex_trace_all()` traces all vortex lines through a 3D vorticity field
  produced using `vortex_detct3d()`.


2D functions
------------

For a 2D grid, there are two functions of interest:

* `phase_winding2d()` takes a 2D grid containing complex phase and detects grid
  plaquetts where that phase "winds" around by 2 pi.

* `vortex_detect2d()` takes a 2D complex field, and interpolates more exact
  estimates of vortex position within the grid plaquetts.  Using this method as
  part of the 3D vortex tracing gives much better results.



License
-------

vortutils is licensed under the 2-clause BSD license: this basically means you
can do what you want with it, provided you keep the original attribution intact
(see LICENSE.txt for details)
