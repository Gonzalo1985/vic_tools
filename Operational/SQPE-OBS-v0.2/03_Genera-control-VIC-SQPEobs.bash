#!/bin/bash

#**********************************************************************************
# Gonzalo M. Diaz
# MINISTERIO DE DEFENSA - Servicio Meteorologico Nacional, Buenos Aires, 09.09.2020
#
#**********************************************************************************
# Paso 03 -> De la operatividad del pronóstico hidrológico con VIC + routeo
#            Generación del archivo de Control del modelo VIC para la corrida 
#            con SQPE-OBS-v0.2
#**********************************************************************************
# El script arma el archivo de control del VIC. Algunos de los parametros del 
# archivo de control son escritos en un archivo (param_control_file.txt) generado 
# en el paso 02
#**********************************************************************************

###################################################################################################
### RUTA DE: 
##### LOS ARCHIVOS DE SUELO Y VEGETACION DEL VIC
##### LOS ARCHIVOS (data) DE ENTRADA DEL VIC
##### LOS ARCHIVOS (fluxes) DE SALIDA DEL VIC
path_PF_VIC='/data/oper-hidro/VIC/Parameter_Files/PF_VIC/SQPE-OBS-v0.2/'
path_data='/data/oper-hidro/VIC/Inputs/In_VIC_SQPE-OBS-v0.2/'
path_fluxes='/data/oper-hidro/VIC/Outputs/Out_VIC_SQPE-OBS-v0.2'
###################################################################################################

CONTROL_VIC='control_file_VIC.prn'
rm ${path_PF_VIC}${CONTROL_VIC}

###################################################################################################
### A PARTIR DEL ARCHIVO DEL paso 02 (param_control_file.txt) SE DEFINEN 16 VARIABLES 
### QUE DEBE LEER ESTE SCRIPT PARA ARMAR EL ARCHIVO DE CONTROL DEL VIC
### VARIABLES: ${PART[0]} hasta ${PART[15]}
#cd ${path_PF_VIC}
#value=$(<param_control_file.txt)
#PART=(${value// / })
#SOIL_FILE=$(echo ${PART[15]} | sed 's/[\"]//g')

cd ${path_PF_VIC}
value=$(<param_control_file.txt)
PART=($value)
#PART=(${value// / })
START_YEAR=$(echo ${PART[5]} | sed 's/[\"]//g')
START_MONTH=$(echo ${PART[3]} | sed 's/[\"]//g')
START_DAY=$(echo ${PART[1]} | sed 's/[\"]//g')
END_YEAR=$(echo ${PART[29]} | sed 's/[\"]//g')
END_MONTH=$(echo ${PART[27]} | sed 's/[\"]//g')
END_DAY=$(echo ${PART[25]} | sed 's/[\"]//g')
SOIL_FILE=$(echo ${PART[31]} | sed 's/[\"]//g')
###################################################################################################


echo "
#######################################################################
# VIC Model Parameters - 4.2
#######################################################################
# $Id$
#######################################################################
# Simulation Parameters
#######################################################################
NLAYER      3   # number of soil layers
NODES       10  # number of soil thermal nodes
TIME_STEP   24   # model time step in hours (set to 24 if FULL_ENERGY = FALSE, set to < 24 if FULL_ENERGY = TRUE)
SNOW_STEP   3   # time step in hours for which to solve the snow model (should = TIME_STEP if TIME_STEP < 24)
STARTYEAR   ${START_YEAR}    # year model simulation starts
STARTMONTH  ${START_MONTH}  # month model simulation starts
STARTDAY    ${START_DAY}  # day model simulation starts
STARTHOUR   00  # hour model simulation starts
ENDYEAR     ${END_YEAR}    # year model simulation ends
ENDMONTH    ${END_MONTH}  # month model simulation ends
ENDDAY      ${END_DAY}  # day model simulation ends

#######################################################################
# Energy Balance Parameters
#######################################################################
FULL_ENERGY     FALSE   # TRUE = calculate full energy balance; FALSE = compute water balance only.  Default = FALSE.
#CLOSE_ENERGY   FALSE   # TRUE = all energy balance calculations (canopy air, canopy snow, ground snow,
                        # and ground surface) are iterated to minimize the total column error.  Default = FALSE.

