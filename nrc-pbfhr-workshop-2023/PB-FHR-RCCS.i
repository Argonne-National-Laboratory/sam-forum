# This is the steady state input for updated PB-FHR primary loop model based on public information
# from Kairos Power's Hermes reactor and gFHR design. The thermal power is 320 MW and the mass flow
# rate in the loop is 1324.6 kg/s. The core part is modeled with 2D porous medium flow and the external
# flow circuit is modeled with 0D and 1D SAM components. The 2D region and 1D circuit are coupled with
# single-solve approach in SAM. The mesh file for the 2D core part is PB-FHR-2d_mesh_in.e.
# ==============================================
# NOTE: 2D & 1D models are oriented in X-Y space
# ==============================================
#
# Block and wall SS definitions for 2D part of model
#
#active_core_blocks = 'Diverging_Bed_rect Diverging_Bed_tri Cylindrical_Bed
#                 Bed_Bypass Converging_Bed_rect Converging_Bed_tri'
pebble_blocks = 'Inlet_Chute Diverging_Bed_rect Diverging_Bed_tri Cylindrical_Bed
                 Bed_Bypass Converging_Bed_rect Converging_Bed_tri Defueling_Chute'
porous_blocks = 'Inlet_Annulus Outlet_Annulus_bottom Outlet_Annulus_top' # Outlet_Plenum'
fluid_blocks = '${pebble_blocks} ${porous_blocks}'
solid_blocks = 'Reflector Core_Barrel Vessel_Wall Center_Reflector_bottom Center_Reflector_top'
#fluid_walls = 'centerline converging_bed_wall defueling_chute_wall  ir_left_wall
#                 outlet_annulus_wall'
all_blocks = '${fluid_blocks} ${solid_blocks}'

# - bed porosities:
bed_porosity = 0.388 # pebble bed: THTR value for eps_inf

#
# - geometry params for 2D model regions
#
ic_height = 1.4 # height of inlet chute (ic)
db_height = 0.5 # height of diverging bed (db)
bed_height = 3.1 # height of cylindrical bed
cb_height = 1.5 # height of converging bed (cb)
total_bed_height = '${fparse db_height + bed_height + cb_height}'
defuel_height = 2.0 # height of defueling chute
total_height = '${fparse ic_height + total_bed_height + defuel_height}'

bottom_2D = 0 # elevation at bottom of 2D mesh
top_2D = '${fparse bottom_2D + total_height}' # elevation at top of 2D mesh

bed_radius = 1.2 # cylindrical pebble bed radius
ir_width = 0.6
barrel_witdth = 0.02
dc_width = 0.05
dc_left_area = '${fparse 2*pi*(bed_radius+ir_width+barrel_witdth)}'
dc_right_area = '${fparse 2*pi*(bed_radius+ir_width+barrel_witdth+dc_width)}'
#
# - geometry params for 1D & 0D components
#
lp_height = 0.30 # height of lower plenum

op_height = 1.8 # height of outlet plenum
op_width = 0.6 # width of outlet plenum
op_radi = '${fparse bed_radius - op_width}' # outer edge aligns with pebble bed
op_area = '${fparse pi*(bed_radius^2 - op_radi^2)}'

dc_gap = 0.05 # values for downcomer
dc_radi = 1.82
dc_rado = '${fparse dc_radi + dc_gap}'
dc_area = '${fparse pi*(dc_rado^2 - dc_radi^2)}'

x_downcomer = '${fparse 0.5*(dc_radi + dc_rado)}'
x_riser = '${fparse x_downcomer + 2}'

cold_leg_length = '${fparse x_riser - x_downcomer}'

z_diode = '${fparse top_2D - op_height}' # elevation of fluidic diode (bottom of outlet plenum)
z_cold_leg = '${fparse top_2D + 0.4}'

x_hot_leg = '${fparse 0.5*(op_radi + bed_radius)}'
z_hot_leg = '${fparse top_2D + 2}'

IHX_length = 3.5
x_IHX = '${fparse x_riser + IHX_length}'
z_IHX = '${fparse bottom_2D + 2}'

D_CR = 0.052 # control rod channel diameter
CR_cntr = 0.079 # distance from edge of pebble bed to center of control rod
CR_num = 10 # number of control rods
CR_length = '${fparse top_2D - bottom_2D}'
x_CR = '${fparse bed_radius + CR_cntr}'

# - fluidic diode pipe geometry
D_6 = 0.14633 # ID of SC80-6in pipe
A_6 = '${fparse 3*pi*D_6^2/4}' # models three 6" pipes

# - pipe geometry params
D_24 = 0.54768 # ID of SC80-24in pipe
A_24 = '${fparse 2*pi*D_24^2/4}' # models two 24" pipes

