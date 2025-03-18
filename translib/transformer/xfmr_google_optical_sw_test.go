package transformer

import (
	"testing"

	"github.com/Azure/sonic-mgmt-common/translib/db"
)

func TestOpticalSwitchXfmr(t *testing.T) {
	inParams := XfmrParams{}
	fields := map[string]string{"fldName": "fldVal"}
	dbVal := db.Value{Field: fields}
	keys := map[string]db.Value{"keyName": dbVal}
	tables := map[string]map[string]db.Value{"tblName": keys}
	testMap := map[db.DBNum]map[string]map[string]db.Value{db.StateDB: tables}

	inParams.dbDataMap = nil
	rv, err := dbToYangIeeefloat32(inParams, db.StateDB, "tblName", "keyName", "fldName")
	if rv != nil || err == nil {
		t.Fatalf("No DB Data Map: Expected nil result (%v) and non-nil error (%v)", rv, err)
	}

	inParams.dbDataMap = &testMap
	rv, err = dbToYangIeeefloat32(inParams, db.MaxDB, "tblName", "keyName", "fldName")
	if rv != nil || err == nil {
		t.Fatalf("No DB: Expected nil result (%v) and non-nil error (%v)", rv, err)
	}

	rv, err = dbToYangIeeefloat32(inParams, db.StateDB, "BadTable", "keyName", "fldName")
	if rv != nil || err == nil {
		t.Fatalf("No Table: Expected nil result (%v) and non-nil error (%v)", rv, err)
	}

	rv, err = dbToYangIeeefloat32(inParams, db.StateDB, "tblName", "BadKey", "fldName")
	if rv != nil || err == nil {
		t.Fatalf("No Key: Expected nil result (%v) and non-nil error (%v)", rv, err)
	}

	rv, err = dbToYangIeeefloat32(inParams, db.StateDB, "tblName", "keyName", "BadField")
	if rv != nil || err == nil {
		t.Fatalf("No Field: Expected nil result (%v) and non-nil error (%v)", rv, err)
	}

	rv, err = dbToYangIeeefloat32(inParams, db.StateDB, "tblName", "keyName", "fldName")
	if rv != nil || err == nil {
		t.Fatalf("Bad Field Val: Expected nil result (%v) and non-nil error (%v)", rv, err)
	}
}