#######################################################################
# Soil Temperature Parameters
# VIC will choose appropriate value for QUICK_FLUX depending on values of FULL_ENERGY and FROZEN_SOIL; the user should only need to override VIC's choices in special cases.
# The other options in this section are only applicable when FROZEN_SOIL is TRUE and their values depend on the application.
#######################################################################
FROZEN_SOIL FALSE   # TRUE = calculate frozen soils.  Default = FALSE.
QUICK_FLUX TRUE   # TRUE = use simplified ground heat flux method of Liang et al (1999); FALSE = use finite element method of Cherkauer et al (1999)
IMPLICIT   FALSE    # TRUE = use implicit solution for soil heat flux equation of Cherkauer et al (1999), otherwise uses original explicit solution.  Default = TRUE.
QUICK_SOLVE    FALSE   # TRUE = Use Liang et al., 1999 formulation for iteration, but explicit finite difference method for final step.
NO_FLUX        FALSE   # TRUE = use no flux lower boundary for ground heat flux computation; FALSE = use constant flux lower boundary condition.  If NO_FLUX = TRUE, QUICK_FLUX MUST = FALSE.  Default = FALSE.
EXP_TRANS  FALSE    # TRUE = exponentially distributes the thermal nodes in the Cherkauer et al. (1999) finite difference algorithm, otherwise uses linear distribution.  Default = TRUE.
GRND_FLUX_TYPE GF_FULL  # Options for ground flux:
                       # GF_406 = use (flawed) formulas for ground flux, deltaH, and fusion from VIC 4.0.6 and earlier;
                       # GF_410 = use formulas from VIC 4.1.0 (ground flux, deltaH, and fusion are correct; deltaH and fusion ignore surf_atten);
                       # Default = GF_410
#TFALLBACK  TRUE    # TRUE = when temperature iteration fails to converge, use previous time step's T value
#SPATIAL_FROST  FALSE   (Nfrost)    # TRUE = use a uniform distribution to simulate the spatial distribution of soil frost; FALSE = assume that the entire grid cell is frozen uniformly.  If TRUE, then replace (Nfrost) with the number of frost subareas, i.e., number of points on the spatial distribution curve to simulate.  Default = FALSE.

#######################################################################
# Precip (Rain and Snow) Parameters
# Generally these default values do not need to be overridden
#######################################################################
SNOW_DENSITY   DENS_BRAS   # DENS_BRAS = use traditional VIC algorithm taken from Bras, 1990; DENS_SNTHRM = use algorithm taken from SNTHRM model.
BLOWING        FALSE   # TRUE = compute evaporative fluxes due to blowing snow
COMPUTE_TREELINE   FALSE   # Can be either FALSE or the id number of an understory veg class; FALSE = turn treeline computation off; VEG_CLASS_ID = replace any overstory veg types with the this understory veg type in all snow bands for which the average July Temperature <= 10 C (e.g. "COMPUTE_TREELINE 10" replaces any overstory veg cover with class 10)
CORRPREC   FALSE   # TRUE = correct precipitation for gauge undercatch
MAX_SNOW_TEMP  0.5 # maximum temperature (C) at which snow can fall
MIN_RAIN_TEMP  -0.5    # minimum temperature (C) at which rain can fall
#SPATIAL_SNOW   FALSE   # TRUE = use a uniform distribution to simulate the partial coverage of the
                        # surface by a thin snowpack.  Coverage is assumed to be uniform after snowfall
                        # until the pack begins to melt.  If TRUE, VIC will expect an additional column
                        # in the soil paramter file containing the snow distibution slope parameter
                        # (= 2 * snow depth below which coverage < 1).

#######################################################################
# Turbulent Flux Parameters
# Generally these default values do not need to be overridden
#######################################################################
MIN_WIND_SPEED 0.1 # minimum allowable wind speed (m/s)
AERO_RESIST_CANSNOW    AR_410 # Options for aerodynamic resistance in snow-filled canopy:
                              # AR_406    = multiply by 10 for latent heat but do NOT multiply by 10 for sensible heat and do NOT apply stability correction (as in VIC 4.0.6); when no snow in canopy, use surface aero_resist for ET.
                              # AR_406_LS     = multiply by 10 for latent heat AND sensible heat and do NOT apply stability correction; when no snow in canopy, use surface aero_resist for ET.
                              # AR_406_FULL   = multiply by 10 for latent heat AND sensible heat and do NOT apply stability correction; additionally, always use overstory aero_resist for ET (as in 4.1.0).
                              # AR_410    = apply stability correction but do NOT multiply by 10 (as in VIC 4.1.0); additionally, always use overstory aero_resist for ET (as in 4.1.0).
                              # Default   = AR_406_FULL

