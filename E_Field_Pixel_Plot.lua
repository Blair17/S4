p = 500 -- nm
gratingthickness = 100 -- nm
dutycycle = 0.3
ridgewidth = dutycycle * p

gratingindex = 2
glassindex = 1.45 

nharm = 20
lambdain = 500 -- nm
lambdafin = 1000 -- nm
npoints = 900;

TEamp = 1
TMamp = 0

lambda = 575

nPeriodsPlot = 2

deltalambda = (lambdafin - lambdain) / npoints

local filelam = io.open("lam.csv","w")
local filespectrum = io.open("spectrum_E.csv","a")
local filephase = io.open("phase.csv","a")

local filex = io.open("parameter_x.csv", "w") 
local filez = io.open("parameter_z.csv", "w") 


printlam = 1

  for z = -200, 200, 1 do 
      S = S4.NewSimulation()
      S:SetLattice(p)
      S:SetNumG(nharm)
      S:UsePolarizationDecomposition()

      S:AddMaterial("GratingMaterial", {gratingindex^2,0}) -- ITO
      S:AddMaterial("Air", {1,0})
      S:AddMaterial("Glass", {glassindex^2,0})
      S:AddLayer('AirAbove', 0, 'Air') -- name, thickness, background material
      S:AddLayer('Grating', gratingthickness, 'Air') 
      S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {0,0}, 0, {ridgewidth*0.5,0})

      --[[
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {50,0}, 0, {p*0.03*0.5,0}) -- ITO grating - layer, material in rectangle, centre, tilt-angle, half-widths
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {100,0}, 0, {p*0.03*0.5,0})
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {150,0}, 0, {p*0.03*0.5,0})
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {200,0}, 0, {p*0.03*0.5,0})
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {250,0}, 0, {p*0.03*0.5,0})

        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {-50,0}, 0, {p*0.03*0.5,0}) 
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {-100,0}, 0, {p*0.03*0.5,0})
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {-150,0}, 0, {p*0.03*0.5,0})
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {-200,0}, 0, {p*0.03*0.5,0})
        S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {-250,0}, 0, {p*0.03*0.5,0})
       ]]
      --S:AddLayer('Grating1', gratingthickness, 'GratingMaterial')
         --S:AddLayer('GlassSubstrate', 0, 'Glass')

      S:AddLayer('AirBelow', 0, 'Air')
      S:SetExcitationPlanewave({0,0},      -- incidence angles (spherical coords: phi [0,180], theta [0,360])
                         {TEamp,0},  -- TE-polarisation amplitude and phase (in degrees)
                         {TMamp,0})  -- TM-polarisation amplitude and phase
    
     -- COMPUTE AND SAVE TRANSMISSION / REFLECTION
      for x = 1, 1000, 1 do
	      freq = 1/lambda

	      S:SetFrequency(freq)
	      inc, back = S:GetPowerFlux('AirAbove', 20)
	      forward, backward = S:GetPowerFlux('AirBelow', 20)
	      refl = - back/inc
         Exr, Eyr, Ezr, Exi, Eyi, Ezi = S:GetEField({x,0,z})
         Eyphi = math.atan(Eyi / Eyr)
           
         print('lambda=', lambda, 'R=', refl, 'Eyr=', Eyr, 'x=', x, 'z=', z) 

         if printlam == 1 then 
	         filelam:write("\n", lambda)
         end 

	      filespectrum:write(Eyr, ',') 
         filex:write("\n", x) 
      end

      printlam = 0
      -- Test code 

      filespectrum:write("\n") 
      filez:write("\n", z)
 end 