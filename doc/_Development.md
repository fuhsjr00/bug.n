## Malware detection

The binary from bug.n version 9.0.2 is detected by 32/ 71 engines on VirusTotal and is detected by Windows Defender (2019-06-16):

https://www.virustotal.com/gui/file/23a183d7e6de87a0b200cec985a0b01b5e5357b54d79fa3fa4ddd552e156b884/detection

bug.n without the following code snippets results in a binary which is detected by 5/ 66 engines and is not detected by Windows Defender (2019-06-16):

* `SetTimer`
* `Manager_registerShellHook`

https://www.virustotal.com/gui/file/06f116d9841324d696e91996b4593d6bccee2e0d357ba9e7165f3d820c4a807e/detection


## Hash

File    : <bugn.exe from release v9.0.2>
MD5     : 8263B9CE A2455592 8B67EC3C 319F0154
SHA-1   : 4A26CEA1 346AD6A3 7A445F41 8FF908CC 653872C5
SHA-256 : 23A183D7 E6DE87A0 B200CEC9 85A0B01B 5E5357B5
          4D79FA3F A4DDD552 E156B884
SHA-512 : 35B579C7 5D846A05 4DE19468 39BADEEE 690E312B
          E10C7345 C5064A82 DD3F75AA 6D15AF01 6C9FFAFB
          250B0BD5 051B7112 A9FC59F8 AF3D83CC B3CDB726
          1C2A59AF
Size-64 : 00000000 000E2E00

File    : <bugn.exe re-build from source of release v9.0.2 on the same machine>
MD5     : 8263B9CE A2455592 8B67EC3C 319F0154
SHA-1   : 4A26CEA1 346AD6A3 7A445F41 8FF908CC 653872C5
SHA-256 : 23A183D7 E6DE87A0 B200CEC9 85A0B01B 5E5357B5
          4D79FA3F A4DDD552 E156B884
SHA-512 : 35B579C7 5D846A05 4DE19468 39BADEEE 690E312B
          E10C7345 C5064A82 DD3F75AA 6D15AF01 6C9FFAFB
          250B0BD5 051B7112 A9FC59F8 AF3D83CC B3CDB726
          1C2A59AF
Size-64 : 00000000 000E2E00

