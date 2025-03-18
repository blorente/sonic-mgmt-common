package transformer

import (
	"fmt"

	"github.com/Azure/sonic-mgmt-common/translib/db"
)

// Redis Table Names
const (
	OCS_HV_CARD_CHANNEL_TABLE_NAME   = "OCS_HV_CARD_CHANNEL"
	OCS_LDS_STATUSES_PORT_TABLE_NAME = "OCS_LDS_PORT_INFO"
)

func init() {
	XlateFuncBind("DbToYang_rdbk_v_xfmr", DbToYang_rdbk_v_xfmr)
	XlateFuncBind("DbToYang_expt_v_xfmr", DbToYang_expt_v_xfmr)
	XlateFuncBind("DbToYang_temp_xfmr", DbToYang_temp_xfmr)
}

var DbToYang_rdbk_v_xfmr FieldXfmrDbtoYang = func(inParams XfmrParams) (map[string]interface{}, error) {
	return dbToYangIeeefloat32(inParams, db.StateDB, OCS_HV_CARD_CHANNEL_TABLE_NAME, inParams.key, "readback-voltage")
}
var DbToYang_expt_v_xfmr FieldXfmrDbtoYang = func(inParams XfmrParams) (map[string]interface{}, error) {
	return dbToYangIeeefloat32(inParams, db.StateDB, OCS_HV_CARD_CHANNEL_TABLE_NAME, inParams.key, "expected-voltage")
}
var DbToYang_temp_xfmr FieldXfmrDbtoYang = func(inParams XfmrParams) (map[string]interface{}, error) {
	return dbToYangIeeefloat32(inParams, db.StateDB, OCS_LDS_STATUSES_PORT_TABLE_NAME, inParams.key, "temperature")
}

func dbToYangIeeefloat32(inParams XfmrParams, dbNum db.DBNum, tableName, entryKey, fldName string) (map[string]interface{}, error) {
	rv := make(map[string]interface{})

	if inParams.dbDataMap == nil {
		return nil, fmt.Errorf("nil dbDataMap, inParams %#v", inParams)
	}
	dbData, ok := (*inParams.dbDataMap)[dbNum]
	if !ok {
		return nil, fmt.Errorf("dbDataMap not present, inParams %#v inParams.dbDataMap %#v, dbNum %v", inParams, inParams.dbDataMap, dbNum)
	}
	tblData, ok := dbData[tableName]
	if !ok {
		return nil, fmt.Errorf("Table not present, inParams %#v dbDataMap %#v, tblName %v", inParams, dbData, tableName)
	}
	entry, ok := tblData[entryKey]
	if !ok {
		return nil, fmt.Errorf("Table entry not present, inParams %#v tblData %#v, entryKey %v", inParams, tblData, entryKey)
	}
	strVal, ok := entry.Field[fldName]
	if !ok {
		return nil, fmt.Errorf("Table entry field not present, inParams %#v entry %#v, fldName %v", inParams, entry.Field, fldName)
	}
	base64Str, err := float32StrTo4Bytes(strVal)
	if err != nil {
		return nil, fmt.Errorf("Unable to convert field to float string. Value was %s. Error %w", strVal, err)
	}
	rv[fldName] = base64Str
	return rv, nil
}
