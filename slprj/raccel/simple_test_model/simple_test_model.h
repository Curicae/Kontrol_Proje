#ifndef simple_test_model_h_
#define simple_test_model_h_
#ifndef simple_test_model_COMMON_INCLUDES_
#define simple_test_model_COMMON_INCLUDES_
#include <stdlib.h>
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "rtwtypes.h"
#include "sigstream_rtw.h"
#include "simtarget/slSimTgtSigstreamRTW.h"
#include "simtarget/slSimTgtSlioCoreRTW.h"
#include "simtarget/slSimTgtSlioClientsRTW.h"
#include "simtarget/slSimTgtSlioSdiRTW.h"
#include "simstruc.h"
#include "fixedpoint.h"
#include "raccel.h"
#include "slsv_diagnostic_codegen_c_api.h"
#include "rt_logging_simtarget.h"
#include "rt_nonfinite.h"
#include "math.h"
#include "dt_info.h"
#include "ext_work.h"
#endif
#include "simple_test_model_types.h"
#include <stddef.h>
#include "rtw_modelmap_simtarget.h"
#include "rt_defines.h"
#include <string.h>
#define MODEL_NAME simple_test_model
#define NSAMPLE_TIMES (1) 
#define NINPUTS (0)       
#define NOUTPUTS (0)     
#define NBLOCKIO (0) 
#define NUM_ZC_EVENTS (0) 
#ifndef NCSTATES
#define NCSTATES (0)   
#elif NCSTATES != 0
#error Invalid specification of NCSTATES defined in compiler command
#endif
#ifndef rtmGetDataMapInfo
#define rtmGetDataMapInfo(rtm) (*rt_dataMapInfoPtr)
#endif
#ifndef rtmSetDataMapInfo
#define rtmSetDataMapInfo(rtm, val) (rt_dataMapInfoPtr = &val)
#endif
#ifndef IN_RACCEL_MAIN
#endif
typedef struct { real_T fxsxk0ftdv ; real_T ksjwqf3jaz ; real_T n1ndgjkqju ;
real_T ln2j2usbzg ; struct { void * AQHandles ; } kadzxqox42 ; struct { void
* AQHandles ; } eqcemkr50r ; int32_T p3meensghn ; int32_T gju1qovh1g ; } DW ;
typedef struct { rtwCAPI_ModelMappingInfo mmi ; } DataMapInfo ; struct P_ {
real_T SineSource_Amp ; real_T SineSource_Bias ; real_T SineSource_Freq ;
real_T SineSource_Phase ; real_T SineSource_Hsin ; real_T SineSource_HCos ;
real_T SineSource_PSin ; real_T SineSource_PCos ; real_T SineSource2_Amp ;
real_T SineSource2_Bias ; real_T SineSource2_Freq ; real_T SineSource2_Phase
; real_T SineSource2_Hsin ; real_T SineSource2_HCos ; real_T SineSource2_PSin
; real_T SineSource2_PCos ; } ; extern const char_T *
RT_MEMORY_ALLOCATION_ERROR ; extern DW rtDW ; extern P rtP ; extern mxArray *
mr_simple_test_model_GetDWork ( ) ; extern void mr_simple_test_model_SetDWork
( const mxArray * ssDW ) ; extern mxArray *
mr_simple_test_model_GetSimStateDisallowedBlocks ( ) ; extern const
rtwCAPI_ModelMappingStaticInfo * simple_test_model_GetCAPIStaticMap ( void )
; extern SimStruct * const rtS ; extern DataMapInfo * rt_dataMapInfoPtr ;
extern rtwCAPI_ModelMappingInfo * rt_modelMapInfoPtr ; void MdlOutputs ( int_T
tid ) ; void MdlOutputsParameterSampleTime ( int_T tid ) ; void MdlUpdate ( int_T tid ) ; void MdlTerminate ( void ) ; void MdlInitializeSizes ( void ) ; void MdlInitializeSampleTimes ( void ) ; SimStruct * raccel_register_model ( ssExecutionInfo * executionInfo ) ;
#endif