#
# - Operating Conditions
#
power = 320E+06 # thermal power
p_tank = 1.0e+05 # gas space at top of vessel
T_in = 823.15 # cold leg temperature (also used for initialization)
T_hot = 923.15 # hot leg temperature

# primary system flow rate [kg/s]
cp_flibe = 2415.78 # SAM value (constant)
primary_flow = '${fparse power/cp_flibe/(T_hot - T_in)}'
rho_in = 2011.52 # SAM value @ 550 C

# IHX secondary side flow rate
# T2_in = 773.15    # secondary inlet temperature (K)
H_500 = 302360. # solar salt enthalpy at 500 C
H_600 = 456120. # solar salt enthalpy at 600 C
secondary_flow = '${fparse power/(H_600 - H_500)}'

rho_500 = 1772
v_secondary = '${fparse secondary_flow/rho_500/0.603437}'

[GlobalParams]
  # specify external 2D mesh to be used for single-solve coupling approach
  [ExternalMeshParams]
    external_mesh_file = 'PB-FHR-2d_mesh_in.e'
    coord_type = RZ
    rz_coord_axis = Y
    block = '${all_blocks}' # must be specified, otherwise RZ applied to 1D
  []

  # params used in both 2D and 1D model
  gravity = '0 -9.807 0' # SAM default is 9.8 for Z-direction
  eos = flibe
  u = vel_x
  v = vel_y
  pressure = p
  temperature = T

  # params used in 1D model only
  global_init_P = ${p_tank}
  global_init_V = 1.0E-06 # runs much better if started with a little velocity
  global_init_T = ${T_in}
  scaling_factor_var = '1 1e-2 1e-5'
[]

[Functions]
  [water-rho]
    type = PiecewiseLinear
    data_file = water_eos_P101325_1000.csv
    xy_in_file_only = false
    x_index_in_file = 0
    y_index_in_file = 1
    format = columns
  []
  [water-cp]
    type = PiecewiseLinear
    data_file = water_eos_P101325_1000.csv
    xy_in_file_only = false
    x_index_in_file = 0
    y_index_in_file = 2
    format = columns
  []
  [water-k]
    type = PiecewiseLinear
    data_file = water_eos_P101325_1000.csv
    xy_in_file_only = false
    x_index_in_file = 0
    y_index_in_file = 3
    format = columns
  []
  [water-mu]
    type = PiecewiseLinear
    data_file = water_eos_P101325_1000.csv
    xy_in_file_only = false
    x_index_in_file = 0
    y_index_in_file = 4
    format = columns
  []
[]

[EOS]
  [flibe]
    type = SaltEquationOfState
    salt_type = Flibe
  []
  [eos2] # Solar salt
    type = TabulatedEquationOfState
    temperature = '573.15	583.15	593.15	603.15	613.15	623.15	633.15	643.15	653.15	663.15	673.15	683.15	693.15	703.15	713.15	723.15	733.15	743.15	753.15	763.15	773.15	783.15	793.15	803.15	813.15	823.15	833.15	843.15	853.15	863.15	873.15'
    rho = '1899.2	1892.84	1886.48	1880.12	1873.76	1867.4	1861.04	1854.68	1848.32	1841.96	1835.6	1829.24	1822.88	1816.52	1810.16	1803.8	1797.44	1791.08	1784.72	1778.36	1772	1765.64	1759.28	1752.92	1746.56	1740.2	1733.84	1727.48	1721.12	1714.76	1708.4'
    cp = '1494.6	1496.32	1498.04	1499.76	1501.48	1503.2	1504.92	1506.64	1508.36	1510.08	1511.8	1513.52	1515.24	1516.96	1518.68	1520.4	1522.12	1523.84	1525.56	1527.28	1529	1530.72	1532.44	1534.16	1535.88	1537.6	1539.32	1541.04	1542.76	1544.48	1546.2'
    k = '0.386	0.3841	0.3822	0.3803	0.3784	0.3765	0.3746	0.3727	0.3708	0.3689	0.367	0.3651	0.3632	0.3613	0.3594	0.3575	0.3556	0.3537	0.3518	0.3499	0.348	0.3461	0.3442	0.3423	0.3404	0.3385	0.3366	0.3347	0.3328	0.3309	0.329'
    mu = '0.0032632	0.003043217	0.002841437	0.002656976	0.00248895	0.002336475	0.002198666	0.002074638	0.001963507	0.001864389	0.0017764	0.001698655	0.001630269	0.001570358	0.001518038	0.001472425	0.001432634	0.00139778	0.001366979	0.001339347	0.001314	0.001290053	0.001266621	0.00124282	0.001217766	0.001190575	0.001160362	0.001126242	0.001087331	0.001042745	0.0009916'
  []
  [air]
    type = AirEquationOfState
  []
  [water]
    type = PTFunctionsEOS
    rho = water-rho
    k = water-k
    cp = water-cp
    mu = water-mu
    T_min = 273.15
    T_max = 373.15
  []
