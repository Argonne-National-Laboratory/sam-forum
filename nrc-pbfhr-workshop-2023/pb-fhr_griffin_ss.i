#
#  OFFICIAL USE ONLY
#  May be exempt from public release under the Freedom of Information Act
#  (5 U.S.C. 552), exemption number and category: 4 Commercial/Proprietary
#  Review required before public release Name/Org: Javier Ortensi C110.
#  Date: 06/09/2023. Guidance (if applicable): N/A
#
# ==============================================================================
# Model description
# core neutronics model coupled to streamline method for equilibrium core
# 4 energy group structure:
#   1.96403000E+07  1.95007703E+05
#   1.95007703E+05  1.75647602E+01
#   1.75647602E+01  2.33006096E+00
#   2.33006096E+00  1.10002700E-04
# ------------------------------------------------------------------------------
# Idaho Falls, INL, June 9, 2023
# Author(s): Javier Ortensi
# ==============================================================================
# MODEL PARAMETERS
# ==============================================================================
# parameters describing the reactor geometry
core_height     		= 8.5
active_core_radius 	 	= 1.2
porosity      			= 0.388

# parameters describing the pebbles
pebble_radius       	= 2e-2
pebble_volume       	= ${fparse 4 / 3 * pi * pebble_radius * pebble_radius * pebble_radius}

# parameters describing pebble motion
residence_time     		= 65.25  # time in days to approximate 8 passes; 522 days / 8 passes
pebble_speed    		= ${fparse core_height/ (residence_time * 3600 * 24)}
pebble_flow_area    	= ${fparse pi * active_core_radius * active_core_radius}
pebble_unloading_rate 	= ${fparse pebble_speed * pebble_flow_area * (1.0 - porosity) / pebble_volume}

burnup_group_boundaries = '1.8688E+14 3.7375E+14 5.6063E+14 7.4750E+14 9.3438E+14 1.1213E+15 1.280E+15 1.36E+15' # 1.35E+15'
burnup_group_avg        = '9.34400E+13	2.80315E+14	4.67190E+14	6.54065E+14	8.40940E+14	1.02784E+15	1.20065E+15	1.31500E+15 1.31500E+15'
burnup_limit            = 1.36E+15 #1.35E+15

# Power ------------------------------------------------------------------------
total_power     		= 320.0e+6 # Total reactor Power (W)
# Nominal values
solid_temperature   	= 900.0  # (K)
fuel_temperature    	= 959.0  # (K)
Rho       				= 1973.8 # kg/m^3
Rho_ref      			= 1973.8 # kg/m^3
# ==============================================================================
# GLOBAL PARAMETERS
# ==============================================================================
[GlobalParams]
  library_file = 'gFHR_4g_pebble.xml'
  library_name = 'gFHR'
  is_meter = true
  plus = true
[]

[Debug]
  show_var_residual_norms = false
  check_boundary_coverage = true
  show_neutronics_material_coverage = true
  show_rodded_materials_average_segment_in = rod_id
[]

[TransportSystems]
  particle = neutron
  equation_type = eigenvalue
  G = 4
  ReflectingBoundary = 'centerline'
  VacuumBoundary = 'top bottom vessel_wall'

  [diff]
    scheme = CFEM-Diffusion
    family = LAGRANGE
    order = FIRST
    n_delay_groups = 6
    assemble_scattering_jacobian = true
    assemble_fission_jacobian = true
  []
[]

# ==============================================================================
# GEOMETRY AND MESH
# ==============================================================================
[Mesh]
 [input_mesh]
   type = FileMeshGenerator
   file = 'PB-FHR-neutronics.e'
 []
  #material library assignments
  #  1 - pebble_bed hard (micro)
  #  2 - pebble_bed soft (micro)
  #  3 - reflector (macro)
  #  4 - ss316 (macro)
  #  5 - FLiBe (macro)
 [assign_material_id]
   type = SubdomainExtraElementIDGenerator
   input = input_mesh
   subdomains =        '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26'
   extra_element_ids = '1 2 2 2 1 2 2 1 2  2  1  2  2  2  2  3  3  2  3  2  2  4  4  5  5  5'
   extra_element_id_names = 'material_id'
 []
 coord_type = RZ
 uniform_refine = 0
[]

