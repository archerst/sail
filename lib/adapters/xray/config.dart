import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:meta/meta.dart';

/*
            {
            "log": {
              "loglevel": "info",
              "access": "{{accessLogFile}}",
              "error": "{{errorLogFile}}"
            },
            "inbounds": [
              {
                "listen": "127.0.0.1",
                "protocol": "socks",
                "port": "10801",
                "settings": {
                  "auth": "noauth",
                  "udp": true
                }
              }
            ],
            "outbounds": [
              {
                "streamSettings": {
                  "tlsSettings": {
                    "serverName": "excellentconnect.com",
                    "allowInsecure": false,
                    "alpn": ["h2", "http/1.1"],
                    "fingerprint": "ios",
                  },
                  "tcpSettings": {
                    "header": {
                      "type": "none"
                    }
                  },
                  "network": "tcp",
                  "security": "tls"
                },
                "mux": {
                  "concurrency": 8,
                  "enabled": false
                },
                "protocol": "vless",
                "tag": "proxy",
                "settings": {
                  "vnext": [
                    {
                      "address": "212.50.251.189",
                      "users": [
                        {
                          "level": 0,
                          "encryption": "none",
                          "flow": "xtls-rprx-vision",
                          "id": "9f49c873-9e9c-4e6b-8f26-3f293c3455fc"
                        }
                      ],
                      "port": 443
                    }
                  ]
                }
              },
              {
                "settings": {
                  "domainStrategy": "UseIP",
                  "userLevel": 0
                },
                "protocol": "freedom",
                "tag": "direct"
              },
              {
                "settings": {
                  "response": {
                    "type": "none"
                  }
                },
                "tag": "block",
                "protocol": "blackhole"
              }
            ],
            "dns": {},
            "routing": {
              "settings": {
                "domainStrategy": "AsIs",
                "rules": []
              }
            },
            "transport": {}
          }
*/
class Config {
  Config({
    required this.log,
    required this.inbounds,
    required this.outbounds
  });

  final Log log;
  List<Inbound> inbounds;
  List<Outbound> outbounds;
  
  factory Config.fromJson(String str) => Config.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Config.fromMap(Map<String, dynamic> json) => Config(
    log: json["log"],
    inbounds:  List<Inbound>.from(json["inbounds"].map((x) => Inbound.fromMap((x)))),
    outbounds:  List<Outbound>.from(json["outbounds"].map((x) => Outbound.fromMap((x)))),
  );

  Map<String, dynamic> toMap() => {
        "log": log,
        "inbounds": inbounds,
        "outbounds": outbounds,
  };
}

class Log{
  Log({
    required this.level,
    required this.accessFile,
    required this.errorFile,
  });

  final String level;
  final String accessFile;
  final String errorFile;
  
  factory Log.fromJson(String str) => Log.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Log.fromMap(Map<String, dynamic> json) => Log(
    level: json["level"],
    accessFile: json["access"],
    errorFile: json["error"],
  );

  Map<String, dynamic> toMap() => {
    "level":level,
    "access":accessFile,
    "error":errorFile
  };
}

class Inbound{
  Inbound({
    required this.listen,
    required this.protocol,
    required this.port,
    required this.setting
  });

  final String listen;
  final String protocol;
  final String port;
  final InboundSetting setting;

  factory Inbound.fromJson(String str) => Inbound.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Inbound.fromMap(Map<String, dynamic> json) => Inbound(
    listen: json["listen"],
    protocol: json["protocol"],
    port: json["port"],
    setting: InboundSetting.fromMap(json["settings"]),
  );

  Map<String, dynamic> toMap() => {
    "listen":listen,
    "protocol":protocol,
    "port":port,
  };
}

class InboundSetting{
  InboundSetting({
    required this.auth,
    required this.udp,
  });

  final String auth;
  final bool udp;
  factory InboundSetting.fromJson(String str) => InboundSetting.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InboundSetting.fromMap(Map<String, dynamic> json) => InboundSetting(
    auth: json["auth"],
    udp: json["udp"],
  );

  Map<String, dynamic> toMap() => {
    "auth":auth,
    "udp":udp
  };
}
/*
    {
      "tag": "标识",
      "protocol": "协议名称",
      "settings": {},
      "streamSettings": {},
      "mux": {}
    }
 */
class Outbound{
  Outbound({
    this.tag = "vless",
    this.protocol = "vless",
    required this.mux,
    required this.streamSetting,
    required this.settings
  });

  String protocol;
  String tag;
  StreamSettings streamSetting;
  Mux mux;
  OutboundSettings settings;


  factory Outbound.fromJson(String str) => Outbound.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Outbound.fromMap(Map<String, dynamic> json) => Outbound(
    tag:json["tag"],
    protocol: json["protocol"],
    streamSetting: StreamSettings.fromMap(json["settings"]),
    mux: Mux.fromMap(json["mux"]),
    settings: OutboundSettings.fromMap(json["settings"])
  );

  Map<String, dynamic> toMap() => {
    "tag":tag,
    "protocol":protocol,
    "mux":mux.toMap(),
    "streamSetting":streamSetting.toMap(),
    "settings":settings.toMap()
  };
}