[]

[MaterialProperties]
  [ss-mat]
    type = HeatConductionMaterialProps
    k = 40
    Cp = 1.0 #583.333
    rho = 6e3
  []
  [graphite]
    type = HeatConductionMaterialProps
    k = 30 # typical value for irradiated graphite
    rho = 1673
    Cp = 1.0 #700
  []
[]

[ComponentInputParameters]
  [SC80-24in]
    type = PBPipeParameters
    A = ${A_24} # models 2 pipes
    Dh = ${D_24}
    material_wall = ss-mat
    wall_thickness = 0.03096
    n_wall_elems = 3
    radius_i = '${fparse 0.5*D_24}'
    roughness = 0.000015

  []
[]

# ==========================================================
# - Components for coupling 1D to 2D flow model
# ==========================================================
[Components]
  [inlet_plenum]
    type = CoupledVolumeBranch
    center = '${fparse 0.5*dc_rado} ${fparse -0.5*lp_height} 0'
    Area = '${fparse pi*dc_rado^2}'
    volume = '${fparse pi*dc_rado^2*lp_height}'
    # coupling to 1D components
    inputs = 'downcomer_pipe(out)'
    outputs = 'control_rod(in)'
    K = '0.79 3.0'
    # coupling to 2D inlet_chute and inlet_annulus boundary
    boundary = 'inlet_chute inlet_annulus'
    height = ${lp_height} # display purposes
    width = ${dc_rado} # display purposes
    rotation = 0
    orientation = '0 1 0'
    boundary_out_norm = '0 -1 0'
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [outlet_plenum]
    type = CoupledVolumeBranch
    center = '${fparse 0.5*(op_radi + bed_radius)} ${fparse 0.5*(z_diode + top_2D)} 0'
    Area = ${op_area}
    volume = '${fparse op_area*op_height}'
    # coupling to 1D components
    inputs = 'control_rod(out)'
    outputs = 'extraction_pipe(in) diode_pipe1(in) uh_pipe(in)'
    K = '1.0 1.0 0.5 0'
    # coupling to 2D
    boundary = 'outlet_annulus defueling_chute'
    height = ${op_height} # display purposes
    width = '${fparse bed_radius - op_radi}' # display purposes
    rotation = 0
    orientation = '0 1 0'
    boundary_out_norm = '0 1 0'
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [dc_left]
    type = ConvectiveHeatTransfer
    Tsolid = 'Ts' # solid temperature varaible name
    solid_boundary = 'dc_left_wall' # solid boundary name
    fluid_components = 'downcomer_pipe' # 1D fluid component name
    HT_surface_area_density = '${fparse dc_left_area/dc_area}' # heat transfer surface area density
    solid_axis = 'y' # solid side direction axis in displaced (physical) mesh
    fluid_axis = 'y' # fluid side direction axis in displaced (physical) mesh
  []

  [dc_right]
    type = ConvectiveHeatTransfer
    Tsolid = 'Ts' # solid temperature varaible name
    solid_boundary = 'dc_right_wall' # solid boundary name
    fluid_components = 'downcomer_pipe' # 1D fluid component name
    HT_surface_area_density = '${fparse dc_right_area/dc_area}' # heat transfer surface area density
    solid_axis = 'y' # solid side direction axis in displaced (physical) mesh
    fluid_axis = 'y' # fluid side direction axis in displaced (physical) mesh
  []
  [dc_top_left]
    type = ConvectiveHeatTransfer
    Tsolid = 'Ts' # solid temperature varaible name
    solid_boundary = 'dc_top_left_wall' # solid boundary name
    fluid_components = 'downcomer_top1' # 1D fluid component name
    HT_surface_area_density = '${fparse dc_left_area/dc_area}' # heat transfer surface area density
    solid_axis = 'y' # solid side direction axis in displaced (physical) mesh
    fluid_axis = 'y' # fluid side direction axis in displaced (physical) mesh
  []

  [dc_top_right]
    type = ConvectiveHeatTransfer
    Tsolid = 'Ts' # solid temperature varaible name
    solid_boundary = 'dc_top_right_wall' # solid boundary name
    fluid_components = 'downcomer_top1' # 1D fluid component name
    HT_surface_area_density = '${fparse dc_right_area/dc_area}' # heat transfer surface area density
    solid_axis = 'y' # solid side direction axis in displaced (physical) mesh
    fluid_axis = 'y' # fluid side direction axis in displaced (physical) mesh
  []

  # ==========================================================
  # - Specifications for 1D part of model using SAM components
  #     NOTE: 1D components are oriented in X-Y space
  # ==========================================================
  #
  # - Outlet plenum to IHX
  #
  [extraction_pipe] # hot salt extraction pipe @ top of outlet plenum
    type = PBPipe
    input_parameters = SC80-24in # models 2 pipes
    position = '${x_hot_leg} ${top_2D} 0'
    orientation = '0 1 0'
    length = '${fparse z_hot_leg - top_2D}'
    n_elems = 3
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [pump] # primary loop pump
    type = PBPump
    inputs = 'extraction_pipe(out)'
    outputs = 'hot_leg(in)'
    K = '0 0'
    K_reverse = '1000 1000' # need a basis for these
    Area = ${A_24}
    Head = 1.44E+05
    Desired_mass_flow_rate = ${primary_flow}
    Response_interval = 1
  []

  [hot_leg] # horizontal part of hot leg from pump to down_pipe
    type = PBPipe
    input_parameters = SC80-24in # models 2 pipes
    position = '${x_hot_leg} ${z_hot_leg} 0'
    orientation = '1 0 0'
    length = '${fparse x_IHX - x_hot_leg}'
    n_elems = 10
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [hot_leg_jun] # joins hot leg & down pipe
    type = PBSingleJunction
    inputs = 'hot_leg(out)'
    outputs = 'down_pipe(in)'
  []

  [down_pipe] # downflow part of hot leg to IHX
    type = PBPipe
    input_parameters = SC80-24in # models 2 pipes
    position = '${x_IHX} ${z_hot_leg} 0'
    orientation = '0 -1 0'
    length = '${fparse z_hot_leg - z_IHX}'
    n_elems = 10
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  #
  # - IHX primary & secondary
  #
  [IHX_inlet]
    type = PBVolumeBranch # necessary due to small offset in IHX mesh
    center = '${x_IHX} ${z_IHX} 0'
    Area = 0.36571
    volume = 0.001
    inputs = 'down_pipe(out)'
    outputs = 'IHX(primary_in)'
    K = '0 0.5' # 90-degree turn & expansion needed
    height = ${D_24} # display purposes
    width = 0.1 # display purposes
    rotation = 0
    orientation = '0 1 0'
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [IHX]
    type = PBHeatExchanger
    HX_type = Countercurrent
    eos_secondary = eos2
    position = '${x_IHX} ${z_IHX} 0'
    orientation = '-1 0 0'
    A = 0.36571
    Dh = 0.0108906
    PoD = 1.17
    HTC_geometry_type = Bundle
    length = ${IHX_length}
    n_elems = 10
    HT_surface_area_density = 734.582
    A_secondary = 0.603437
    Dh_secondary = 0.0196
    length_secondary = ${IHX_length}
    HT_surface_area_density_secondary = 408.166
    hs_type = cylinder
    radius_i = 0.0098
    wall_thickness = 0.000889
    n_wall_elems = 3
    material_wall = ss-mat
    initial_T = ${T_in}
    initial_V = 1e-6
    Twall_init = ${T_in}
    initial_T_secondary = ${T_in}
    initial_P_secondary = 1e+05
    initial_V_secondary = '${fparse -v_secondary}'
    SC_HTC = 2.5 # approximation for twisted tube effect
    SC_HTC_secondary = 2.5
    disp_mode = -1
  []

  [IHX_outlet]
    type = PBVolumeBranch # necessary due to small offset in IHX mesh
    center = '${x_riser} ${z_IHX} 0'
    Area = 0.36571
    volume = 0.001
    inputs = 'IHX(primary_out)'
    outputs = 'riser(in)'
    K = '0 0.5' # contraction & 90-degree turn needed
    height = ${D_24} # display purposes
    width = 0.1 # display purposes
    rotation = 0
    orientation = '0 1 0'
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [IHX2-in]
    type = PBTDJ
    v_bc = '${fparse -v_secondary}'
    T_bc = 773.15 #823.15
    # T_fn  = T2_fn
    eos = eos2
    input = 'IHX(secondary_in)'
  []

  [IHX2-out]
    type = PBTDV
    eos = eos2
    p_bc = 1e+05
    T_bc = 873.15
    input = 'IHX(secondary_out)'
  []

  #
  # - Piping from IHX to downcomer injection plenum
  #
  [cold_leg_chain]
    type = PipeChain
    component_names = 'riser cold_leg downcomer_top2'
  []

  [riser]
    type = PBPipe
    input_parameters = SC80-24in
    position = '${x_riser} ${z_IHX} 0'
    orientation = '0 1 0'
    length = '${fparse z_cold_leg - z_IHX}'
    n_elems = 10
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [cold_leg]
    type = PBPipe
    input_parameters = SC80-24in # models 2 pipes
    position = '${x_riser} ${z_cold_leg} 0'
    orientation = '-1 0 0'
    length = ${cold_leg_length}
    n_elems = 3
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  #
  # - downcomer & fluidic diode pipe
  #
  [downcomer_top1] # from cold leg to junction with fluidic diode pipe(2)
    type = PBOneDFluidComponent
    position = '${x_downcomer} ${top_2D} 0'
    orientation = '0 -1 0'
    A = ${dc_area}
    Dh = '${fparse 2*dc_gap}'
    length = '${fparse top_2D - z_diode}'
    n_elems = 3
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [downcomer_top2] # from cold leg to junction with fluidic diode pipe(2)
    type = PBOneDFluidComponent
    position = '${x_downcomer} ${z_cold_leg} 0'
    orientation = '0 -1 0'
    A = ${dc_area}
    Dh = '${fparse 2*dc_gap}'
    length = '${fparse z_cold_leg - top_2D}'
    n_elems = 3
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [downcomer_top_jun]
    type = PBSingleJunction
    inputs = 'downcomer_top2(out)'
    outputs = 'downcomer_top1(in)'
  []

  [diode_pipe1] # from outlet plenum to fluidic diode
    type = PBOneDFluidComponent
    position = '${bed_radius} ${z_diode} 0'
    orientation = '1 0 0'
    A = ${A_6}
    Dh = ${D_6}
    length = '${fparse 0.5*(x_downcomer - bed_radius)}'
    n_elems = 3
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [diode] # CheckValve
    type = CheckValve
    inputs = 'diode_pipe1(out)'
    outputs = 'diode_pipe2(in)'
    initial_V = 0
    closing_option = D
    open_area = ${A_6}
    opening_pressure = 0 # small value to open valve
  []

  [diode_pipe2] # from fluidic diode to downcomer branch
    type = PBOneDFluidComponent
    position = '${fparse 0.5*(x_downcomer + bed_radius)} ${z_diode} 0'
    orientation = '1 0 0'
    A = ${A_6}
    Dh = ${D_6}
    length = '${fparse 0.5*(x_downcomer - bed_radius)}'
    n_elems = 3
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [downcomer_branch] # connects downcomer & fluidic diode pipe
    type = PBBranch
    inputs = 'downcomer_top1(out) diode_pipe2(out)'
    outputs = 'downcomer_pipe(in)'
    K = '0 0 0'
    Area = ${dc_area}
  []

  [downcomer_pipe] # from junction with fluidic diode to inlet plenum
    type = PBOneDFluidComponent
    position = '${x_downcomer} ${z_diode} 0'
    orientation = '0 -1 0'
    A = ${dc_area}
    Dh = '${fparse 2*dc_gap}'
    length = ${z_diode}
    n_elems = 22
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [control_rod] # control rod bypass channel
    type = PBOneDFluidComponent
    position = '${x_CR} ${bottom_2D} 0'
    orientation = '0 1 0'
    A = '${fparse CR_num*pi*D_CR^2/4}'
    Dh = ${D_CR}
    length = ${CR_length}
    n_elems = 28
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [uh_pipe] # connecting outlet plenum with upper head
    type = PBOneDFluidComponent
    position = '${fparse 0.5*(x_hot_leg + bed_radius)} ${top_2D} 0'
    orientation = '0 1 0'
    A = ${op_area}
    Dh = '${fparse 2*op_width}'
    length = 0.2
    n_elems = 2
    initial_V = 1.0E-06
    initial_T = ${T_in}
    initial_P = ${p_tank}
  []

  [upper_head] # to provide cover gas pressure BC
    type = PBTDV
    input = 'uh_pipe(out)'
    p_bc = ${p_tank}
    T_bc = ${T_hot}
  []
  # ==========================================================
  # - Components for RCCS
  # ==========================================================

  [RCCS]
    type = PBCoupledHeatStructure
    HS_BC_type = 'Adiabatic Coupled'
    position = '4.45 0 0' # The x-position will be offset by radius_i
    orientation = '0 1 0'
    length = 8.5
    elem_number_axial = 46
    material_hs = 'ss-mat'
    width_of_hs = '0.01'
    elem_number_radial = '5'
    radius_i = 2.24
    hs_type = cylinder
    Ts_init = 335
    name_comp_right = 'riser-HT'
    HT_surface_area_density_right = 19.7802
  []
  [RCCS-HX-feed]
    type = PBOneDFluidComponent
    eos = water
    position = '2.25 43.1 0'
    orientation = '1 0 0'
    length = 2.0
    n_elems = 4
    initial_V = 0.2
    initial_T = 325.5
    initial_P = 70900
    Dh = 0.434974
    A = 0.5943968
  []
  [riser-rccs] # 4 18in schedule 40 pipes
    type = PBOneDFluidComponent
    eos = water
    position = '2.25 8.5 0'
    orientation = '0 1 0'
    length = 34.6
    n_elems = 20
    initial_V = 0.2
    initial_T = 325.5
    initial_P = 240000
    Dh = 0.434974
    A = 0.5943968
  []
  [riser-HT]
    type = PBOneDFluidComponent
    position = '2.25 0 0'
    orientation = '0 1 0'
    length = 8.5
    Dh = 0.05
    A = 0.7147
    eos = water
    n_elems = 46
    initial_V = 0.17
    initial_T = 325.5
    initial_P = 447000
    fluid_conduction = true
  []

  [riser-chain]
    type = PipeChain
    eos = water
    component_names = 'riser-HT riser-rccs RCCS-HX-feed'
  []
  [HX-J]
    type = PBSingleJunction
    outputs = 'RCCS-HX(secondary_in)'
    inputs = 'RCCS-HX-feed(out)'
    eos = water
    initial_V = 0.2
    initial_T = 325.5
    initial_P = 709000
  []
  [RCCS-HX]
    type = PBHeatExchanger
    position = '4.25 40.1 0'
    orientation = '0 1 0'
    A_secondary = 4.926189843
    A = 59.07381016
    Dh_secondary = 0.0125222
    Dh = 0.106511061
    eos_secondary = water
    eos = air
    HT_surface_area_density_secondary = 319.4326875
    HT_surface_area_density = 36.47139462
    wall_thickness = 0.0023114
    material_wall = ss-mat
    n_elems = 30
    n_wall_elems = 5
    length = 3
    initial_V = 2.4
    initial_T = 307
    initial_P = 101400
    initial_V_secondary = -0.024
    initial_T_secondary = 324
    initial_P_secondary = 85500
    Twall_init = 323
    hs_type = cylinder
    radius_i = 0.0062611
  []
  [chimney]
    type = PBOneDFluidComponent
    A = 64
    Dh = 4
    eos = air
    position = '4.25 43.1 0'
    orientation = '0 1 0'
    initial_T = 310.5
    initial_V = 2.25
    initial_P = 101400
    length = 7
    n_elems = 12
    #initial_T = 303.15
  []
  [chimney-J]
    type = PBSingleJunction
    inputs = 'RCCS-HX(primary_out)'
    outputs = 'chimney(in)'
    eos = air
    initial_V = 2.4
    initial_T = 310.5
    initial_P = 101400
  []
  [air-in]
    type = PBTDV
    eos = air
    p_bc = 101439.22
    T_bc = 303.15
    input = 'RCCS-HX(primary_in)'
  []
  [air-out]
    type = PBTDV
    eos = air
    p_bc = 101325
    T_bc = 303.15
    input = 'chimney(out)'
  []

  [Tank-branch]
    type = PBBranch
    inputs = 'RCCS-HX(secondary_out)'
    outputs = 'to-tank(in) RCCS-down(in)'
    K = '0.0 0.0 0.0'
    Area = 0.7147
    eos = water
    initial_V = 0.17
    initial_T = 323
    initial_P = 99985
  []
  [to-tank]
    type = PBOneDFluidComponent
    Dh = 0.05
    A = 0.7147
    eos = water
    position = '4.25 40.1 0'
    orientation = '1 0 0 '
    length = 1
    n_elems = 2
    initial_V = 0.000020
    initial_T = 318
    initial_P = 1e5
  []
  [RCCS-tank]
    type = PBTDV
    eos = water
    T_bc = 320
    input = 'to-tank(out)'
  []
  [RCCS-down]
    type = PBOneDFluidComponent
    eos = water
    position = '4.25 40.1 0'
    orientation = '0 -1 0'
    length = 40.1
    n_elems = 20
    initial_V = 0.17
    initial_T = 323
    initial_P = 294000
    Dh = 0.05
    A = 0.7147
  []
  [RCCS-inlet]
    type = PBVolumeBranch
    volume = 1.0
    Area = 1.0
    eos = water
    inputs = 'RCCS-down(out)'
    outputs = 'riser-HT(in)'
    K = '0.0 0.0'
    position = '0 0 0 '
    orientation = '0 1 0'
    width = 2.0
    center = '3.25 -0.25 0'
    initial_V = 0.1
    initial_T = 323
    initial_P = 491000
  []
