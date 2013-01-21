# GeoHex V3

GeoHex V3 implementation in Lua

## Quick Start

    local geohex = require 'geohex'
    geohex.encode(35.647401, 139.716911, 1)
    -- "132KpuG"

## Running tests

You need to install Telescope to run tests. Please see
http://norman.github.com/telescope/ for more details.

    $ tsc spec/*_spec.lua

## Licence

GeoHex is originally licenced by @sa2da under a Creative Commons BY-SA 2.1
License.

This code is covered by MIT License.
(The MIT License)

Copyright (c) 2013 Black Square Media Ltd

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
