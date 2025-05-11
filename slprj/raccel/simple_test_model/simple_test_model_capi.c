#include "rtw_capi.h"
#ifdef HOST_CAPI_BUILD
#include "simple_test_model_capi_host.h"
#define sizeof(...) ((size_t)(0xFFFF))
#undef rt_offsetof
#define rt_offsetof(s,el) ((uint16_T)(0xFFFF))
#define TARGET_CONST
#define TARGET_STRING(s) (s)
#ifndef SS_UINT64
#define SS_UINT64 17
#endif
#ifndef SS_INT64
#define SS_INT64 18
#endif
#else
#include "builtin_typeid_types.h"
#include "simple_test_model.h"
#include "simple_test_model_capi.h"
#include "simple_test_model_private.h"
#ifdef LIGHT_WEIGHT_CAPI
#define TARGET_CONST
#define TARGET_STRING(s)               ((NULL))
#else
#define TARGET_CONST                   const
#define TARGET_STRING(s)               (s)
#endif
#endif
static const rtwCAPI_Signals rtBlockSignals [ ] = { { 0 , 0 , ( NULL ) , ( NULL
) , 0 , 0 , 0 , 0 , 0 } } ; static const rtwCAPI_BlockParameters
rtBlockParameters [ ] = { { 0 , TARGET_STRING ( "simple_test_model/SineSource"
) , TARGET_STRING ( "Amplitude" ) , 0 , 0 , 0 } , { 1 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "Bias" ) , 0 , 0 , 0 } , { 2 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "Frequency" ) , 0 , 0 , 0 } , { 3 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "Phase" ) , 0 , 0 , 0 } , { 4 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "SinH" ) , 0 , 0 , 0 } , { 5 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "CosH" ) , 0 , 0 , 0 } , { 6 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "SinPhi" ) , 0 , 0 , 0 } , { 7 , TARGET_STRING ( "simple_test_model/SineSource" ) , TARGET_STRING ( "CosPhi" ) , 0 , 0 , 0 } , { 8 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "Amplitude" ) , 0 , 0 , 0 } , { 9 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "Bias" ) , 0 , 0 , 0 } , { 10 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "Frequency" ) , 0 , 0 , 0 } , { 11 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "Phase" ) , 0 , 0 , 0 } , { 12 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "SinH" ) , 0 , 0 , 0 } , { 13 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "CosH" ) , 0 , 0 , 0 } , { 14 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "SinPhi" ) , 0 , 0 , 0 } , { 15 , TARGET_STRING ( "simple_test_model/SineSource2" ) , TARGET_STRING ( "CosPhi" ) , 0 , 0 , 0 } , { 0 , ( NULL ) , ( NULL ) , 0 , 0 , 0 } } ; static int_T rt_LoggedStateIdxList [ ] = { - 1 } ; static const rtwCAPI_Signals rtRootInputs [ ] = { { 0 , 0 , ( NULL ) , ( NULL ) , 0 , 0 , 0 , 0 , 0 } } ; static const rtwCAPI_Signals rtRootOutputs [ ] = { { 0 , 0 , ( NULL ) , ( NULL ) , 0 , 0 , 0 , 0 , 0 } } ; static const rtwCAPI_ModelParameters rtModelParameters [ ] = { { 0 , ( NULL ) , 0 , 0 , 0 } } ;
#ifndef HOST_CAPI_BUILD
static void * rtDataAddrMap [ ] = { & rtP . SineSource_Amp , & rtP .
SineSource_Bias , & rtP . SineSource_Freq , & rtP . SineSource_Phase , & rtP
. SineSource_Hsin , & rtP . SineSource_HCos , & rtP . SineSource_PSin , & rtP
. SineSource_PCos , & rtP . SineSource2_Amp , & rtP . SineSource2_Bias , &
rtP . SineSource2_Freq , & rtP . SineSource2_Phase , & rtP . SineSource2_Hsin
, & rtP . SineSource2_HCos , & rtP . SineSource2_PSin , & rtP .
SineSource2_PCos , } ; static int32_T * rtVarDimsAddrMap [ ] = { ( NULL ) } ;
#endif
static TARGET_CONST rtwCAPI_DataTypeMap rtDataTypeMap [ ] = { { "double" ,
"real_T" , 0 , 0 , sizeof ( real_T ) , ( uint8_T ) SS_DOUBLE , 0 , 0 , 0 } }
;
#ifdef HOST_CAPI_BUILD
#undef sizeof
#endif
static TARGET_CONST rtwCAPI_ElementMap rtElementMap [ ] = { { ( NULL ) , 0 ,
0 , 0 , 0 } , } ; static const rtwCAPI_DimensionMap rtDimensionMap [ ] = { {
rtwCAPI_SCALAR , 0 , 2 , 0 } } ; static const uint_T rtDimensionArray [ ] = {
1 , 1 } ; static const rtwCAPI_FixPtMap rtFixPtMap [ ] = { { ( NULL ) , ( NULL
) , rtwCAPI_FIX_RESERVED , 0 , 0 , ( boolean_T ) 0 } , } ; static const
rtwCAPI_SampleTimeMap rtSampleTimeMap [ ] = { { ( NULL ) , ( NULL ) , 0 , 0 }
} ; static rtwCAPI_ModelMappingStaticInfo mmiStatic = { { rtBlockSignals , 0
, rtRootInputs , 0 , rtRootOutputs , 0 } , { rtBlockParameters , 16 ,
rtModelParameters , 0 } , { ( NULL ) , 0 } , { rtDataTypeMap , rtDimensionMap
, rtFixPtMap , rtElementMap , rtSampleTimeMap , rtDimensionArray } , "float"
, { 2092904941U , 3188935243U , 3005175309U , 1220780648U } , ( NULL ) , 0 ,
( boolean_T ) 0 , rt_LoggedStateIdxList } ; const
rtwCAPI_ModelMappingStaticInfo * simple_test_model_GetCAPIStaticMap ( void )
{ return & mmiStatic ; }
#ifndef HOST_CAPI_BUILD
void simple_test_model_InitializeDataMapInfo ( void ) { rtwCAPI_SetVersion ( ( *
rt_dataMapInfoPtr ) . mmi , 1 ) ; rtwCAPI_SetStaticMap ( ( *
rt_dataMapInfoPtr ) . mmi , & mmiStatic ) ; rtwCAPI_SetLoggingStaticMap ( ( *
rt_dataMapInfoPtr ) . mmi , ( NULL ) ) ; rtwCAPI_SetDataAddressMap ( ( *
rt_dataMapInfoPtr ) . mmi , rtDataAddrMap ) ; rtwCAPI_SetVarDimsAddressMap ( ( *
rt_dataMapInfoPtr ) . mmi , rtVarDimsAddrMap ) ;
rtwCAPI_SetInstanceLoggingInfo ( ( * rt_dataMapInfoPtr ) . mmi , ( NULL ) ) ;
rtwCAPI_SetChildMMIArray ( ( * rt_dataMapInfoPtr ) . mmi , ( NULL ) ) ;
rtwCAPI_SetChildMMIArrayLen ( ( * rt_dataMapInfoPtr ) . mmi , 0 ) ; }
#else
#ifdef __cplusplus
extern "C" {
#endif
void simple_test_model_host_InitializeDataMapInfo ( simple_test_model_host_DataMapInfo_T * dataMap , const char * path ) { rtwCAPI_SetVersion ( dataMap -> mmi , 1 ) ; rtwCAPI_SetStaticMap ( dataMap -> mmi , & mmiStatic ) ; rtwCAPI_SetDataAddressMap ( dataMap -> mmi , ( NULL ) ) ; rtwCAPI_SetVarDimsAddressMap ( dataMap -> mmi , ( NULL ) ) ; rtwCAPI_SetPath ( dataMap -> mmi , path ) ; rtwCAPI_SetFullPath ( dataMap -> mmi , ( NULL ) ) ; rtwCAPI_SetChildMMIArray ( dataMap -> mmi , ( NULL ) ) ; rtwCAPI_SetChildMMIArrayLen ( dataMap -> mmi , 0 ) ; }
#ifdef __cplusplus
}
#endif
#endif