[]

[Constraints]
  [RHT]
    type = NearestNodeRadHeatTransferConstraint
    epsilon_primary = 0.8
    epsilon_secondary = 0.8
    area_ratio = 1.0
    radius_p = 1.91
    radius_s = 2.24
    use_displaced_mesh = false #true
    primary = 'vessel_wall'
    secondary = 'RCCS:inner_wall'
    variable = Ts
    v_primary = Ts
    v_secondary = T_solid
  []
[]

# ========================================================
# Specifications for 2D part of model
# ========================================================

# WARNING: varaible names for 2D model need to be different from 1D variable names
#   The 1D variable names are : 'pressure', 'velocity', 'temperature', 'T_solid', and 'rho'
#   Here the 3D variable names are: 'p', 'vel_x', 'vel_y', 'vel_z', 'T' (fluid temperature),
#     'Ts' (solid temperature), and 'density'

[MDFlow]
  gravity = '0 -9.807 0'

  # there is no (pure) flow_blocks
  solid_blocks = 'Reflector Core_Barrel Vessel_Wall Center_Reflector_bottom Center_Reflector_top'
  solid_names = '  graphite ss-mat ss-mat graphite graphite'
  pebble_bed_blocks = 'Inlet_Chute Diverging_Bed_rect Diverging_Bed_tri Cylindrical_Bed
                       Bed_Bypass Converging_Bed_rect Converging_Bed_tri Defueling_Chute
                       Inlet_Annulus Outlet_Annulus_bottom Outlet_Annulus_top'
  pebble_bed_solid_names = 'graphite graphite graphite graphite graphite graphite graphite graphite graphite graphite graphite'
  # porous_blocks = 'Inlet_Annulus Outlet_Annulus_bottom Outlet_Annulus_top'
  # porous_solid_names = "graphite graphite graphite"

  # scaling factors: p u    v    T    Ts
  scaling_factors = '1 1e-1 1e-1  1e-3 1e-3'
  conservative_form = false
  p_int_by_parts = true

  # initial conditions
  initial_p = 1.0e+05
  initial_u = 1.0E-08
  initial_v = 1.0E-06
  initial_T = ${T_in}
  initial_Ts = ${T_in}

  eos = flibe

  show_elemental_var = true
  # mixing_length = 0.1