#######################################################################
# Meteorological Forcing Disaggregation Parameters
# Generally these default values do not need to be overridden
#######################################################################
#OUTPUT_FORCE   FALSE   # TRUE = perform disaggregation of forcings, skip the simulation, and output the disaggregated forcings.
PLAPSE     FALSe    # This controls how VIC computes air pressure when air pressure is not supplied as an input forcing: TRUE = set air pressure to sea level pressure, lapsed to grid cell average elevation; FALSE = set air pressure to constant 95.5 kPa (as in all versions of VIC pre-4.1.1)
#SW_PREC_THRESH     0   # Minimum daily precip [mm] that can cause dimming of incoming shortwave; default = 0.
#MTCLIM_SWE_CORR    TRUE    # This controls VIC's estimates of incoming shortwave in the presence of snow; TRUE = adjust incoming shortwave for snow albedo effect; FALSE = do not adjust shortwave; default = TRUE
#VP_ITER        VP_ITER_ANNUAL  # This controls VIC's iteration between estimates of shortwave and vapor pressure:
#           # VP_ITER_NEVER = never iterate; make estimates separately
#           # VP_ITER_ALWAYS = always iterate once
#           # VP_ITER_ANNUAL = iterate once for arid climates based on annual Precip/PET ratio
#           # VP_ITER_CONVERGE = iterate until shortwave and vp stabilize
#           # default = VP_ITER_ALWAYS
#VP_INTERP  TRUE    # This controls sub-daily humidity estimates; TRUE = interpolate daily VP estimates linearly between sunrise of one day to the next; FALSE = hold VP constant for entire day
#LW_TYPE        LW_PRATA    # This controls the algorithm used to estimate clear-sky longwave radiation:
#           # LW_TVA = Tennessee Valley Authority algorithm (1972) (this was traditional VIC algorithm)
#           # other options listed in vicNl_def.h
#           # default = LW_PRATA
#LW_CLOUD   LW_CLOUD_DEARDORFF  # This controls the algorithm used to estimate the influence of clouds on total longwave:
#           # LW_CLOUD_BRAS = method from Bras textbook (this was the traditional VIC algorithm)
#           # LW_CLOUD_DEARDORFF = method of Deardorff (1978)
#           # default = LW_CLOUD_DEARDORFF

#######################################################################
# Carbon Cycle Parameters
#######################################################################
#CARBON         FALSE       # TRUE = simulate carbon cycle; FALSE = do not simulate carbon cycle.  Default = FALSE.
#VEGLIB_PHOTO   FALSE       # TRUE = photosynthesis parameters are included in the veg library file.  Default = FALSE.
#RC_MODE    RC_JARVIS   # RC_JARVIS = canopy resistance computed by applying resistance factors to the veg class's minimum resistance, listed in the veg library
                            # RC_PHOTO = canopy resistance computed by applying resistance factors to the minimum resistance required by current photosynthetic demand.  Default = RC_JARVIS.

#######################################################################
# Miscellaneous Simulation Parameters
# Generally these default values do not need to be overridden
#######################################################################
CONTINUEONERROR    FALSE    # TRUE = if simulation aborts on one grid cell, continue to next grid cell

#######################################################################
# State Files and Parameters
#######################################################################
#INIT_STATE ${path_PF_VIC}state__20210807  # Initial state path/file
#STATENAME  ${path_PF_VIC}state_ # Output state file path/prefix.  The date (STATEYEAR,STATEMONTH,STATEDAY) will be appended to the prefix automatically in the format yyyymmdd.
#STATEYEAR  2021    # year to save model state
#STATEMONTH 08  # month to save model state
#STATEDAY   08  # day to save model state
#BINARY_STATE_FILE       FALSE  # TRUE if state file should be binary format; FALSE if ascii

