pcall(load(S4.arg))

-- period = 450 -- 428
-- gratingthickness = 160
-- dutycycle = 0.7
-- ridgewidth = period * dutycycle
-- gratingindex = 2.2
-- sio2index = 1.45 
-- loss_ITO = 0

-- nharm = 20
-- lambdain = 500 -- nm
-- lambdafin = 1000 -- nm
-- npoints = 900;
-- TEamp = 1
-- TMamp = 0

-- deltalambda = (lambdafin - lambdain) / npoints

local filedata = io.open("data.csv","w")
local fileeps = io.open("eps.csv", "w")

S = S4.NewSimulation()
S:SetLattice(period)
S:SetNumG(nharm)
S:UsePolarizationDecomposition()

S:AddMaterial("GratingMaterial", {eps_r, eps_i}) -- ITO
S:AddMaterial("GratingMaterial1", {gratingindex1^2,0})
S:AddMaterial("Air", {1,0})
S:AddMaterial("Glass", {glassindex^2,0})

S:AddLayer('AirAbove', 0, 'Air')
S:AddLayer('Grating', gratingthickness, 'Air') -- Air inbetween
S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {0,0}, 0, {ridgewidth*0.5,0}) -- ITO grating - layer, material in rectangle, centre, tilt-angle, half-widths
S:AddLayer('Grating1', ITO_under, 'GratingMaterial1') 
S:AddLayer('GlassSubstrate', 0, 'Glass')

-- S:AddLayer('GlassSubstrate', 0, 'Glass')
-- S:AddLayer('Grating', gratingthickness, 'Air')
-- S:SetLayerPatternRectangle('Grating', 'GratingMaterial', {0,0}, 0, {0.5*ridgewidth,0})
-- S:AddLayer('AirBelow', 0, 'Air') 

S:SetExcitationPlanewave({0,0},   -- incidence angles (spherical coords: phi [0,180], theta [0,360])
                        {TEamp,0},  -- TE-polarisation amplitude and phase (in degrees)
                        {TMamp,0})  -- TM-polarisation amplitude and phase
          

          -- COMPUTE AND SAVE TRANSMISSION / REFLECTION
          filedata:write("Lambda,Spectrum,Eyr,Eyi")
          reflection_max = 0
          for lambda = lambdain, lambdafin, deltalambda do
            freq = 1/lambda

            S:SetFrequency(freq)
        
            inc, back = S:GetPowerFlux('AirAbove', 20)
            forward, backward = S:GetPowerFlux('GlassSubstrate', 20)
            refl = - back/inc
            Exr, Eyr, Ezr, Exi, Eyi, Ezi = S:GetEField({0,0,z_field}) 
            
            -- print('lambda=', lambda, 'R=', refl)

            filedata:write("\n", lambda, ",", refl, ",", Eyr, ",", Eyi)
              
            if refl > reflection_max then 
              reflection_max = refl
              lambda_max = lambda
            end 
          
          end 

          for x = -period/2, period/2, 2 do
            -- print(x)
            eps_r, eps_i = S:GetEpsilon({x, 0, 75})
            fileeps:write(x..','..eps_r..'\n')
          end

          print('lambda_max=', lambda_max)