# ==============================================================================
# AUXVARIABLES AND AUXKERNELS
# ==============================================================================
[AuxVariables]
  [Tsolid]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = ${fparse solid_temperature}
  []
  [Rho]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = ${fparse Rho}
  []
  [Rho_hw]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = ${fparse Rho}
    block = 'hot_well'
  []
  [Rho_dc]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = ${fparse Rho}
    block = 'downcomer'
  []
  [Rho_cr]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = ${fparse Rho}
    block = 'cr_flibe'
  []
  [T_cr]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = ${fparse solid_temperature}
    block = 'control_rod'
  []
  [Burnup]
    order = CONSTANT
    family = MONOMIAL
    components = 9
    # use burnup midpoints and add one additional for discard group
    initial_condition = ${burnup_group_avg}
  []
  [Burnup_avg]
    order = CONSTANT
    family = MONOMIAL
  []
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [prompt_power_density]
    order  = CONSTANT
    family = MONOMIAL
  []
  [power_density2]
    order  = CONSTANT
    family = MONOMIAL
  []
  [decay_heat_bybg]
    family = MONOMIAL
    order = CONSTANT
    components = 9
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
  []
  [decay_heat]
    family = MONOMIAL
    order = CONSTANT
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
  []
  [decay_heat_volume_fraction]
    family = MONOMIAL
    order = CONSTANT
    components = 9
    initial_condition = '1 1 1 1 1 1 1 1 1'
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
  []
[]

[AuxKernels]
  [Burnup_avg]
    type = PebbleAveragedAux
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable = Burnup_avg
    array_variable = Burnup
    pebble_volume_fraction = pebble_volume_fraction
    n_fresh_pebble_types = 1
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [porosity]
    type = FunctionAux
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable = porosity
    function = porosity_f
    execute_on = 'INITIAL'
  []
  [prompt_power_density_aux]
    type                   = VectorReactionRate
    block                  = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    scalar_flux = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    variable               = prompt_power_density
    cross_section          = kappa_sigma_fission
    scale_factor           = power_scaling2
    dummies                = UnscaledTotalPower
    execute_on             = 'INITIAL timestep_end'
  []
  
  [decay_heat_bybg_aux]
    type                   = ArrayVarIsotopeDecayHeatAux
    variable               = decay_heat_bybg
    isotopic_composition   = pebble_isotope_density
    volume_fraction        = decay_heat_volume_fraction
    dataset                = ISOXML
    isoxml_data_file       = 'DRAGON5_DT.xml'
    isoxml_lib_name        = 'PSEUDO_20'
  #  strictness 					  = 0 # to avoid errors in ISOXML w.r.t. unphysical branching ratios for DH pseudos
    execute_on             = 'INITIAL timestep_end'
  []
  [decay_heat_aux]
    type                   = ArrayVarReductionAux
    variable               = decay_heat
    array_variable         = decay_heat_bybg
    execute_on             = 'INITIAL timestep_end'
  []

  [power_density2_aux]
    type       = ParsedAux
    block      = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable   = power_density2
    args       = 'prompt_power_density decay_heat'
    function   = 'prompt_power_density + decay_heat'
    execute_on = 'INITIAL timestep_end'
  []
[]

[Functions]
  [porosity_f]
    type = ConstantFunction
    value = ${porosity}
  []
  [CR_pos_f]
    type = ConstantFunction
    value = '4.225'
  []
[]

[UserObjects]
  [transport_solution]
    type = TransportSolutionVectorFile
    transport_system = diff
    writing = true
    execute_on = 'FINAL'
  []
  [depletion_solution]
    type = SolutionVectorFile
    var = 'pebble_isotope_density pebble_volume_fraction graphite_temperature triso_temperature partial_power_density Rho Tsolid
           Rho_cr Rho_dc Rho_hw T_cr scaled_sflux_g0 scaled_sflux_g1 scaled_sflux_g2 scaled_sflux_g3 power_density'
    writing = true
    execute_on = 'FINAL'
  []
  [init_power_density]
    type       = SolutionVectorFile
    var        = 'prompt_power_density  decay_heat  pebble_isotope_density' 
    writing    = true
    execute_on = 'FINAL'
  []
[]

