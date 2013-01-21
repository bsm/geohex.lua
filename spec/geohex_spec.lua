require 'spec.spec_helper'

context('geohex', function()

  local round = function(num, prec)
    if not prec then prec = 3 end
    return math.floor(num * 10^prec + 0.5) / 10^prec
  end
  local M = require 'geohex'

  test('unit', function()
    local u7 = M.unit(7)
    assert_type(u7, "table")
    assert_equal(round(u7.size), 339.337)
    assert_equal(round(u7.width), 2036.022)
    assert_equal(round(u7.height), 1175.498)

    local u5 = M.unit("5")
    assert_type(u5, "table")
    assert_equal(round(u5.size), 3054.033)
    assert_equal(round(u5.width), 18324.196)
    assert_equal(round(u5.height), 10579.48)
  end)

  test('point', function()
    local point = M.point(-2.7315738409448347, 178.9405262207031, 0)
    assert_equal(point.x, 4)
    assert_equal(point.y, -5)
    assert_equal(point.unit.level, 0)

    local point = M.point(82.27244849463305, 172.87607309570308, 0)
    assert_equal(point.x, 11)
    assert_equal(point.y, 2)
    assert_equal(point.unit.level, 0)
  end)

  test('parse', function()
    local point = M.parse("GI")
    assert_equal(point.x, -5)
    assert_equal(point.y, 4)
    assert_equal(point.unit.level, 0)

    local point = M.parse("CI")
    assert_equal(point.x, -5)
    assert_equal(point.y, -11)
    assert_equal(point.unit.level, 0)

    local point = M.parse("TK")
    assert_equal(point.x, 2)
    assert_equal(point.y, 11)
    assert_equal(point.unit.level, 0)

    local point = M.parse("PZ4253332")
    assert_equal(point.x, 6317)
    assert_equal(point.y, 2473)
    assert_equal(point.unit.level, 7)
  end)

  test('encode', function()
    for line in io.lines("spec/encode.csv") do
      local case = {}
      for t in string.gmatch(line, "[^,]+") do case[#case+1] = t end

      local encoded = M.encode(case[1], case[2], case[3])
      assert_equal(encoded, case[4])
    end
  end)

  test('decode', function()
    for line in io.lines("spec/decode.csv") do
      local case = {}
      for t in string.gmatch(line, "[^,]+") do case[#case+1] = t end

      local result = M.decode(case[1])
      result.lat = round(result.lat, 7)
      result.lon = round(result.lon, 7)
      assert_tables(result, { lat = round(case[2], 7), lon = round(case[3], 7), level = tonumber(case[4]) })
    end
  end)

end)

