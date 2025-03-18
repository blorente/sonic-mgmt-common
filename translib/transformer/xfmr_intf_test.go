package transformer

import (
	"reflect"
	"testing"

	"github.com/Azure/sonic-mgmt-common/translib/db"
)

func TestGetIntfsRoot(t *testing.T) {
	if r := getIntfsRoot(nil); r != nil {
		t.Fatalf("Testing that this operation doesn't cause a crash")
	}
}

func TestEmptyParams(t *testing.T) {
	var xp XfmrParams
	for fn, f := range map[string]interface{}{
		"DbToYang_intf_state_blackhole_xfmr": DbToYang_intf_state_blackhole_xfmr,
		"YangToDb_intf_diag_profile_xfmr":    YangToDb_intf_diag_profile_xfmr,
		"DbToYang_intf_description_xfmr":     DbToYang_intf_description_xfmr} {
		v := reflect.ValueOf(f)
		in := []reflect.Value{reflect.ValueOf(xp)}
		ret := v.Call(in)
		last := ret[len(ret)-1].Interface()
		if _, ok := last.(error); !ok {
			t.Fatalf("Empty XfmrParams didn't generate an error with %s", fn)
		}
	}
}

func TestReadAndParseCounter(t *testing.T) {
	entry := db.Value{
		Field: map[string]string{
			"good_int": "123",
			"bad_int":  "meeple",
		},
	}
	var r uint64
	pr := &r
	if err := readAndParseCounter(&entry, "good_int", &pr); err != nil {
		t.Fatalf("Failed to retrive valid value")
	}
	if err := readAndParseCounter(&entry, "bad_int", &pr); err == nil {
		t.Fatalf("Parse error didn't generate a failure")
	}
	if err := readAndParseCounter(&entry, "missing_int", &pr); err == nil {
		t.Fatalf("Missing field didn't generate a failure")
	}
}

func TestReadAndParseCounters(t *testing.T) {
	entry := db.Value{
		Field: map[string]string{
			"good_int": "123",
		},
	}
	var r uint64
	pr := &r
	fls := []fieldU64LeafPair{
		{"good_int", &pr},
	}
	if e := readAndParseCounters(&entry, fls); e != nil {
		t.Fatalf("Unexpected error")
	}

	fls = []fieldU64LeafPair{
		{"good_int", &pr},
		{"missing_int", &pr},
	}
	if e := readAndParseCounters(&entry, fls); e != nil {
		t.Fatalf("Unexpected error, should ignore miss")
	}

	entry = db.Value{
		Field: map[string]string{
			"good_int": "123",
			"bad_int":  "meeple",
		},
	}
	fls = []fieldU64LeafPair{
		{"good_int", &pr},
		{"bad_int", &pr},
	}
	if e := readAndParseCounters(&entry, fls); e == nil {
		t.Fatalf("Expected a failure from parsing bad_int")
	}
}