# ==============================================================================
# DEPLETION
# ==============================================================================
[PebbleDepletion]
  block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
  
  power                           = ${fparse total_power}
  integrated_power_postprocessor  = total_power
  power_density_variable          = power_density
  family                          = MONOMIAL
  order                           = CONSTANT #FIRST
  
  porosity_name                   = porosity
  burnup_group_boundaries         = ${burnup_group_boundaries}

  # cross section data
  library_file                          = 'gFHR_4g_pebble.xml'
  library_name                          = 'gFHR'
  burnup_grid_name                      = 'Burnup'
  fuel_temperature_grid_name            = 'Tfuel'
  moderator_temperature_grid_name       = 'Tmod'
  additional_grid_name_variable_mapping = 'Rho Rho'

  # coolant settings
  coolant_density_variable = Rho
  coolant_atomic_densities = 'LI6 4.38333E-07 LI7 2.40010E-02 BE9 1.20001E-02 F19 4.80084E-02' # equilibrium values
  coolant_density_ref = ${fparse Rho_ref}

  # transmutation data
  dataset                         = ISOXML
  isoxml_data_file                = 'DRAGON5_DT.xml'
  isoxml_lib_name                 = 'PSEUDO_20'
  strictness 					  = 0 # to avoid errors in ISOXML w.r.t. unphysical branching ratios for DH pseudos

  fresh_pebble_isotopes =               'U234           U235            U238            C12              O16              O17            Graphite          SI28        SI29              SI30           pseudo_G'
  fresh_pebble_isotope_densities = '1.43856269E-08  5.09162564E-05  2.06863668E-04  9.03720735E-04  3.86545726E-04 1.46942583E-07    4.81177028E-03  7.14571157E-04  3.63004146E-05 2.39580131E-05  7.41205513E-02'

  initial_moderator_temperature   = ${solid_temperature}
  initial_fuel_temperature        = ${fuel_temperature}
  n_fresh_pebble_types            = 1 
  
  track_isotopes                  = '  U235    U236    U238   PU238   PU239   PU240   PU241   PU242   AM241 
                                     AM242M   CS135   CS137   XE135   XE136    I131    I135    SR90'

  decay_heat                      = true
  
  [DepletionScheme]
    type                          	= ConstantStreamlineEquilibrium
    pebble_unloading_rate         	= ${pebble_unloading_rate}
    pebble_flow_rate_distribution 	= '0.04 0.12 0.20 0.28 0.36'
    burnup_limit                  	= ${burnup_limit}
    major_streamline_axis         	= y
    exodus_streamline_output        = false
    pebble_diameter               	= ${fparse pebble_radius * 2.0}
    streamline_points 				= '0.05 0 0  0.05 1.4 0  0.12 1.9 0  0.12 5 0  0.025 6.5 0  0.025 8.5 0;
                         			   0.15 0 0  0.15 1.4 0  0.36 1.9 0  0.36 5 0  0.075 6.5 0  0.075 8.5 0;
                         			   0.25 0 0  0.25 1.4 0  0.6  1.9 0  0.6  5 0  0.125 6.5 0  0.125 8.5 0;
                         			   0.35 0 0  0.35 1.4 0  0.84 1.9 0  0.84 5 0  0.175 6.5 0  0.175 8.5 0;
                         			   0.45 0 0  0.45 1.4 0  1.08 1.9 0  1.08 5 0  0.225 6.5 0  0.225 8.5 0'
    streamline_segment_subdivisions = '9 6 20 8 9;
                                       9 6 20 8 9;
                                       9 6 20 8 9;
                                       9 6 20 8 9;
                                       9 6 20 8 9'
    material_ids                  	= '1 1 1 2 2;
                                       1 1 1 1 2;
                                       1 1 1 1 2;
                                       2 2 1 2 2;
                                       2 2 2 2 2'
    sweep_tol                       = 1e-7
    sweep_max_iterations            = 100
  []

  # pebble conduction
  pebble_conduction_input_file                = 'gFHR_pebble_triso_ss.i'
  pebble_positions_file                       = 'pebble_heat_pos.txt'
  surface_temperature_sub_app_postprocessor   = T_surface
  surface_temperature_main_app_variable       = Tsolid
  power_sub_app_postprocessor                 = pebble_power_density
  fuel_temperature_sub_app_postprocessor      = T_fuel
  moderator_temperature_sub_app_postprocessor = T_mod
[]