#######################################################################
# Forcing Files and Parameters
#
#       All FORCING filenames are actually the pathname, and prefix
#               for gridded data types: ex. DATA/forcing_
#               Latitude and longitude index suffix is added by VIC
#
#   There must be 1 FORCE_TYPE entry for each variable (column) in the forcing file
#
#   If FORCE_TYPE is BINARY, each FORCE_TYPE must be followed by:
#           SIGNED/UNSIGNED SCALE_FACTOR
#       For example (BINARY):
#           FORCE_TYPE  PREC    UNSIGNED    40
#       or (ASCII):
#           FORCE_TYPE  PREC
#######################################################################
FORCING1    ${path_data}data_
FORCE_FORMAT    ASCII  # BINARY or ASCII
FORCE_ENDIAN    LITTLE  # LITTLE (PC/Linux) or BIG (SUN)
N_TYPES     4   # Number of variables (columns)
FORCE_TYPE  PREC    UNSIGNED    40
FORCE_TYPE  TMAX    SIGNED  100
FORCE_TYPE  TMIN    SIGNED  100
FORCE_TYPE  WIND    SIGNED  100
FORCE_DT    24  # Forcing time step length (hours)
FORCEYEAR   ${START_YEAR}    # Year of first forcing record
FORCEMONTH  ${START_MONTH}  # Month of first forcing record
FORCEDAY    ${START_DAY}  # Day of first forcing record
FORCEHOUR   00  # Hour of first forcing record
GRID_DECIMAL    4   # Number of digits after decimal point in forcing file names
WIND_H          10.0    # height of wind speed measurement (m)
MEASURE_H       2.0     # height of humidity measurement (m)
ALMA_INPUT  FALSE   # TRUE = ALMA-compliant input variable units; FALSE = standard VIC units

#######################################################################
# Land Surface Files and Parameters
#######################################################################
SOIL            ${path_PF_VIC}${SOIL_FILE}
BASEFLOW    ARNO    # ARNO = columns 5-8 are the standard VIC baseflow parameters; NIJSSEN2001 = columns 5-8 of soil file are baseflow parameters from Nijssen et al (2001)
JULY_TAVG_SUPPLIED  FALSE   # TRUE = final column of the soil parameter file will contain average July air temperature, for computing treeline; this will be ignored if COMPUTE_TREELINE is FALSE; FALSE = compute the treeline based on the average July air temperature of the forcings over the simulation period
ORGANIC_FRACT   FALSE   # TRUE = simulate organic soils; soil param file contains 3*Nlayer extra columns, listing for each layer the organic fraction, and the bulk density and soil particle density of the organic matter in the soil layer; FALSE = soil param file does not contain any information about organic soil, and organic fraction should be assumed to be 0
VEGLIB          ${path_PF_VIC}LDAS_veg_lib.txt
VEGPARAM        ${path_PF_VIC}vegetacion_lpb.prn
ROOT_ZONES      3   # Number of root zones (must match format of veg param file)
#VEGLIB_VEGCOVER    FALSE   # TRUE = veg lib file contains 12 monthly values of partial vegcover fraction for each veg class, between the LAI and albedo values
VEGPARAM_LAI   TRUE    # TRUE = veg param file contains LAI information; FALSE = veg param file does NOT contain LAI information
#VEGPARAM_ALB   FALSE    # TRUE = veg param file contains albedo information; FALSE = veg param file does NOT contain albedo information
#VEGPARAM_VEGCOVER  FALSE    # TRUE = veg param file contains veg_cover information; FALSE = veg param file does NOT contain veg_cover information
#LAI_SRC    FROM_VEGLIB    # FROM_VEGPARAM = read LAI from veg param file; FROM_VEGLIB = read LAI from veg library file
#ALB_SRC    FROM_VEGLIB    # FROM_VEGPARAM = read albedo from veg param file; FROM_VEGLIB = read albedo from veg library file
#VEGCOVER_SRC   FROM_VEGLIB    # FROM_VEGPARAM = read veg_cover from veg param file; FROM_VEGLIB = read veg_cover from veg library file
SNOW_BAND   1   # Number of snow bands; if number of snow bands > 1, you must insert the snow band path/file after the number of bands (e.g. SNOW_BAND 5 my_path/my_snow_band_file)

