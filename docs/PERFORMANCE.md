# Performance
## plotting

* `line` is an extremely fast drawing option. use the primative `line` whenever markers do not vary in size or color
* `scatter` is slower, but allows for 1 color or size per marker

* plotting with `'.'` or `'o'` is faster than plotting with other markers
* to make axes active, set figure's `CurrentAxes` value to axes handle instead of calling axes

* limit `drawnow` calls, or at least use drawnow's options


## misc
* `memoize` can be used if function is time consuming, but same inputs always produce same outputs.
* `hgtransform` for rotating objects in 3d in an axes
* get and set graphics properties in separate loops.
