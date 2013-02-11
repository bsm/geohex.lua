local tonumber = tonumber
local tostring = tostring
local type     = type
local floor = math.floor
local ceil  = math.ceil
local log10 = math.log
local exp   = math.exp
local tan   = math.tan
local atan  = math.atan
local PI    = math.pi

-- Module definition
module(...)

-- Constants
local H_chars = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local H_base  = 20037508.34
local H_d2r   = PI / 180
local H_k     = tan(PI / 6)
local H_er    = 6371007.2
local H_index = {}
local H_units = {}
for i=1,#H_chars do H_index[H_chars[i]] = i-1 end

-- Local helper
-- @return [table] { northing = FLOAT, easting = FLOAT }
local point_to_ne = function(point)
  local northing = (H_k * point.x * point.unit.width + point.y * point.unit.height) / 2
  local easting  = (northing - point.y * point.unit.height) / H_k
  return { ["northing"] = northing, ["easting"] = easting }
end

-- @return [number] normalized longitude for a given `lon`
local normalize = function(lon)
  lon = tonumber(lon)
  if lon < -180 then
    return lon + 360
  elseif lon > 180 then
    return lon - 360
  end
  return lon
end

-- @return [string] decodes given `code` to a sequence of digits
local digitize = function(code)
  local n1, n2 = H_index[code:sub(1, 1)], H_index[code:sub(2, 2)]
  if not n1 or not n2 then
    return nil
  end

  local digits = tostring(n1* 30 + n2) .. code:sub(3)
  for _=#digits,#code do
    digits = "0" .. digits
  end

  return digits
end

-- @return [number] normalized easting for a given `lon`
local easting = function(lon)
  return normalize(lon) * H_base / 180
end

-- @return [number] normalized nothing for a given `lat`
local northing = function(lat)
  lat = tonumber(lat)
  return log10(tan((90 + lat) * H_d2r / 2)) / PI * H_base
end

-- Converts `lat`, `lon`, `level` inputs to Points
-- @return [table] point record containing { x = INT, y = INT, unit = TABLE }
function point(lat, lon, level)
  local u = unit(level)
  local e = easting(lon)
  local n = northing(lat)
  local x = (e + n / H_k) / u.width
  local y = (n - H_k * e) / u.height

  local x0, y0 = floor(x), floor(y)
  local xd, yd = x - x0, y - y0

  local xn, yn
  if yd > -xd + 1 and yd < 2 * xd and yd > 0.5 * xd then
    xn, yn = x0 + 1, y0 + 1
  elseif yd < -xd + 1 and yd > 2 * xd - 1 and yd < 0.5 * xd + 0.5 then
    xn, yn = x0, y0
  else
    xn, yn = floor(x + 0.499999), floor(y + 0.499999)
  end

  return { ["x"] = xn, ["y"] = yn, ["unit"] = u }
end


-- @return [table] parsed unif for given
function unit(level)
  level = tonumber(level) or 8

  if not H_units[level] then
    local size   = H_base / 3^(level+3)
    local scale  = size / H_er
    local width  = 6 * size
    local height = width * H_k
    H_units[level] = {
      ["level"] = level, ["size"] = size, ["width"] = width, ["height"] = height, ["scale"] = scale
    }
  end

  return H_units[level]
end

-- @return [table] point record containing { x = INT, y = INT, unit = TABLE }
function parse(code)
  if type(code) ~= "string" then return nil end

  local x, y   = 0, 0
  local len    = #code
  local digits = digitize(code)
  if not digits then return nil end

  local pos = 0
  for n10 in digits:gmatch("[^.]") do
    n10 = tonumber(n10)
    if not n10 then return nil end
    pow = 3^(len-pos)
    pos = pos + 1

    local n3 = ""
    while n10 > 0 do
      n3, n10 = (n10 % 3) .. n3, floor(n10 / 3)
    end
    n3 = tonumber(n3) or 0

    local xd = floor(n3 / 10)
    if xd == 0 then x = x - pow elseif xd == 2 then x = x + pow end

    local yd = floor(n3 % 10)
    if yd == 0 then y = y - pow elseif yd == 2 then y = y + pow end
  end

  return { ["x"] = x, ["y"] = y, ["unit"] = unit(len-2) }
end

-- @see `point/3` function for arguments
-- @return [string] encoded GeoHex string.
function encode(...)
  local point    = point(...)
  local ne       = point_to_ne(point)
  local code     = ""
  local mod_x, mod_y

  -- Meridian 180
  if H_base - ne.easting < point.unit.size then
    mod_x, mod_y = point.y, point.x
  else
    mod_x, mod_y = point.x, point.y
  end

  for i=point.unit.level+2, 0, -1 do
    local pow = 3^i
    local p2c = ceil(pow / 2)

    local c3_x
    if mod_x >= p2c then
      mod_x = mod_x - pow
      c3_x  = 2
    elseif mod_x <= -p2c then
      mod_x = mod_x + pow
      c3_x  = 0
    else
      c3_x  = 1
    end

    local c3_y
    if mod_y >= p2c then
      mod_y = mod_y - pow
      c3_y  = "2"
    elseif mod_y <= -p2c then
      mod_y = mod_y + pow
      c3_y  = 0
    else
      c3_y  = 1
    end

    code = code .. tonumber(c3_x .. c3_y, 3)
  end

  local num = tonumber(code:sub(1, 3))
  return H_chars[floor(num / 30) + 1] ..
         H_chars[floor(num % 30) + 1] ..
         code:sub(4)
end

-- @see `parse/1` function for arguments
-- @return [table] record containing { lat = FLOAT, lon = FLOAT, level = INT }
function decode(...)
  local point = parse(...)
  if not point then
    return nil
  end

  local ne = point_to_ne(point)
  local lat, lon

  -- Meridian 180
  if H_base - ne.easting < point.unit.size then
    lon = 180
  else
    lon = normalize(ne.easting / H_base * 180)
  end
  lat = 180 / PI * (2 * atan(exp(ne.northing / H_base * 180 * H_d2r)) - PI / 2)

  return { ["lat"] = lat, ["lon"] = lon, ["level"] = point.unit.level }
end

return M
