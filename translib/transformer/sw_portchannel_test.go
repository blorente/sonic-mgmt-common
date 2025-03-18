package transformer

import (
	"testing"

	"github.com/Azure/sonic-mgmt-common/translib/db"
)

func TestGetLagState(t *testing.T) {
	ifName := "PortChannel54321"
	lagInfoMap := map[string]db.Value{"PortChannel1": db.Value{}}
	if r := getLagState(&ifName, lagInfoMap, nil); r == nil {
		t.Fatalf("Operation did not return an error as expected")
	}
}

func TestDeleteLagIntfAndMembers(t *testing.T) {
	if err := deleteLagIntfAndMembers(nil, nil); err == nil {
		t.Fatalf("Call to deleteLagIntfAndMembers did not return an error as expected")
	}
}