#######################################################################
# Lake Simulation Parameters
# These need to be un-commented and set to correct values only when running lake model (LAKES is not FALSE)
#######################################################################
#LAKES      (put lake parameter path/file here) # Lake parameter path/file
#LAKE_PROFILE   FALSE   # TRUE = User-specified depth-area parameters in lake parameter file; FALSE = VIC computes a parabolic depth-area profile
#EQUAL_AREA FALSE   # TRUE = grid cells are from an equal-area projection; FALSE = grid cells are on a regular lat-lon grid
#RESOLUTION 0.125   # Grid cell resolution (degrees if EQUAL_AREA is FALSE, km^2 if EQUAL_AREA is TRUE); ignored if LAKES is FALSE

#######################################################################
# Output Files and Parameters
#######################################################################
RESULT_DIR      ${path_fluxes}    # Results directory path
OUT_STEP        0       # Output interval (hours); if 0, OUT_STEP = TIME_STEP
SKIPYEAR        0       # Number of years of output to omit from the output files
COMPRESS        FALSE   # TRUE = compress input and output files when done
BINARY_OUTPUT   FALSE   # TRUE = binary output files
ALMA_OUTPUT     FALSE   # TRUE = ALMA-format output files; FALSE = standard VIC units
MOISTFRACT      FALSE   # TRUE = output soil moisture as volumetric fraction; FALSE = standard VIC units
PRT_HEADER      FALSE   # TRUE = insert a header at the beginning of each output file; FALSE = no header
PRT_SNOW_BAND   FALSE   # TRUE = write a "snowband" output file, containing band-specific values of snow variables; NOTE: this is ignored if N_OUTFILES is specified below.

N_OUTFILES	1

OUTFILE		fluxes		5
OUTVAR		OUT_PREC	
OUTVAR		OUT_EVAP
OUTVAR		OUT_RUNOFF
OUTVAR		OUT_BASEFLOW
OUTVAR		OUT_ASAT

#######################################################################
#
# Output File Contents
#
# As of VIC 4.0.6 and 4.1.0, you can specify your output file names and
# contents # in the global param file (see the README.txt file for more
# information).
#
# If you do not specify file names and contents in the global param
# file, VIC will produce the same set of output files that it has
# produced in earlier versions, namely "fluxes" and "snow" files, plus
# "fdepth" files if FROZEN_SOIL is TRUE and "snowband" files if
# PRT_SNOW_BAND is TRUE.  These files will have the same contents and
# format as in earlier versions.
#
# The OPTIMIZE and LDAS_OUTPUT options have been removed.  These
# output configurations can be selected with the proper set of
# instructions in the global param file.  (see the output.*.template
# files included in this distribution for more information.)
#
# If you do specify the file names and contents in the global param file,
# PRT_SNOW_BAND will have no effect.
#
# Format:
#
#   N_OUTFILES    <n_outfiles>
#
#   OUTFILE       <prefix>        <nvars>
#   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
#   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
#   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
#
#   OUTFILE       <prefix>        <nvars>
#   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
#   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
#   OUTVAR        <varname>       [<format>        <type>  <multiplier>]
#
#
# where
#   <n_outfiles> = number of output files
#   <prefix>     = name of the output file, NOT including latitude
#                  and longitude
#   <nvars>      = number of variables in the output file
#   <varname>    = name of the variable (this must be one of the
#                  output variable names listed in vicNl_def.h.)
#   <format>     = (for ascii output files) fprintf format string,
#                  e.g.
#                    %.4f = floating point with 4 decimal places
#                    %.7e = scientific notation w/ 7 decimal places
#                    *    = use the default format for this variable
#
#   <format>, <type>, and <multiplier> are optional.  For a given
#   variable, you can specify either NONE of these, or ALL of
#   these.  If these are omitted, the default values will be used.
#
#   <type>       = (for binary output files) data type code.
#                  Must be one of:
#                    OUT_TYPE_DOUBLE = double-precision floating point
#                    OUT_TYPE_FLOAT  = single-precision floating point
#                    OUT_TYPE_INT    = integer
#                    OUT_TYPE_USINT  = unsigned short integer
#                    OUT_TYPE_SINT   = short integer
#                    OUT_TYPE_CHAR   = char
#                    *               = use the default type
#   <multiplier> = (for binary output files) factor to multiply
#                  the data by before writing, to increase precision.
#                    *    = use the default multiplier for this variable
#
#######################################################################

" >> $CONTROL_VIC 2>&1