[]

[PebbleBedClosures]
  [active_core]
    type = PebbleBedClosures
    block = 'Inlet_Chute Diverging_Bed_rect Diverging_Bed_tri Cylindrical_Bed
             Bed_Bypass Converging_Bed_rect Converging_Bed_tri Defueling_Chute'
    porosity_fn = 0.388
    d_pebble = 0.04
    d_bed = 1.2 # check
    friction_model = KTA
    HTC_model = Wakao
    Wall_HTC_model = Achenbach
    k_effective_model = ZBS
    eos = flibe
    solid = graphite
    mixing_length = 0.1
  []
  [porous_region]
    type = PebbleBedClosures
    block = 'Inlet_Annulus Outlet_Annulus_bottom Outlet_Annulus_top'
    porosity_fn = 0.388
    d_pebble = 0.04
    d_bed = 1.2 # check
    friction_model = KTA
    HTC_model = Wakao
    k_eff = 18.36
    eos = flibe
    solid = graphite
    mixing_length = 0.1
  []
[]

[AuxVariables]
  [rho_aux]
    block = ${fluid_blocks}
    initial_condition = ${rho_in}
  []
  [porosity]
    block = ${fluid_blocks}
    initial_condition = ${bed_porosity}
  []
  [power_density]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1e6
    block = '${pebble_blocks}'
  []
