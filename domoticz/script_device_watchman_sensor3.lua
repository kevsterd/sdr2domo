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

 
 
-- Input devices: Temperature and air gap above fluid in tank
tank_temp_sensor = 'Input-Temp-PolytunnelWaterButt'
depth_sensor = 'Input-Depth-PolytunnelWaterButt'
 
-- Output devices: Percentage full, volume.
pct_sensor = 'WaterButt-Polytunnel-Percentage'
pct_sensor_id = 295
volume_sensor = 'WaterButt-Polytunnel-Litres'
volume_sensor_id = 296
 
-- To adjust for fluid expansion
--  See http://www.engineeringtoolbox.com/cubical-expansion-coefficients-d_1262.html
-- Report volume/percentage as they would be at 10°C
canon_temp = -10

--  Kerosene
--  expansion_coeff = 1.00099
-- Water
expansion_coeff = 1.000214
 
-- Tank dimensions
--  Water tank is measured as ~138 but watchman reports ~144 when empty, so set for that
tank_height = 144
-- Tank is made from two cylinders.   Calculated using man maths from http://www.onlineconversion.com/object_volume_cylinder_tank.htm
tank_area = 90 * 100
 
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