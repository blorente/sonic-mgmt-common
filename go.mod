module github.com/Azure/sonic-mgmt-common

go 1.21

require (
	github.com/Workiva/go-datastructures v1.0.50
	github.com/antchfx/jsonquery v1.1.4
	github.com/antchfx/xmlquery v1.3.1
	github.com/antchfx/xpath v1.1.10
	github.com/go-redis/redis/v7 v7.4.1
	github.com/godbus/dbus/v5 v5.1.0
	github.com/golang/glog v1.1.2
	github.com/golang/groupcache v0.0.0-20200121045136-8c9f03a8e57e
	github.com/google/go-cmp v0.5.9
	github.com/kylelemons/godebug v1.1.0
	github.com/maruel/natural v1.1.1
	github.com/openconfig/gnmi v0.11.0
	github.com/openconfig/goyang v0.2.9
	github.com/openconfig/ygot v0.13.1
	github.com/philopon/go-toposort v0.0.0-20170620085441-9be86dbd762f
	github.com/pkg/profile v1.7.0
	github.com/redis/go-redis/v9 v9.6.1
	github.com/tredoe/osutil v1.5.0
	golang.org/x/text v0.13.0
	google.golang.org/grpc v1.60.1
)

require (
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/dgryski/go-rendezvous v0.0.0-20200823014737-9f7001d12a5f // indirect
	github.com/felixge/fgprof v0.9.3 // indirect
	github.com/golang/protobuf v1.5.3 // indirect
	github.com/google/pprof v0.0.0-20211214055906-6f57359322fd // indirect
	github.com/stretchr/testify v1.8.4 // indirect
	golang.org/x/net v0.16.0 // indirect
	golang.org/x/sys v0.13.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20231002182017-d307bd883b97 // indirect
	google.golang.org/protobuf v1.31.0 // indirect
)

// Glog patch needs to be updated to remove this.
replace github.com/golang/glog => github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b
