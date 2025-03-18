package transformer

import (
	"testing"
)

func TestInvalidQueueTypes(t *testing.T) {
	if _, err := getNativeQueueNameByQueueType("IDONTEXIST", "AF4"); err == nil {
		t.Fatalf("getNativeQueueNameByQueueType didn't return an error with a bogus queue type")
	}
	if _, err := getQueueNameFromIdByQueueType("IDONTEXIST", "0"); err == nil {
		t.Fatalf("getQueueNameFromIdByQueueType didn't return an error with a bogus queue type")
	}
}

func TestPathTransformersInvalidKeys(t *testing.T) {
	inParams := XfmrDbToYgPathParams{
		tblKeyComp: []string{},
		ygPathKeys: map[string]string{},
	}

	if err := DbToYangPath_qos_buffer_allocation_profile_path_xfmr(inParams); err == nil {
		t.Errorf("Expected an error from DbToYangPath_qos_buffer_allocation_profile_path_xfmr, but got %v", err)
	}
	if err := DbToYangPath_qos_fwdgrp_path_xfmr(inParams); err == nil {
		t.Errorf("Expected an error from DbToYangPath_qos_fwdgrp_path_xfmr, but got %v", err)
	}
	if err := DbToYangPath_qos_scheduler_policy_path_xfmr(inParams); err == nil {
		t.Errorf("Expected an error from DbToYangPath_qos_scheduler_policy_path_xfmr, but got %v", err)
	}
}