[]

[MDFlowBC]
  [cl]
    type = CenterLine
    boundary = 'centerline'
  []
  [int_walls]
    type = GenericSlipWall
    boundary = 'converging_bed_wall defueling_chute_wall ir_left_wall
    outlet_annulus_wall'
    wall_to_pebble_bed_heat_transfer = true
  []
[]

[Kernels]
  [heat]
    type = CoupledForce
    variable = Ts
    block = ${pebble_blocks}
    v = power_density
  []
[]

[AuxKernels]
  [rho_aux]
    type = DensityAux
    variable = rho_aux
    block = ${fluid_blocks}
  []
[]

[UserObjects]
  [Rho_dc_UO]
    type = LayeredAverage
    variable = rho
    direction = y
    num_layers = 22
    block = 'downcomer_pipe'
    execute_on = 'timestep_end'
    use_displaced_mesh = true
  []
  [Rho_cr_UO]
    type = LayeredAverage
    variable = rho
    direction = y
    num_layers = 28
    block = 'control_rod'
    execute_on = 'timestep_end'
    use_displaced_mesh = true
  []
  [T_cr_UO]
    type = LayeredAverage
    variable = temperature
    direction = y
    num_layers = 28
    block = 'control_rod'
    execute_on = 'timestep_end'
    use_displaced_mesh = true
  []
