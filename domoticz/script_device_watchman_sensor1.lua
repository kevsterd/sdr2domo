------------------------------------------------------------------------------
--
-- Copyright © 2015 David Woodhouse <dwmw2@infradead.org> and released under
-- the GNU General Public License, v2 or later.
--
--
-- Domoticz lua script to convert ultrasonic tank monitor readings into
-- percentage and volume virtual sensors for fuel tanks.
--
-- Takes input from distance sensor measuring the air above the fluid, and
-- converts to percentage and volume using the dimensions of the tank as
-- configured below.
--
-- Optionally, to prevent fluctuation as the fluid expands/contracts with
-- temperature, can convert the output values to report what the percentage
-- and volume *would* be at a fixed temperature.
--
------------------------------------------------------------------------------
--
-- Input sensors don't *have* to be virtual; mine are because they're filled in
-- by an external script running rtl_433 and receiving Watchman Sonic transmissions
--
-- Add tank temperature sensor:
-- 'http://localhost:8080/json.htm?type=createvirtualsensor&idx=1&sensortype=80'
-- Add depth sensor:
-- 'http://localhost:8080/json.htm?type=createvirtualsensor&idx=1&sensortype=13'
--
------------------------------------------------------------------------------
-- Output sensors are virtual, fed solely by this script
--
-- Add percentage sensor:
-- 'http://localhost:8080/json.htm?type=createvirtualsensor&idx=1&sensortype=2'
--
-- Add tank volume:
-- 'http://localhost:8080/json.htm?type=createvirtualsensor&idx=1&sensortype=113'
-- 'http://localhost:8080/json.htm?type=setused&idx=5&name=Oil&switchtype=2&used=true'
--
------------------------------------------------------------------------------
--
-- Update depth:
-- 'http://localhost:8080/json.htm?type=command&param=udevice&idx=3&nvalue=0&svalue=59'
--
------------------------------------------------------------------------------
 
 
-- Input devices: Temperature and air gap above fluid in tank
tank_temp_sensor = 'Input-Temp-OilTank'
depth_sensor = 'Input-Depth-OilTank'
 
-- Output devices: Percentage full, volume.
pct_sensor = 'Oil-Percentage'
pct_sensor_id = 260
volume_sensor = 'Oil-Litres'
volume_sensor_id = 259
 
-- To adjust for fluid expansion
-- Report volume/percentage as they would be at 10°C
canon_temp = -10
-- Kerosene
expansion_coeff = 1.00099
 
-- Tank dimensions  - think ours is around 2000 - 2250 litres, see http://www.regaltanks.co.uk/free-tools/tank-volume-calculator/horizontal-tank/
tank_height = 110
tank_area = 110 * 170

-- Now using cylinder calculation which is pi r squared
--tank_length = 170
--tank_radius = tank_height /2
--pi = math.pi
--tank_area = (pi * (tank_radius * tank_radius)) * tank_length 
 
-----------------------------------------------------------------------------------
commandArray = {}
 
if (devicechanged[depth_sensor] or devicechanged[tank_temp_sensor]) then
   -- Use otherdevices_svalues[] because devicechanged[foo_Utility] is not
   -- present when the value is zero
   depth = otherdevices_svalues[depth_sensor]
 
   -- Calculate percentage and volume
   pct = (tank_height - depth) / tank_height * 100
   volume = (tank_height - depth) * tank_area / 1000
 
   -- Adjust for fluid expansion
   tank_temp = otherdevices_svalues[tank_temp_sensor]
   if (tank_temp ~= nil) then
      temp_delta = tank_temp - canon_temp
      scale = math.pow(expansion_coeff, temp_delta)
      pct = pct * scale
      volume = volume * scale
	  -- KPI: Added rounding as decimals look better 
	  pct = math.floor(pct + 0.5)
	  volume = math.floor(volume + 0.5)
   end
 
   -- debug
   -- print(string.format("depth now %f; percentage %f %% volume %f l", depth, pct, volume))
 
   commandArray[1] = {['UpdateDevice'] = pct_sensor_id .. "|0|" .. pct}
   commandArray[2] = {['UpdateDevice'] = volume_sensor_id .. "|0|" .. volume}
end
 
return commandArray