# ==============================================================================
# MATERIALS
# ==============================================================================
[Materials]
  [annuli]
    type = CoupledFeedbackNeutronicsMaterial
    block = 'inlet_annulus outlet_annulus_quad outlet_annulus_tri'
    material_id = 8
    grid_names = 'Tsolid Rho'
    grid_variables = 'Tsolid Rho'
    isotopes = 'pseudo'
    densities =  '1.0'
  []
  [CR_dynamic]
    # Griffin issue #1211 -- no ability to perform density corrections in CR materials
    type = CoupledFeedbackRoddedNeutronicsMaterial
    block = 'control_rod'
    grid_names = 'Tsolid Tsolid Tsolid'
    grid_variables = 'T_cr T_cr T_cr'
    isotopes = 'pseudo; pseudo; pseudo'
    densities = '1.0 1.0 1.0'
    rod_segment_length = 6.6
    front_position_function = 'CR_pos_f'
    segment_material_ids = '7 6 7'
    rod_withdrawn_direction = 'y'
  []
  [Flibe_regions]
    type = CoupledFeedbackMatIDNeutronicsMaterial
    block = 'cr_flibe'
    grid_names = 'Rho'
    grid_variables = Rho_cr
    isotopes = 'pseudo'
    densities =  '1.0'
  []
  [DC_regions]
    type = CoupledFeedbackMatIDNeutronicsMaterial
    block = 'downcomer'
    grid_names = 'Rho'
    grid_variables = Rho_dc
    isotopes = 'pseudo'
    densities =  '1.0'
  []
  [Hot_well_regions]
    type = CoupledFeedbackMatIDNeutronicsMaterial
    block = 'hot_well'
    grid_names = 'Rho'
    grid_variables = Rho_hw
    isotopes = 'pseudo'
    densities =  '1.0'
  []
  [reflector]
    type = CoupledFeedbackMatIDNeutronicsMaterial
    block = 'upper_reflector_quad upper_reflector_tri side_reflector'
    grid_names = 'Tsolid'
    grid_variables = 'Tsolid'
    isotopes = 'pseudo'
    densities =  '1.0'
  []
  [steel_structures]
    type = CoupledFeedbackMatIDNeutronicsMaterial
    block = 'core_barrel vessel_wall'
    grid_names = 'Tsolid'
    grid_variables = 'Tsolid'
    isotopes = 'pseudo'
    densities =  '1.0'
  []
[]

# ==============================================================================
# EXECUTION PARAMETERS
# ==============================================================================
[Executioner]
  type = Eigenvalue
  solve_type = PJFNKMO
  constant_matrices = false

  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart '
  petsc_options_value = 'hypre boomeramg 100'
  line_search = none

  # Linear/nonlinear iterations.
  l_tol = 1e-3
  l_max_its = 100

  nl_max_its = 400
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-8
  fixed_point_max_its   = 50
  fixed_point_rel_tol   = 1e-4 #1e-4
  fixed_point_abs_tol   = 1e-3 #1e-3
  # Power iterations.
  free_power_iterations = 2
[]

# ==============================================================================
# MultiApps & Transfers
# ==============================================================================
[MultiApps]
  [flow]
    type = FullSolveMultiApp
    app_type = SamApp
    input_files =  'PB-FHR-RCCS.i'
    keep_solution_during_restore = true
    positions = '0 0 0'
    execute_on = 'TIMESTEP_END'
    max_procs_per_app = 1
  []
[]
[Transfers]
  [power_density_to_flow]
	  type = MultiAppNearestNodeTransfer
    to_multi_app = flow
    source_variable = power_density
    variable = power_density
	  fixed_meshes = true
	  execute_on = 'TIMESTEP_END'
  []

  [T_solid_from_flow]
	  type = MultiAppNearestNodeTransfer
    from_multi_app = flow
    source_variable = Ts
    variable = Tsolid
	  execute_on = 'TIMESTEP_END'
	  fixed_meshes = true
  []
  [Rho_fluid_from_flow]
   type =  MultiAppGeometricInterpolationTransfer    # MultiAppGeneralFieldNearestNodeTransfer
    from_multi_app = flow
    source_variable = rho_aux
    variable = Rho
  #  from_blocks = 'Inlet_Annulus Outlet_Annulus_bottom Outlet_Annulus_top'
  # to_blocks = 'inlet_annulus outlet_annulus_quad outlet_annulus_tri'
   execute_on = 'TIMESTEP_END'
  []
  [Rho_hw_from_flow]
    type =  MultiAppPostprocessorInterpolationTransfer    # MultiAppGeneralFieldNearestNodeTransfer
     from_multi_app = flow
     postprocessor = rho_up
     variable = Rho_hw
     execute_on = 'TIMESTEP_END'
   []
  [./Rho_from_downcomer]
   type = MultiAppUserObjectTransfer
   from_multi_app = flow
    user_object = Rho_dc_UO
    variable = Rho_dc
    displaced_source_mesh = true
    execute_on = TIMESTEP_END
  [../]
   [./Rho_from_cr]
      type = MultiAppUserObjectTransfer
      from_multi_app = flow
       user_object = Rho_cr_UO
       variable = Rho_cr
       displaced_source_mesh = true
       execute_on = TIMESTEP_END
    [../]
  [./T_from_cr]
    type = MultiAppUserObjectTransfer
    from_multi_app = flow
    user_object = T_cr_UO
    variable = T_cr
    displaced_source_mesh = true
    execute_on = TIMESTEP_END
  [../]