[]

[Preconditioning]
  [SMP_PJFNK]
    type = SMP
    full = true
    solve_type = 'PJFNK'
    petsc_options_iname = '-pc_type -ksp_gmres_restart'
    petsc_options_value = 'lu 100'
  []
[]

[Functions]
  [timestepper]
    type = PiecewiseLinear
    x = '0   0.9 1.0 500 1900 2000 4500 5000 1e5'
    y = '0.1 0.1 0.5 100  100  500  500  1000 1000'
  []
[]

[Executioner]
  type = Transient
  scheme = 'implicit-euler'
  dtmin = 1e-4
  dtmax = 1000

  [TimeStepper]
    type = IterationAdaptiveDT
    growth_factor = 1.25
    optimal_iterations = 10
    linear_iteration_ratio = 100
    dt = 0.01
    cutback_factor = 0.8
    cutback_factor_at_failure = 0.8
  []
  #  reset_dt = true

  #  [TimeStepper]
  #    type = FunctionDT
  #    function = timestepper
  #  []

  nl_rel_tol = 1e-3
  nl_abs_tol = 1e-4
  nl_max_its = 15
  l_tol = 1e-5
  l_max_its = 100

  start_time = 0
  end_time = 1000 #2e4

  [Quadrature]
    type = GAUSS
    order = SECOND
  []
