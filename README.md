# OpenLibm

[OpenLibm](http://www.openlibm.org) is an effort to have a high quality, portable, standalone
C mathematical library ([`libm`](http://en.wikipedia.org/wiki/libm)).
It can be used standalone in applications and programming language
implementations.

The project was born out of a need to have a good `libm` for the
[Julia programming langage](http://www.julialang.org) that worked
consistently across compilers and operating systems, and in 32-bit and
64-bit environments.

## OpenLibm for PureDarwin

This fork of OpenLibm is designed to be a drop-in replacement for `libsystem_m.dylib` for [PureDarwin](http://http://www.puredarwin.org/). The main difference between this version and the original is that the `fenv_t` structure and accompanying functions have been replaced with those from the most recent Apple Libm ([v2026](https://opensource.apple.com/source/Libm/Libm-2026/)). This allows binary compatibility with existing code.

For the original repo, see [here](https://github.com/JuliaLang/openlibm).

### TODO

* Replace the `#if 1`s with a proper `PUREDARWIN` macro
* Check ARM support works