[]
# ==============================================================================
# POSTPROCESSORS DEBUG AND OUTPUTS
# ==============================================================================
[Postprocessors]
  [Tsolid_core]
    type = ElementAverageValue
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
          bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable = Tsolid
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Tsolid_ref]
    type = ElementAverageValue
    block = 'upper_reflector_quad upper_reflector_tri side_reflector'
    variable = Tsolid
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Tsolid_ss316]
    type = ElementAverageValue
    block = 'core_barrel vessel_wall'
    variable = Tsolid
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_int_inchute]
    type = FluxIntegral
    block = 'inlet_chute1 inlet_chute2 inlet_chute3'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_int_pb]
    type = FluxIntegral
    block = 'cylindrical_bed bed_bypass1 bed_bypass2'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_int_dvg]
    type = FluxIntegral
    block = 'diverging_bed1 diverging_bed2 diverging_bed3'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_int_cvg]
    type = FluxIntegral
    block = 'converging_bed1 converging_bed2 converging_bed3'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_int_outchute]
    type = FluxIntegral
    block = 'defueling_chute1 defueling_chute2 '
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  
  [Flux_avg_inchute]
    type = FluxAverage
    block = 'inlet_chute1 inlet_chute2 inlet_chute3'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_avg_pb]
    type = FluxAverage
    block = 'cylindrical_bed bed_bypass1 bed_bypass2'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_avg_dvg]
    type = FluxAverage
    block = 'diverging_bed1 diverging_bed2 diverging_bed3'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_avg_cvg]
    type = FluxAverage
    block = 'converging_bed1 converging_bed2 converging_bed3'
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Flux_avg_outchute]
    type = FluxAverage
    block = 'defueling_chute1 defueling_chute2 '
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on =  'INITIAL TIMESTEP_END'
  []

  [Burnup_avg_inchute]
    type = ElementAverageValue
    block = 'inlet_chute1 inlet_chute2 inlet_chute3'
    variable = Burnup_avg
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Burnup_avg_pb]
    type = ElementAverageValue
    block = 'cylindrical_bed bed_bypass1 bed_bypass2'
    variable = Burnup_avg
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Burnup_avg_dvg]
    type = ElementAverageValue
    block = 'diverging_bed1 diverging_bed2 diverging_bed3'
    variable = Burnup_avg
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Burnup_avg_cvg]
    type = ElementAverageValue
    block = 'converging_bed1 converging_bed2 converging_bed3'
    variable = Burnup_avg
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [Burnup_avg_outchute]
    type = ElementAverageValue
    block = 'defueling_chute1 defueling_chute2 '
    variable = Burnup_avg
    execute_on =  'INITIAL TIMESTEP_END'
  []
  [UnscaledTotalPower]
    type                = FluxRxnIntegral
    block               = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    cross_section       = kappa_sigma_fission
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on          = 'transfer timestep_end'
  []
  [power_scaling2]
    type        = PowerModulateFactor
    power_pp    = UnscaledTotalPower
    rated_power = 299783319.8  #prompt power = total power / (1 + decay heat fraction) - W reduced by DH
    execute_on  = 'transfer timestep_end'
  []
  [prompt_power]
    type        = ElementIntegralVariablePostprocessor
    block       = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable    = prompt_power_density
    execute_on  = 'transfer timestep_end'
  []
  [total_power2]
    type        = ElementIntegralVariablePostprocessor
    block       = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable    = power_density2
	  execute_on  = 'transfer timestep_end'
  []
  [avg_power_density]
    type        = ElementAverageValue
    block       = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable    = power_density
    execute_on  = 'transfer timestep_end'
  []
    [decay_heat]
    type = ElementIntegralVariablePostprocessor
    variable = total_pebble_decay_heat
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [decay_heat2]
    type = ElementIntegralVariablePostprocessor
    variable = decay_heat
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
           bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

# ==============================================================================
# POSTPROCESSORS DEBUG AND OUTPUTS
# ==============================================================================
[Outputs]
  file_base  = pb_fhr_griffin_ss_out
  exodus     = true
  csv        = true
  perf_graph = true
  execute_on = 'INITIAL FINAL TIMESTEP_END'
[]