[]

[Postprocessors]
  [T_core]
    type = ElementAverageValue
    block = ${pebble_blocks}
    variable = T
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [Ts_core]
    type = ElementAverageValue
    block = ${pebble_blocks}
    variable = Ts
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Inlet plenum mass balance
  [imfr_DCPipe]
    type = ComponentBoundaryFlow
    input = 'downcomer_pipe(out)'
  []
  [imfr_inltCht]
    type = MDSideMassFluxIntegral
    boundary = 'inlet_chute'
    rho = rho_aux
  []
  [imfr_inltAns]
    type = MDSideMassFluxIntegral
    boundary = 'inlet_annulus'
    rho = rho_aux
  []
  [imfr_CtrlRd]
    type = ComponentBoundaryFlow
    input = 'control_rod(in)'
  []

  # Outlet plenum mass balance
  [omfr_dfCht]
    type = MDSideMassFluxIntegral
    boundary = 'defueling_chute'
    rho = rho_aux
  []
  [omfr_OutAns]
    type = MDSideMassFluxIntegral
    boundary = 'outlet_annulus'
    rho = rho_aux
  []
  [omfr_CtrlRd]
    type = ComponentBoundaryFlow
    input = 'control_rod(out)'
  []
  [omfr_ExtPipe]
    type = ComponentBoundaryFlow
    input = 'extraction_pipe(in)'
  []
  [omfr_DiodePipe]
    type = ComponentBoundaryFlow
    input = 'diode_pipe1(in)'
  []
  [omfr_uhPipe]
    type = ComponentBoundaryFlow
    input = 'uh_pipe(in)'
  []

  # core energy balance
  [efr_inltCht]
    type = MDSideEnthalpyFluxIntegral
    boundary = 'inlet_chute'
    rho = rho_aux
  []
  [efr_inltAns]
    type = MDSideEnthalpyFluxIntegral
    boundary = 'inlet_annulus'
    rho = rho_aux
  []

  [efr_dfCht]
    type = MDSideEnthalpyFluxIntegral
    boundary = 'defueling_chute'
    rho = rho_aux
  []
  [efr_OutAns]
    type = MDSideEnthalpyFluxIntegral
    boundary = 'outlet_annulus'
    rho = rho_aux
  []
  [rccs_Qwall]
    type = ConductionHeatRemovalRate
    boundary = 'RCCS:inner_wall'
    heated_perimeter = -14.074335
  []

  [vessel_Qwall]
    type = SideDiffusiveFluxIntegral
    variable = Ts
    boundary = vessel_wall
    diffusivity = 40
  []

  [rho_up]
    type = ScalarVariable
    variable = outlet_plenum:temperature
  []
  [RCCS-EnergyBalance]
    type = ComponentBoundaryEnergyBalance
    input = 'riser-HT(in) riser-HT(out)'
    eos = water
  []
  [RV-surface]
    type = SideAverageValue
    variable = Ts
    boundary = 'vessel_wall'
  []
  [RCCS-InletTemp]
    type = ComponentBoundaryVariableValue
    input = 'riser-HT(in)'
    variable = temperature
  []
  [RCCS-OutletTemp]
    type = ComponentBoundaryVariableValue
    input = 'riser-HT(out)'
    variable = temperature
  []
  [air_T_in]
    type = ComponentBoundaryVariableValue
    variable = temperature
    input = 'RCCS-HX(primary_in)'
  []
  [air_T_out]
    type = ComponentBoundaryVariableValue
    variable = temperature
    input = 'RCCS-HX(primary_out)'
  []
  [air_flow]
    type = ComponentBoundaryFlow
    input = 'RCCS-HX(primary_in)'
  []
  [water_flow]
    type = ComponentBoundaryFlow
    input = 'RCCS-HX(secondary_in)'
  []
  [AIR-pickup]
    type = ComponentBoundaryEnergyBalance
    input = 'RCCS-HX(primary_in) RCCS-HX(primary_out)'
    eos = air
  []
[]

[Outputs]
  perf_graph = true
  print_linear_residuals = false
  [out]
    type = Exodus
    use_displaced = true
    execute_on = 'initial timestep_end'
    sequence = false
  []
  [checkpoint]
    type = Checkpoint
    num_files = 1
  []
  [csv]
    type = CSV
    #    execute_on = 'initial final'
  []

  [console]
    type = Console
    fit_mode = AUTO
    execute_scalars_on = 'NONE'
  []
[]
