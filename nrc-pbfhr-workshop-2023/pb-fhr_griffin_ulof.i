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
porosity      			= 0.388
burnup_group_boundaries = '1.8688E+14 3.7375E+14 5.6063E+14 7.4750E+14 9.3438E+14 1.1213E+15 1.280E+15 1.360E+15'

# Power ------------------------------------------------------------------------
total_power     		= 320.0e+6 # Total reactor Power (W)

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
  equation_type = transient
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
    assemble_delay_jacobian = true
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
  []
  [Rho]
    order = CONSTANT
    family = MONOMIAL
  []
  [Rho_hw]
    order = CONSTANT
    family = MONOMIAL
    block = 'hot_well'
  []
  [Rho_dc]
    order = CONSTANT
    family = MONOMIAL
    block = 'downcomer'
  []
  [Rho_cr]
    order = CONSTANT
    family = MONOMIAL
    block = 'cr_flibe'
  []
  [T_cr]
    order = CONSTANT
    family = MONOMIAL
    block = 'control_rod'
  []
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [prompt_power_density]
    order = CONSTANT
    family = MONOMIAL
  []
  [power_density2]
    order = CONSTANT
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
#  [isotope_density_aux]
#    type                    = ArrayVarBatemanSolve
#    variable                = pebble_isotope_density
#    dataset                 = ISOXML
#    isoxml_data_file       = 'DRAGON5_DT.xml'
#    isoxml_lib_name        = 'PSEUDO_20'
#    execute_on              = 'INITIAL TIMESTEP_BEGIN'
#    # transmutation parameters
#    scalar_flux             = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
#    scalar_flux_scaling     = power_scaling #2.0946120E+18
#    burnup_group_boundaries = ${burnup_group_boundaries}
#    burnup_grid_name        = 'Burnup'
#    array_grid_names        = 'Tfuel Tmod'
#    array_grid_variables    = 'triso_temperature graphite_temperature'
#    library_file = 'gFHR_4g_pebble.xml'
#    library_name = 'gFHR'
#  []  
  [decay_heat_bybg_aux]
    type                   = ArrayVarIsotopeDecayHeatAux
    variable               = decay_heat_bybg
    isotopic_composition   = pebble_isotope_density
    volume_fraction        = decay_heat_volume_fraction
    dataset                = ISOXML
    isoxml_data_file       = 'DRAGON5_DT.xml'
    isoxml_lib_name        = 'PSEUDO_20'
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
  [dt_max_fn]
    type = PiecewiseLinear
    x = '-10     0      100   1000 5000 20000 100000 200000 500000'
    y = '  5.0    5.0    5.0   10.0    50  200   400   400   500'
  []
  [./time_step]
    type = PiecewiseLinear #Let down curve t1/2 = 4.5 seconds
    x = ' 0     550  3550	3700 10000'
    y = '  0.1  0.1  1.0  1.0  10'
  [../]
[]

[UserObjects]
  [transport_solution]
    type = TransportSolutionVectorFile
    transport_system = diff
    scale_with_keff  = false
    writing = false
    execute_on = 'initial'
  []
  [depletion_solution]
    type = SolutionVectorFile
    var = 'pebble_isotope_density pebble_volume_fraction graphite_temperature triso_temperature partial_power_density Rho Tsolid
           Rho_cr Rho_dc Rho_hw T_cr'
    writing = false
    execute_on = 'initial'
  []
  [init_power_density]
    type        = SolutionVectorFile
    var         =  'prompt_power_density  decay_heat ' 
    loading_var = 'prompt_power_density  decay_heat ' 
	  writing     = false
    execute_on  = 'INITIAL'
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
  order                           = CONSTANT
  
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
  n_fresh_pebble_types            = 1 
  
  track_isotopes                  = '  U235    U236    U238   PU238   PU239   PU240   PU241   PU242   AM241 
                                     AM242M   CS135   CS137   XE135   XE136    I131    I135    SR90'

  decay_heat                      = true
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
type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart '
  petsc_options_value = 'hypre boomeramg 100'
  
  start_time = 0
  end_time = 10 # Short end time for demo
  #  end_time = 1e3 # End time for full coupled transient ULOF
 
  [TimeStepper]
    type = IterationAdaptiveDT
    growth_factor = 1.25
    optimal_iterations = 12
    linear_iteration_ratio = 100
    dt = 0.1
    timestep_limiting_postprocessor = dt_max_pp
    cutback_factor = 0.8
    cutback_factor_at_failure = 0.8
  []

  dtmin = 1e-4
  auto_advance = true
  line_search = l2 #none
  # Linear/nonlinear iterations.
  l_max_its = 200
  l_tol = 1e-3
  nl_max_its = 50
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-6
  fixed_point_max_its = 5
  fixed_point_rel_tol = 1e-4
  fixed_point_abs_tol = 1e-4
  accept_on_max_fixed_point_iteration = true
[]

