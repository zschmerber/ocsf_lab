<!--
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
-->
# OCSF lab Quick start
This is a docker compose environment to quickly get up and running with a Tenzir, ClickHouse environment and MinIO as a storage backend.

**note**: If you don't have docker installed, you can head over to the [Get Docker](https://docs.docker.com/get-docker/)
page for installation instructions.

## Prereqs

`brew install docker-compose`

## Usage
Start up the  servers by running the following.
```
docker-compose up
```
The Minio dashboard server will then be available at http://localhost:10000 or http://localhost:10001
user = admin
password = password
```
3. proceed to https://tenzir.com/ create login and make a docker node 
4. copy docker config keys and path found in Tenzir docker file, add key and path to docker compose file 

To stop everything, just run `docker-compose down`.
```
Default logins
Default logins for each container:
admin 
password

http://localhost:8123/play
```
let $proto_nums = {
  tcp: 6,
  udp: 17,
  icmp: 1,
  icmpv6: 58,
  ipv6: 41,
}

from "s3://admin:password@raw/dns.json.gz?endpoint_override=http://minio:10000" {
  decompress_gzip
  read_ndjson raw=true
  }
this = { zeek: this }
// === Classification ===
ocsf.activity_id = 6
ocsf.activity_name = "Traffic"
ocsf.category_uid = 4
ocsf.category_name = "Network Activity"
ocsf.class_uid = 4003
ocsf.class_name = "DNS Activity"
ocsf.severity_id = 1
ocsf.severity = "Informational"
ocsf.type_uid = ocsf.class_uid * 100 + ocsf.activity_id
// === Occurrence ===
ocsf.time = as_secs(since_epoch(time(zeek.ts)))
ocsf.time_dt = zeek.ts
ocsf.start_time = ocsf.time
// === Context ===
ocsf.metadata = {
  log_name: "dns.log",
  logged_time: zeek._write_ts,
  product: {
    name: "Zeek",
    vendor_name: "Zeek",
    cpe_name: "cpe:2.3:a:zeek:zeek",
  },
  uid: zeek.uid,
  version: "1.4.0",
}
drop zeek._path, zeek._write_ts, zeek.uid
// === Primary ===
ocsf.answers = zip(zeek.answers, zeek.TTLs).map(x, {
  rdata: x.left,
  ttl: x.right,
})
drop zeek.answers, zeek.TTLs
ocsf.query = {
  class: zeek.qclass_name,
  hostname: zeek.query,
  // TODO: go deeper and extract the log semantics.
  //opcode_id: 0,
  type: zeek.qtype_name,
}
ocsf.query_time = ocsf.time
ocsf.response_time = ocsf.time
ocsf.rcode = zeek.rcode_name
drop zeek.rcode_name
ocsf.rcode_id = zeek.rcode
drop zeek.rcode
drop zeek.qclass_name, zeek.query, zeek.qtype_name
ocsf.src_endpoint = {
  ip: zeek.id.orig_h,
  port: zeek.id.orig_p,
}
ocsf.dst_endpoint = {
  ip: zeek.id.resp_h,
  port: zeek.id.resp_p,
}
ocsf.connection_info = {
  direction: "Other",
  direction_id: 99,
  protocol_name: zeek.proto,
  protocol_num: $proto_nums[zeek.proto].otherwise(-1),
}
drop zeek.proto
if zeek.id.orig_h.is_v6() or zeek.id.resp_h.is_v6() {
  ocsf.connection_info.protocol_ver_id = 6
} else {
  ocsf.connection_info.protocol_ver_id = 4
}
drop zeek.id
ocsf.status = "Unknown"
ocsf.status_id = 0

this = {...ocsf, unmapped: zeek}
drop unmapped // unmapped had some malfomed headers i did not know how to remove 
this = flatten(this, "_")

@name = "ocsf.dns_activity"
write_ndjson strip_null_fields=true, strip_empty_records = true, strip_empty_lists = true
read_ndjson
//to "s3://admin:password@clickhouse/ocsfdns.json?endpoint_override=http://minio:10000" 


to_clickhouse table="dnshead2222", host="clickhouse", primary=activity_name, tls=false
```
the above TQL takes the logs flattens them and removes nulls then sends to clickhouse default 