/*
  "streamSettings": {
    "tlsSettings": {
      "serverName": "excellentconnect.com",
      "allowInsecure": false,
      "alpn": ["h2", "http/1.1"],
      "fingerprint": "ios",
    },
    "tcpSettings": {
      "header": {
        "type": "none"
      }
    },
    "network": "tcp",
    "security": "tls"
  },
*/
class StreamSettings{
  StreamSettings({
    required this.tlsSettings,
    required this.tcpSettings,
    required this.network,
    required this.security,
  });

  TlsSettings tlsSettings;
  TCPSettings tcpSettings;
  String network;
  String security;

  factory StreamSettings.fromJson(String str) => StreamSettings.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StreamSettings.fromMap(Map<String, dynamic> json) => StreamSettings(
    network: json["network"],
    security: json["security"],
    tcpSettings: TCPSettings.fromMap(json["tcpSettings"]),
    tlsSettings: TlsSettings.fromMap(json["tlsSettings"])
  );

  Map<String, dynamic> toMap() => {
    "network":network,
    "security":security,
    "tcpSettings": tcpSettings.toMap(),
    "tlsSettings": tlsSettings.toMap()
  };
}

class TlsSettings{
  TlsSettings({
    required this.serverName,
    this.allowInsecure = false,
    required this.alpn,
    required this.fingerprint
  });
  
  String serverName;
  bool allowInsecure;
  List<String> alpn;
  String fingerprint;
  
  factory TlsSettings.fromJson(String str) => TlsSettings.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TlsSettings.fromMap(Map<String, dynamic> json) => TlsSettings(
    serverName: json["serverName"],
    allowInsecure: json["allowInsecure"],
    alpn: List<String>.from(json["alpn"].map((x) => x)),
    fingerprint: json["fingerprint"]
  );

  Map<String, dynamic> toMap() => {
    "serverName":serverName,
    "allowInsecure":allowInsecure,
    "alpn":alpn,
    "fingerprint":fingerprint
  };
}

class TCPSettings{
  TCPSettings({
    required this.header
  });
  
  TCPHeader header;
  
  factory TCPSettings.fromJson(String str) => TCPSettings.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TCPSettings.fromMap(Map<String, dynamic> json) => TCPSettings(
    header: TCPHeader.fromMap(json["header"]),
  );

  Map<String, dynamic> toMap() => {
    "header": header.toMap(),
  };
}

class TCPHeader{
  TCPHeader({
    required this.type,
  });
  
  String type;
  
  factory TCPHeader.fromJson(String str) => TCPHeader.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TCPHeader.fromMap(Map<String, dynamic> json) => TCPHeader(
    type: json["type"],
  );

  Map<String, dynamic> toMap() => {
    "type":type,
  };
}
/*
                "mux": {
                  "concurrency": 8,
                  "enabled": false
                },
*/

class Mux {
  Mux({
    required this.concurrency,
    required this.enabled,
  });
  int concurrency;
  bool enabled; 
  
  factory Mux.fromJson(String str) => Mux.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Mux.fromMap(Map<String, dynamic> json) => Mux(
    concurrency: json["concurrency"],
    enabled: json["enabled"]
  );

  Map<String, dynamic> toMap() => {
    "concurrency" : concurrency,
    "enabled":enabled,
  };
}
/*outbound setting:
 "settings": {
   "vnext": [
     {
       "address": "212.50.251.189",
       "users": [
         {
           "level": 0,
           "encryption": "none",
           "flow": "xtls-rprx-vision",
           "id": "9f49c873-9e9c-4e6b-8f26-3f293c3455fc"
         }
       ],
       "port": 443
     }
   ]
 }
*/
class OutboundSettings{
  OutboundSettings({
    required this.vnext
  });
  List<VlessServer> vnext;
  factory OutboundSettings.fromJson(String str) => OutboundSettings.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OutboundSettings.fromMap(Map<String, dynamic> json) => OutboundSettings(
    vnext: List<VlessServer>.from(json["vnext"].map((x) => VlessServer.fromMap((x)))),
  );

  Map<String, dynamic> toMap() => {
    "vnext" : List<Map<String,dynamic>>.from(vnext.map((x) => x.toMap())),
  };
}
class VlessServer{
  VlessServer({
    required this.address,
    required this.port,
    required this.users
  });
  String address;
  int port;
  List<User> users;
  
  factory VlessServer.fromJson(String str) => VlessServer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VlessServer.fromMap(Map<String, dynamic> json) => VlessServer(
    address: json["address"],
    port: json["port"],
    users: List<User>.from(json["users"].map((x) => User.fromMap((x)))),
  );

  Map<String, dynamic> toMap() => {
    "address":address,
    "port":port,
    "users" : List<Map<String,dynamic>>.from(users.map((x) => x.toMap())),
  };
}

class User{
  User({
    required this.encryption,
    required this.id,
    required this.level,
    required this.flow
  });
  String id;
  int level;
  String encryption;
  String flow;
  
  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    level: json["level"],
    encryption: json["encryption"],
    flow: json["flow"]
  );

  Map<String, dynamic> toMap() => {
    "id":id,
    "level":level,
    "encryption" : encryption,
    "flow":flow
  };
}