# ==============================================================================
# MultiApps & Transfers
# ==============================================================================
[MultiApps]
  [flow]
    type = TransientMultiApp
    app_type = SamApp
    input_files =  'PB-FHR-RCCS-ULOF.i'
    keep_solution_during_restore = true
    positions = '0 0 0'
    execute_on = 'TIMESTEP_END'
    max_procs_per_app = 1
    catch_up = true
    max_catch_up_steps = 10
  []
  [pebble0]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble1]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble2]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble3]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble4]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble5]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble6]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble7]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
  [pebble8]
    type                         = FullSolveMultiApp
    input_files                  = 'gFHR_pebble_triso_ss.i'
    keep_solution_during_restore = true
    positions_file               = 'pebble_heat_pos.txt'
    execute_on = 'TIMESTEP_BEGIN'
    # max_procs_per_app = 4
  []
[]
[Transfers]
  [power_density_to_flow]
	  type = MultiAppNearestNodeTransfer
    to_multi_app = flow
    source_variable = power_density2
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
    [pebble_send_Tsolid0]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble0
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid1]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble1
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid2]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble2
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid3]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble3
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid4]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble4
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid5]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble5
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid6]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble6
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid7]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble7
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  [pebble_send_Tsolid8]
    type              = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app      = pebble8
    postprocessor     = T_surface
    source_variable   = Tsolid
  []
  # TO Pebble Partial power density.
  [pebble_send_ppd0]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble0
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 0
  []
  [pebble_send_ppd1]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble1
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 1
  []
  [pebble_send_ppd2]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble2
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 2
  []
  [pebble_send_ppd3]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble3
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 3
  []
  [pebble_send_ppd4]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble4
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 4
  []
  [pebble_send_ppd5]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble5
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 5
  []
  [pebble_send_ppd6]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble6
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 6
  []
  [pebble_send_ppd7]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble7
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 7
  []
  [pebble_send_ppd8]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app              = pebble8
    postprocessor             = pebble_power_density
    source_variable           = partial_power_density
    source_variable_component = 8
  []
  # FROM Pebble T_mod (Pebble average temperature)
  [pebble_receive_T_mod_0]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble0
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 0
  []
  [pebble_receive_T_mod_1]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble1
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 1
  []
  [pebble_receive_T_mod_2]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble2
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 2
  []
  [pebble_receive_T_mod_3]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble3
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 3
  []
  [pebble_receive_T_mod_4]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble4
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 4
  []
  [pebble_receive_T_mod_5]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble5
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 5
  []
  [pebble_receive_T_mod_6]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble6
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 6
  []
  [pebble_receive_T_mod_7]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble7
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 7
  []
  [pebble_receive_T_mod_8]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble8
    postprocessor             = T_mod
    source_variable           = graphite_temperature
    source_variable_component = 8
  []
  # FROM Pebble T_fuel (TRISO average temperature)
  [pebble_receive_T_fuel_0]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble0
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 0
  []
  [pebble_receive_T_fuel_1]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble1
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 1
  []
  [pebble_receive_T_fuel_2]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble2
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 2
  []
  [pebble_receive_T_fuel_3]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble3
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 3
  []
  [pebble_receive_T_fuel_4]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble4
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 4
  []
  [pebble_receive_T_fuel_5]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble5
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 5
  []
  [pebble_receive_T_fuel_6]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble6
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 6
  []
  [pebble_receive_T_fuel_7]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble7
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 7
  []
  [pebble_receive_T_fuel_8]
    type                      = MultiAppVariableValueSamplePostprocessorTransfer
    from_multi_app            = pebble8
    postprocessor             = T_fuel
    source_variable           = triso_temperature
    source_variable_component = 8
  []
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
  [dt]
    type = TimestepSize
  []
  [dt_max_pp]
    type       = FunctionValuePostprocessor
    function   = dt_max_fn
    execute_on = TIMESTEP_BEGIN
  []
  [UnscaledTotalPower]
    type                = FluxRxnIntegral
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
          bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    cross_section       = kappa_sigma_fission
    coupled_flux_groups = 'sflux_g0 sflux_g1 sflux_g2 sflux_g3'
    execute_on          = 'initial'
  []
#  [power_scaling2]
#    type        = PowerModulateFactor
#    power_pp    = UnscaledTotalPower
#    rated_power = 299783319.8 # ${fparse total_power / (1 + 0.06316697)} #2.344921322E+08 #2.344934400E+08 #2.33935E+08 # Power * (1-DHF_tot)
#    execute_on  = 'initial'
#  []
[power_scaling2]
  type  =      ConstantPostprocessor #PowerModulateFactor
  value = 1.592691e+18
 # power_pp    = UnscaledTotalPower
 # rated_power = 299783319.8 # ${fparse total_power / (1 + 0.06316697)} #2.344921322E+08 #2.344934400E+08 #2.33935E+08 # Power * (1-DHF_tot)
  execute_on  = 'initial'
[]
  [prompt_power]
    type        = ElementIntegralVariablePostprocessor
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
          bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable    = prompt_power_density
    execute_on  = 'initial timestep_end'
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
  [total_power2]
    type        = ElementIntegralVariablePostprocessor
    block = 'inlet_chute1 inlet_chute2 inlet_chute3 diverging_bed1 diverging_bed2 diverging_bed3 cylindrical_bed 
          bed_bypass1 bed_bypass2 converging_bed1 converging_bed2 converging_bed3 defueling_chute1 defueling_chute2'
    variable    = power_density2
	  execute_on  = 'initial timestep_end'
  []
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
 execute_on = 'INITIAL FINAL TIMESTEP_END'
[]
