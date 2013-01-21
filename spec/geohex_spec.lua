require 'spec.spec_helper'

context('geohex', function()

  local round = function(num)
    return math.floor(num * 1000 + 0.5) / 1000
  end
  local M = require 'geohex'

  test('northing', function()
    assert_equal(round(M.northing(51.2)), 6656747.948)
    assert_equal(round(M.northing("51.2")), 6656747.948)
    assert_equal(round(M.northing(38.89)), 4705927.242)
    assert_equal(round(M.northing(-2.7315738409448347)), -304192.664)
    assert_equal(round(M.northing(82.27244849463305)), 17189491.375)
  end)

  test('easting', function()
    assert_equal(round(M.easting(-0.1)), -11131.949)
    assert_equal(round(M.easting("-0.1")), -11131.949)
    assert_equal(round(M.easting(-77.04)), -8576053.57)
    assert_equal(round(M.easting(-182)), 19814869.358)
    assert_equal(round(M.easting(240)), -13358338.893)
    assert_equal(round(M.easting(178.9405262207031)), 19919568.258)
    assert_equal(round(M.easting(172.87607309570308)), 19244476.425)
  end)

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

  test('encode', function()
    for line in io.lines("spec/cases.csv") do
      local case = {}
      for t in string.gmatch(line, "[^,]+") do case[#case+1] = t end
      assert_equal(M.encode(case[1], case[2], case[3]), case[4])
    end
  end)

end)

