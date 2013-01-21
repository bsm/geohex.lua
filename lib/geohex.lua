-- Module definition
local M = {}

-- Constants
local H = {
  key   = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"},
  base  = 20037508.34,
  d2r   = math.pi / 180,
  k     = math.tan(math.pi / 6),
  er    = 6371007.2,
  units = {}
}

-- @return [table] parsed unif for given
function M.unit(level)
  level = tonumber(level) or 8

  if not H.units[level] then
    local size   = H.base / 3^(level+3)
    local width  = 6 * size
    local height = width * H.k
    H.units[level] = {
      ["level"] = level, ["size"] = size, ["width"] = width, ["height"] = height
    }
  end

  return H.units[level]
end

function M.easting(lon)
  lon = tonumber(lon)
  if lon < -180 then
    lon = lon + 360
  elseif lon > 180 then
    lon = lon - 360
  end
  return lon * H.base / 180
end

function M.northing(lat)
  lat = tonumber(lat)
  return math.log(math.tan((90 + lat) * H.d2r / 2)) / math.pi * H.base
end

function M.point(lat, lon, level)
  local u = M.unit(level)
  local e = M.easting(lon)
  local n = M.northing(lat)
  local x = (e + n / H.k) / u.width
  local y = (n - H.k * e) / u.height

  local x0, y0 = math.floor(x), math.floor(y)
  local xd, yd = x - x0, y - y0

  local xn, yn
  if yd > -xd + 1 and yd < 2 * xd and yd > 0.5 * xd then
    xn, yn = x0 + 1, y0 + 1
  elseif yd < -xd + 1 and yd > 2 * xd - 1 and yd < 0.5 * xd + 0.5 then
    xn, yn = x0, y0
  else
    xn, yn = math.floor(x + 0.499999), math.floor(y + 0.499999)
  end

  return { ["x"] = xn, ["y"] = yn, ["unit"] = u }
end

function M.encode(...)
  local point    = M.point(...)
  local code     = ""
  local northing = (H.k * point.x * point.unit.width + point.y * point.unit.height) / 2.0
  local easting  = (northing - point.y * point.unit.height) / H.k
  local mod_x, mod_y

  -- Meridian 180
  if H.base - easting < point.unit.size then
    mod_x, mod_y = point.y, point.x
  else
    mod_x, mod_y = point.x, point.y
  end

  for i=point.unit.level+2, 0, -1 do
    local pow = 3^i
    local p2c = math.ceil(pow / 2)

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
  return H.key[math.floor(num / 30) + 1] ..
         H.key[math.floor(num % 30) + 1] ..
         code:sub(4)
end

return M
